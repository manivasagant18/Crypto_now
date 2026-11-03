import 'package:flutter/material.dart';

import 'package:coinlens/core/format.dart';
import 'package:coinlens/core/theme.dart';
import 'package:coinlens/models/coin_market.dart';
import 'package:coinlens/widgets/common/change_chip.dart';

/// "Bitcoin price · BTC", the big price with its 24h change, and when it was updated.
class PriceHeader extends StatelessWidget {
  const PriceHeader({super.key, required this.coin});

  final CoinMarket coin;

  @override
  Widget build(BuildContext context) {
    final muted = mutedText(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${coin.name} price · ${coin.symbol}', style: TextStyle(color: muted, fontSize: 14)),
        const SizedBox(height: 6),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 4,
          children: [
            Text(
              formatPrice(coin.price),
              style: TextStyle(
                color: strongText(context),
                fontSize: 28,
                fontWeight: FontWeight.w700,
                fontFeatures: kTabular,
              ),
            ),
            ChangeChip(change: coin.change24h),
            Text('24h', style: TextStyle(color: muted, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 4),
        Text('Last updated ${timeAgo(coin.lastUpdated)}', style: TextStyle(color: muted, fontSize: 12)),
      ],
    );
  }
}
