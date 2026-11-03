import 'dart:math';

import 'package:coinlens/data/api/api_client.dart';
import 'package:coinlens/models/chart_point.dart';
import 'package:coinlens/models/coin_detail.dart';
import 'package:coinlens/models/coin_market.dart';
import 'package:coinlens/models/global_stats.dart';

/// Offline sample data, used with --dart-define=MOCK=true and in tests.
/// The numbers are illustrative, not live prices.
class MockApiClient implements ApiClient {
  MockApiClient({this.latency = const Duration(milliseconds: 400)});

  /// Pause before each answer, so loading states are visible like on a real network.
  final Duration latency;

  @override
  Future<Fetched<List<CoinMarket>>> markets({int perPage = 250, String category = ''}) async {
    await Future<void>.delayed(latency);
    final list = [
      for (final c in _ranked)
        if (category.isEmpty || c.categories.contains(category)) CoinMarket.fromJson(_json(c)),
    ];
    return Fetched(list.take(perPage).toList());
  }

  @override
  Future<Fetched<CoinDetail>> coin(String id) async {
    await Future<void>.delayed(latency);
    final c = _find(id);
    return Fetched(CoinDetail.fromJson({..._json(c), 'description': c.about}));
  }

  @override
  Future<Fetched<List<ChartPoint>>> chart(String id, int days, {String symbol = ''}) async {
    await Future<void>.delayed(latency);
    return Fetched(_walk(_find(id), days));
  }

  @override
  Future<Fetched<GlobalStats>> global() async {
    await Future<void>.delayed(latency);
    final total = _coins.fold<double>(0, (s, c) => s + c.marketCap) / 0.93;
    return Fetched(GlobalStats.fromJson({
      'totalMarketCap': total,
      'totalVolume': _coins.fold<double>(0, (s, c) => s + c.volume) / 0.9,
      'btcDominance': _find('bitcoin').marketCap / total * 100,
      'ethDominance': _find('ethereum').marketCap / total * 100,
      'activeCoins': 17642,
      'markets': 1318,
    }));
  }

  // ---- Helpers

  static _Coin _find(String id) {
    for (final c in _coins) {
      if (c.id == id) return c;
    }
    throw ApiException('not_found', 'Coin not found');
  }

  /// Coins sorted by market cap, which is also their rank.
  static final _ranked = [..._coins]..sort((a, b) => b.marketCap.compareTo(a.marketCap));

  static Map<String, dynamic> _json(_Coin c) {
    final rank = _ranked.indexOf(c) + 1;
    final swing = (c.change24h.abs() / 100 + 0.01) * c.price;
    return {
      'id': c.id,
      'symbol': c.symbol,
      'name': c.name,
      'image': '',
      'rank': rank,
      'price': c.price,
      'change24h': c.change24h,
      'marketCap': c.marketCap,
      'volume24h': c.volume,
      'high24h': c.price + swing / 2,
      'low24h': c.price - swing / 2,
      'circulatingSupply': c.circulating,
      'totalSupply': c.totalSupply,
      'maxSupply': c.maxSupply,
      'ath': c.ath,
      'athChangePct': (c.price / c.ath - 1) * 100,
      'athDate': c.athDate,
      'atl': c.atl,
      'atlDate': c.atlDate,
      'lastUpdated': DateTime.now().toUtc().toIso8601String(),
    };
  }

  /// A random walk that ends at today's price. Seeded by coin and range, so the
  /// same chart appears every time it is opened.
  static List<ChartPoint> _walk(_Coin c, int days) {
    final (count, step, sigma) = switch (days) {
      1 => (288, const Duration(minutes: 5), 0.003),
      7 => (168, const Duration(hours: 1), 0.008),
      30 => (180, const Duration(hours: 4), 0.015),
      _ => (days, const Duration(days: 1), 0.03),
    };
    final stable = c.categories.contains('stablecoins');
    final seed = '${c.id}$days'.codeUnits.fold<int>(17, (a, b) => a * 31 + b) & 0x7fffffff;
    final rnd = Random(seed);
    final prices = List<double>.filled(count, c.price);
    for (var i = count - 2; i >= 0; i--) {
      final move = (rnd.nextDouble() - 0.5) * 2 * (stable ? 0.0005 : sigma);
      prices[i] = stable ? 1 + (prices[i + 1] - 1) * 0.6 + move : prices[i + 1] * (1 + move);
    }
    final now = DateTime.now();
    return [
      for (var i = 0; i < count; i++)
        ChartPoint.fromJson({
          'timestamp': now.subtract(step * (count - 1 - i)).millisecondsSinceEpoch,
          'price': prices[i],
        }),
    ];
  }
}

class _Coin {
  const _Coin(
    this.id,
    this.symbol,
    this.name, {
    required this.price,
    required this.change24h,
    required this.marketCap,
    required this.volume,
    required this.circulating,
    this.totalSupply,
    this.maxSupply,
    required this.ath,
    required this.athDate,
    required this.atl,
    required this.atlDate,
    required this.categories,
    required this.about,
  });

  final String id;
  final String symbol;
  final String name;
  final double price;
  final double change24h;
  final double marketCap;
  final double volume;
  final double circulating;
  final double? totalSupply;
  final double? maxSupply;
  final double ath;
  final String athDate;
  final double atl;
  final String atlDate;

  /// CoinGecko category slugs, the same ones the Market filter uses.
  final List<String> categories;
  final String about;
}

const _coins = [
  _Coin('bitcoin', 'BTC', 'Bitcoin',
      price: 77317, change24h: -0.8, marketCap: 1.54e12, volume: 3.8e10,
      circulating: 19.95e6, totalSupply: 19.95e6, maxSupply: 21e6,
      ath: 126080, athDate: '2025-10-06', atl: 67.81, atlDate: '2013-07-06',
      categories: ['layer-1'],
      about: 'Bitcoin is the first decentralised cryptocurrency, launched in 2009 by the '
          'pseudonymous Satoshi Nakamoto. New coins are created by proof-of-work mining, '
          'and the supply is capped at 21 million.'),
  _Coin('ethereum', 'ETH', 'Ethereum',
      price: 2235.5, change24h: 1.6, marketCap: 2.70e11, volume: 1.6e10,
      circulating: 120.7e6, totalSupply: 120.7e6,
      ath: 4946, athDate: '2025-08-24', atl: 0.432979, atlDate: '2015-10-20',
      categories: ['layer-1', 'decentralized-finance-defi'],
      about: 'Ethereum is a programmable blockchain that runs smart contracts. Most DeFi, '
          'NFT and stablecoin activity happens on it or on networks built on top of it.'),
  _Coin('tether', 'USDT', 'Tether',
      price: 1.0, change24h: 0.01, marketCap: 1.83e11, volume: 6.5e10,
      circulating: 183e9, totalSupply: 183e9,
      ath: 1.32, athDate: '2018-07-24', atl: 0.572521, atlDate: '2015-03-02',
      categories: ['stablecoins'],
      about: 'Tether is a stablecoin designed to stay at one US dollar, backed by reserves '
          'held by its issuer. It is the most traded asset in crypto.'),
  _Coin('ripple', 'XRP', 'XRP',
      price: 2.05, change24h: -2.1, marketCap: 1.23e11, volume: 3.1e9,
      circulating: 60e9, totalSupply: 99.98e9, maxSupply: 100e9,
      ath: 3.65, athDate: '2025-07-18', atl: 0.00268621, atlDate: '2014-05-22',
      categories: ['layer-1'],
      about: 'XRP is the native asset of the XRP Ledger, built for fast and cheap '
          'cross-border payments.'),
  _Coin('binancecoin', 'BNB', 'BNB',
      price: 845, change24h: 0.9, marketCap: 1.18e11, volume: 1.9e9,
      circulating: 139.2e6, totalSupply: 139.2e6, maxSupply: 200e6,
      ath: 1370, athDate: '2025-10-13', atl: 0.0398177, atlDate: '2017-10-19',
      categories: ['layer-1'],
      about: 'BNB powers the BNB Chain and pays for fees on the Binance exchange. Part of '
          'the supply is burned every quarter.'),
  _Coin('solana', 'SOL', 'Solana',
      price: 142.3, change24h: 3.4, marketCap: 7.8e10, volume: 4.2e9,
      circulating: 548e6, totalSupply: 610e6,
      ath: 293.31, athDate: '2025-01-19', atl: 0.500801, atlDate: '2020-05-11',
      categories: ['layer-1'],
      about: 'Solana is a high-throughput blockchain known for low fees and fast blocks, '
          'popular for trading and consumer apps.'),
  _Coin('usd-coin', 'USDC', 'USDC',
      price: 1.0, change24h: 0.0, marketCap: 7.6e10, volume: 8.1e9,
      circulating: 76e9, totalSupply: 76e9,
      ath: 1.17, athDate: '2019-05-08', atl: 0.877647, atlDate: '2023-03-11',
      categories: ['stablecoins'],
      about: 'USDC is a dollar stablecoin issued by Circle and backed by cash and short-term '
          'US government bonds.'),
  _Coin('dogecoin', 'DOGE', 'Dogecoin',
      price: 0.1462, change24h: 5.8, marketCap: 2.2e10, volume: 1.4e9,
      circulating: 150e9,
      ath: 0.731578, athDate: '2021-05-08', atl: 0.0000869, atlDate: '2015-05-06',
      categories: ['meme-token'],
      about: 'Dogecoin started in 2013 as a joke based on the Shiba Inu "doge" meme and '
          'became one of the best-known coins. It has no supply cap.'),
  _Coin('cardano', 'ADA', 'Cardano',
      price: 0.5214, change24h: -1.3, marketCap: 1.88e10, volume: 6.2e8,
      circulating: 36.1e9, totalSupply: 45e9, maxSupply: 45e9,
      ath: 3.09, athDate: '2021-09-02', atl: 0.01925275, atlDate: '2020-03-13',
      categories: ['layer-1'],
      about: 'Cardano is a proof-of-stake blockchain developed with a research-first '
          'approach and peer-reviewed protocol design.'),
  _Coin('chainlink', 'LINK', 'Chainlink',
      price: 13.4, change24h: 2.2, marketCap: 9.1e9, volume: 4.8e8,
      circulating: 678e6, totalSupply: 1e9, maxSupply: 1e9,
      ath: 52.7, athDate: '2021-05-10', atl: 0.148183, atlDate: '2017-11-29',
      categories: ['decentralized-finance-defi'],
      about: 'Chainlink is an oracle network that brings off-chain data, such as prices, '
          'to smart contracts.'),
  _Coin('shiba-inu', 'SHIB', 'Shiba Inu',
      price: 0.00001125, change24h: -4.6, marketCap: 6.6e9, volume: 2.1e8,
      circulating: 589e12, totalSupply: 589e12,
      ath: 0.00008616, athDate: '2021-10-28', atl: 0.000000000056366, atlDate: '2020-11-28',
      categories: ['meme-token'],
      about: 'Shiba Inu is a meme token on Ethereum that grew a large community and its own '
          'ecosystem of apps.'),
  _Coin('dai', 'DAI', 'Dai',
      price: 1.0, change24h: -0.02, marketCap: 5.3e9, volume: 1.9e8,
      circulating: 5.3e9, totalSupply: 5.3e9,
      ath: 1.22, athDate: '2020-03-13', atl: 0.88196, atlDate: '2023-03-11',
      categories: ['stablecoins', 'decentralized-finance-defi'],
      about: 'Dai is a decentralised dollar stablecoin created by locking crypto collateral '
          'in smart contracts.'),
  _Coin('uniswap', 'UNI', 'Uniswap',
      price: 6.12, change24h: -3.9, marketCap: 3.8e9, volume: 1.6e8,
      circulating: 620e6, totalSupply: 1e9, maxSupply: 1e9,
      ath: 44.92, athDate: '2021-05-03', atl: 1.03, atlDate: '2020-09-17',
      categories: ['decentralized-finance-defi'],
      about: 'UNI is the governance token of Uniswap, the largest decentralised exchange, '
          'where tokens are swapped against liquidity pools.'),
  _Coin('pepe', 'PEPE', 'Pepe',
      price: 0.00000785, change24h: 8.9, marketCap: 3.3e9, volume: 6.4e8,
      circulating: 420.69e12, totalSupply: 420.69e12, maxSupply: 420.69e12,
      ath: 0.00002803, athDate: '2024-12-09', atl: 0.000000055142, atlDate: '2023-04-18',
      categories: ['meme-token'],
      about: 'Pepe is a meme token named after the Pepe the Frog meme, launched in 2023 with '
          'no team allocation.'),
  _Coin('bittensor', 'TAO', 'Bittensor',
      price: 312, change24h: 2.9, marketCap: 2.9e9, volume: 1.2e8,
      circulating: 9.3e6, totalSupply: 9.3e6, maxSupply: 21e6,
      ath: 757.6, athDate: '2024-03-07', atl: 30.83, atlDate: '2023-05-14',
      categories: ['artificial-intelligence'],
      about: 'Bittensor is a network where machine learning models compete and are rewarded '
          'in TAO for useful output.'),
  _Coin('aave', 'AAVE', 'Aave',
      price: 182.5, change24h: 4.1, marketCap: 2.78e9, volume: 2.4e8,
      circulating: 15.2e6, totalSupply: 16e6, maxSupply: 16e6,
      ath: 661.69, athDate: '2021-05-18', atl: 26.02, atlDate: '2020-11-05',
      categories: ['decentralized-finance-defi'],
      about: 'Aave is a lending protocol where users deposit crypto to earn interest or '
          'borrow against their deposits.'),
  _Coin('render-token', 'RENDER', 'Render',
      price: 3.42, change24h: 6.3, marketCap: 1.77e9, volume: 9.5e7,
      circulating: 518e6, totalSupply: 532e6, maxSupply: 644e6,
      ath: 13.53, athDate: '2024-03-17', atl: 0.03665669, atlDate: '2020-06-16',
      categories: ['artificial-intelligence'],
      about: 'Render connects people who need GPU power for 3D rendering and AI work with '
          'people who have idle GPUs.'),
  _Coin('fetch-ai', 'FET', 'Artificial Superintelligence Alliance',
      price: 0.62, change24h: -5.2, marketCap: 1.5e9, volume: 1.1e8,
      circulating: 2.4e9, totalSupply: 2.7e9, maxSupply: 2.71e9,
      ath: 3.45, athDate: '2024-03-28', atl: 0.00816959, atlDate: '2020-03-13',
      categories: ['artificial-intelligence'],
      about: 'FET is the token of an alliance of AI projects building tools for autonomous '
          'software agents.'),
];
