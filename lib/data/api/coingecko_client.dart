import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:coinlens/core/config.dart';
import 'package:coinlens/data/api/api_client.dart';
import 'package:coinlens/data/api/coingecko_mapper.dart';
import 'package:coinlens/data/cache/ttl_cache.dart';
import 'package:coinlens/models/chart_point.dart';
import 'package:coinlens/models/coin_detail.dart';
import 'package:coinlens/models/coin_market.dart';
import 'package:coinlens/models/global_stats.dart';

/// Live market data from CoinGecko's free public REST API, with Binance as a
/// backup source for charts.
class CoinGeckoClient implements ApiClient {
  CoinGeckoClient({
    http.Client? client,
    this.baseUrl = 'https://api.coingecko.com/api/v3',
    this.binanceUrl = 'https://data-api.binance.vision/api/v3',
    this.apiKey = kCoinGeckoApiKey,
    this.maxRateLimitWait = const Duration(seconds: 60),
    TtlCache<dynamic>? cache,
  })  : _client = client ?? http.Client(),
        _cache = cache ?? TtlCache<dynamic>();

  final http.Client _client;
  final String baseUrl;

  /// Binance's free public market data, used for charts when CoinGecko is rate limiting.
  final String binanceUrl;
  final String apiKey;

  /// Longest pause before quietly retrying a rate-limited request.
  final Duration maxRateLimitWait;

  /// The free API allows few calls per minute, so responses are cached on the device.
  final TtlCache<dynamic> _cache;

  /// CoinGecko refreshes free data every 1-5 minutes, so 2 minutes loses little and
  /// leaves calls free for charts.
  static const _shortTtl = Duration(minutes: 2);
  static const _longTtl = Duration(minutes: 5);

  // ---- Endpoints

  @override
  Future<Fetched<List<CoinMarket>>> markets({int perPage = 250, String category = ''}) {
    return _quietly(() async {
      final r = await _get('/coins/markets', {
        'vs_currency': 'usd',
        'order': 'market_cap_desc',
        'per_page': '$perPage',
        'page': '1',
        'sparkline': 'false',
        'price_change_percentage': '24h',
        if (category.isNotEmpty) 'category': category,
      }, _shortTtl);
      final list = [
        for (final e in r.data as List) CoinMarket.fromJson(mapMarket(e as Map<String, dynamic>)),
      ];
      return Fetched(list, stale: r.stale);
    });
  }

  @override
  Future<Fetched<CoinDetail>> coin(String id) {
    return _quietly(() async {
      final r = await _get('/coins/${Uri.encodeComponent(id)}', {
        'localization': 'false',
        'tickers': 'false',
        'market_data': 'true',
        'community_data': 'false',
        'developer_data': 'false',
        'sparkline': 'false',
      }, _longTtl);
      return Fetched(
        CoinDetail.fromJson(mapCoinDetail(r.data as Map<String, dynamic>)),
        stale: r.stale,
      );
    });
  }

  /// Price points from CoinGecko. If CoinGecko fails, falls back to Binance
  /// candles for [symbol] right away, so the chart still appears.
  @override
  Future<Fetched<List<ChartPoint>>> chart(String id, int days, {String symbol = ''}) {
    return _quietly(() async {
      final Fetched<List<Map<String, dynamic>>> raw;
      try {
        final r = await _get(
          '/coins/${Uri.encodeComponent(id)}/market_chart',
          {'vs_currency': 'usd', 'days': '$days'},
          _longTtl,
          waitOnBurst: symbol.isEmpty,
        );
        raw = Fetched(mapMarketChart(r.data as Map<String, dynamic>), stale: r.stale);
      } on ApiException catch (coingeckoError) {
        if (symbol.isEmpty) rethrow;
        try {
          return _points(await _binanceChart(symbol.toUpperCase(), days));
        } on ApiException {
          // Not listed on Binance either: report CoinGecko's error, so a rate limit
          // is waited out and retried instead of shown.
          throw coingeckoError;
        }
      }
      return _points(raw);
    });
  }

  @override
  Future<Fetched<GlobalStats>> global() {
    return _quietly(() async {
      final r = await _get('/global', const {}, _shortTtl);
      return Fetched(GlobalStats.fromJson(mapGlobal(r.data as Map<String, dynamic>)), stale: r.stale);
    });
  }

  static Fetched<List<ChartPoint>> _points(Fetched<List<Map<String, dynamic>>> r) =>
      Fetched([for (final p in r.data) ChartPoint.fromJson(p)], stale: r.stale);

  /// Binance kline interval and candle count for each chart range.
  static const _klines = {1: ('5m', 288), 7: ('1h', 168), 30: ('4h', 180), 365: ('1d', 365)};

  /// Close prices of SYMBOL/USDT candles. Tether has no USDT pair, so it is
  /// priced from USDC/USDT, inverted.
  Future<Fetched<List<Map<String, dynamic>>>> _binanceChart(String symbol, int days) async {
    final (interval, limit) = _klines[days] ?? ('1d', days.clamp(1, 1000));
    final invert = symbol == 'USDT';
    final uri = Uri.parse('$binanceUrl/klines').replace(queryParameters: {
      'symbol': invert ? 'USDCUSDT' : '${symbol}USDT',
      'interval': interval,
      'limit': '$limit',
    });
    final r = await _getUri(uri, _longTtl, waitOnBurst: true);
    final points = mapBinanceKlines(r.data as List, invert: invert);
    if (points.isEmpty) throw ApiException('upstream_error', 'No chart data');
    return Fetched(points, stale: r.stale);
  }

  // ---- HTTP, cache and retries

  /// Runs [load], and if it is rate limited, waits and tries once more instead of
  /// failing, so screens stay on their loading state rather than showing an error.
  Future<T> _quietly<T>(Future<T> Function() load) async {
    try {
      return await load();
    } on ApiException catch (e) {
      if (!e.isRateLimited) rethrow;
      final wait = Duration(seconds: e.retryAfter ?? 10);
      await Future<void>.delayed(wait < maxRateLimitWait ? wait : maxRateLimitWait);
      return load();
    }
  }

  Future<Fetched<dynamic>> _get(
    String path,
    Map<String, String> query,
    Duration ttl, {
    bool waitOnBurst = true,
  }) {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query.isEmpty ? null : query);
    return _getUri(uri, ttl, waitOnBurst: waitOnBurst);
  }

  /// Requests already on their way, so identical calls made at the same time
  /// (several screens loading at once) share one network call.
  final _inFlight = <String, Future<Fetched<dynamic>>>{};

  /// Returns a fresh cached body, or fetches one. If the fetch fails and an
  /// expired copy exists, returns that copy marked stale.
  Future<Fetched<dynamic>> _getUri(Uri uri, Duration ttl, {required bool waitOnBurst}) {
    final key = uri.toString();
    final hit = _cache.fresh(key);
    if (hit != null) return Future.value(Fetched(hit));
    // The callback must not return the removed future: whenComplete would wait on it, i.e. on itself.
    return _inFlight[key] ??= _download(uri, key, ttl, waitOnBurst: waitOnBurst).whenComplete(() {
      _inFlight.remove(key);
    });
  }

  Future<Fetched<dynamic>> _download(Uri uri, String key, Duration ttl, {required bool waitOnBurst}) async {
    try {
      final body = await _fetch(uri, waitOnBurst: waitOnBurst);
      _cache.put(key, body, ttl);
      return Fetched(body);
    } on ApiException {
      final old = _cache.any(key);
      if (old != null) return Fetched(old, stale: true);
      rethrow;
    }
  }

  Future<dynamic> _fetch(Uri uri, {required bool waitOnBurst}) async {
    for (var attempt = 0;; attempt++) {
      final res = await _send(uri);
      switch (res.statusCode) {
        case 200:
          try {
            return jsonDecode(res.body);
          } on FormatException {
            throw ApiException('upstream_error', "Couldn't load data");
          }
        case 404:
          throw ApiException('not_found', 'Coin not found');
        case 429:
          final retry = int.tryParse(res.headers['retry-after'] ?? '') ?? 30;
          // Short burst limits clear within seconds, so wait once instead of failing.
          if (waitOnBurst && attempt == 0 && retry <= 5) {
            await Future<void>.delayed(Duration(seconds: retry));
            continue;
          }
          throw ApiException('rate_limited', "Couldn't load data", retryAfter: retry);
        default:
          throw ApiException('upstream_error', "Couldn't load data");
      }
    }
  }

  Future<http.Response> _send(Uri uri) async {
    try {
      return await _client.get(uri, headers: {
        'Accept': 'application/json',
        if (apiKey.isNotEmpty && uri.toString().startsWith(baseUrl)) 'x-cg-demo-api-key': apiKey,
      }).timeout(const Duration(seconds: 15));
    } on Exception {
      throw ApiException('network', 'Check your connection and try again');
    }
  }
}
