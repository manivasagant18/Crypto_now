// Turns raw snake_case CoinGecko (and Binance) JSON into the app's camelCase
// keys, the shape the models' fromJson constructors read.

final _htmlTag = RegExp(r'<[^>]*>');

/// One row of /coins/markets.
Map<String, dynamic> mapMarket(Map<String, dynamic> m) => {
      'id': m['id'],
      'symbol': (m['symbol'] as String? ?? '').toUpperCase(),
      'name': m['name'],
      'image': m['image'],
      'rank': m['market_cap_rank'],
      'price': m['current_price'],
      'change24h': m['price_change_percentage_24h'],
      'marketCap': m['market_cap'],
      'volume24h': m['total_volume'],
      'high24h': m['high_24h'],
      'low24h': m['low_24h'],
      'circulatingSupply': m['circulating_supply'],
      'totalSupply': m['total_supply'],
      'maxSupply': m['max_supply'],
      'ath': m['ath'],
      'athChangePct': m['ath_change_percentage'],
      'athDate': _dateOnly(m['ath_date']),
      'atl': m['atl'],
      'atlDate': _dateOnly(m['atl_date']),
      'lastUpdated': m['last_updated'],
    };

/// /coins/{id}. Market numbers sit under market_data, one value per currency.
Map<String, dynamic> mapCoinDetail(Map<String, dynamic> c) {
  final md = c['market_data'] as Map<String, dynamic>? ?? const {};
  Object? usd(String key) => (md[key] as Map<String, dynamic>?)?['usd'];
  return {
    'id': c['id'],
    'symbol': (c['symbol'] as String? ?? '').toUpperCase(),
    'name': c['name'],
    'image': (c['image'] as Map<String, dynamic>?)?['large'],
    'rank': c['market_cap_rank'],
    'price': usd('current_price'),
    'change24h': md['price_change_percentage_24h'],
    'marketCap': usd('market_cap'),
    'volume24h': usd('total_volume'),
    'high24h': usd('high_24h'),
    'low24h': usd('low_24h'),
    'circulatingSupply': md['circulating_supply'],
    'totalSupply': md['total_supply'],
    'maxSupply': md['max_supply'],
    'ath': usd('ath'),
    'athChangePct': usd('ath_change_percentage'),
    'athDate': _dateOnly(usd('ath_date')),
    'atl': usd('atl'),
    'atlDate': _dateOnly(usd('atl_date')),
    'lastUpdated': md['last_updated'],
    'description': ((c['description'] as Map<String, dynamic>?)?['en'] as String? ?? '')
        .replaceAll(_htmlTag, '')
        .trim(),
  };
}

/// /coins/{id}/market_chart: a list of [timestamp, price] pairs.
List<Map<String, dynamic>> mapMarketChart(Map<String, dynamic> raw) {
  final prices = raw['prices'] as List? ?? const [];
  return [
    for (final p in prices)
      if (p is List && p.length >= 2) {'timestamp': p[0], 'price': p[1]},
  ];
}

/// Binance /klines candles, keeping the close price. [invert] turns a
/// USDC/USDT price into a USDT/USD one.
List<Map<String, dynamic>> mapBinanceKlines(List raw, {bool invert = false}) {
  final points = <Map<String, dynamic>>[];
  for (final k in raw) {
    if (k is! List || k.length < 5) continue;
    final close = double.tryParse('${k[4]}') ?? 0;
    if (close <= 0) continue;
    points.add({'timestamp': k[0], 'price': invert ? 1 / close : close});
  }
  return points;
}

/// /global. Everything sits under data, with values per currency or per coin.
Map<String, dynamic> mapGlobal(Map<String, dynamic> raw) {
  final d = raw['data'] as Map<String, dynamic>? ?? const {};
  Object? pick(String key, String sub) => (d[key] as Map<String, dynamic>?)?[sub];
  return {
    'totalMarketCap': pick('total_market_cap', 'usd'),
    'totalVolume': pick('total_volume', 'usd'),
    'btcDominance': pick('market_cap_percentage', 'btc'),
    'ethDominance': pick('market_cap_percentage', 'eth'),
    'activeCoins': d['active_cryptocurrencies'],
    'markets': d['markets'],
  };
}

String _dateOnly(Object? v) {
  final s = v as String? ?? '';
  return s.length >= 10 ? s.substring(0, 10) : s;
}
