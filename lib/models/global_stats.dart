double _d(Object? v) => (v as num?)?.toDouble() ?? 0;

/// Whole-market numbers for the Statistics tab.
class GlobalStats {
  GlobalStats.fromJson(Map<String, dynamic> j)
      : totalMarketCap = _d(j['totalMarketCap']),
        totalVolume = _d(j['totalVolume']),
        btcDominance = _d(j['btcDominance']),
        ethDominance = _d(j['ethDominance']),
        activeCoins = (j['activeCoins'] as num?)?.toInt() ?? 0,
        markets = (j['markets'] as num?)?.toInt() ?? 0;

  final double totalMarketCap;
  final double totalVolume;
  final double btcDominance;
  final double ethDominance;
  final int activeCoins;
  final int markets;
}
