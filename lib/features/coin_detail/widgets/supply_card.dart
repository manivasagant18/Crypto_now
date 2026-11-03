import 'package:flutter/material.dart';

import 'package:coinlens/core/format.dart';
import 'package:coinlens/core/theme.dart';
import 'package:coinlens/models/coin_market.dart';
import 'package:coinlens/widgets/common/surface_card.dart';

/// Circulating vs maximum supply, with a progress bar when there is a cap.
class SupplyCard extends StatelessWidget {
  const SupplyCard({super.key, required this.coin});

  final CoinMarket coin;

  /// Share of the maximum supply already in circulation, from 0 to 1.
  double get _minedFraction {
    final cap = coin.maxSupply;
    if (cap == null || cap <= 0) return 0;
    return (coin.circulatingSupply / cap).clamp(0.0, 1.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final muted = mutedText(context);
    final strong = strongText(context);
    final hasCap = coin.maxSupply != null && coin.maxSupply! > 0;
    final mined = _minedFraction;

    Widget labelled(String label, num value) => Text.rich(
          TextSpan(
            style: TextStyle(color: muted, fontSize: 13),
            children: [
              TextSpan(text: '$label '),
              TextSpan(
                text: formatSupply(value, coin.symbol),
                style: TextStyle(color: strong, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Supply', style: TextStyle(color: strong, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              labelled('Circulating', coin.circulatingSupply),
              if (hasCap) labelled('Max', coin.maxSupply!),
            ],
          ),
          if (hasCap) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: mined,
                minHeight: 8,
                backgroundColor: neutralChipColor(context),
                color: kAccent,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(mined * 100).round()}% of max supply mined',
              style: TextStyle(color: muted, fontSize: 13),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text('No maximum supply cap', style: TextStyle(color: muted, fontSize: 13)),
          ],
        ],
      ),
    );
  }
}
