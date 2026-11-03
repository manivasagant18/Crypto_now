double _d(Object? v) => (v as num?)?.toDouble() ?? 0;
double? _dn(Object? v) => (v as num?)?.toDouble();

/// One coin in the market list. Parsed from the app's camelCase JSON shape,
/// which coingecko_mapper.dart and mock_client.dart both produce.
class CoinMarket {
  CoinMarket.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        symbol = j['symbol'] as String,
        name = j['name'] as String,
        image = j['image'] as String? ?? '',
        rank = (j['rank'] as num?)?.toInt() ?? 0,
        price = _d(j['price']),
        change24h = _d(j['change24h']),
        marketCap = _d(j['marketCap']),
        volume24h = _d(j['volume24h']),
        high24h = _d(j['high24h']),
        low24h = _d(j['low24h']),
        circulatingSupply = _d(j['circulatingSupply']),
        totalSupply = _dn(j['totalSupply']),
        maxSupply = _dn(j['maxSupply']),
        ath = _d(j['ath']),
        athChangePct = _d(j['athChangePct']),
        athDate = j['athDate'] as String? ?? '',
        atl = _d(j['atl']),
        atlDate = j['atlDate'] as String? ?? '',
        lastUpdated = DateTime.tryParse(j['lastUpdated'] as String? ?? '');

  final String id;
  final String symbol;
  final String name;
  final String image;
  final int rank;
  final double price;
  final double change24h;
  final double marketCap;
  final double volume24h;
  final double high24h;
  final double low24h;
  final double circulatingSupply;
  final double? totalSupply;
  final double? maxSupply;
  final double ath;
  final double athChangePct;
  final String athDate;
  final double atl;
  final String atlDate;
  final DateTime? lastUpdated;
}
