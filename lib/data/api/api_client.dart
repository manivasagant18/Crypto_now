import 'package:coinlens/models/chart_point.dart';
import 'package:coinlens/models/coin_detail.dart';
import 'package:coinlens/models/coin_market.dart';
import 'package:coinlens/models/global_stats.dart';

class ApiException implements Exception {
  ApiException(this.code, this.message, {this.retryAfter});

  /// network, not_found, rate_limited or upstream_error.
  final String code;
  final String message;
  final int? retryAfter;

  bool get isRateLimited => code == 'rate_limited';

  @override
  String toString() => message;
}

/// Data plus a flag meaning "a refresh failed, this is an older cached copy".
class Fetched<T> {
  const Fetched(this.data, {this.stale = false});

  final T data;
  final bool stale;
}

/// Everything the screens need from a market data source.
/// CoinGeckoClient reads it from the network; MockApiClient returns sample data.
abstract class ApiClient {
  Future<Fetched<List<CoinMarket>>> markets({int perPage = 250, String category = ''});

  Future<Fetched<CoinDetail>> coin(String id);

  /// [symbol] lets a source draw the chart from another provider when its main one is busy.
  Future<Fetched<List<ChartPoint>>> chart(String id, int days, {String symbol = ''});

  Future<Fetched<GlobalStats>> global();
}
