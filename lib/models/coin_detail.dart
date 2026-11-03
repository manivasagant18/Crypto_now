import 'coin_market.dart';

/// Detail view. Adds the description to the market fields.
class CoinDetail extends CoinMarket {
  CoinDetail.fromJson(super.j)
      : description = j['description'] as String? ?? '',
        super.fromJson();

  final String description;
}
