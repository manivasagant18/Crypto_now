import 'package:flutter/material.dart';

import 'package:coinlens/core/format.dart';
import 'package:coinlens/core/theme.dart';
import 'package:coinlens/models/coin_market.dart';
import 'package:coinlens/widgets/common/change_chip.dart';
import 'package:coinlens/widgets/common/surface_card.dart';

/// All-time high and low, their dates, and how far today's price is from each.
class AthAtlCard extends StatelessWidget {
  const AthAtlCard({super.key, required this.coin});

  final CoinMarket coin;

  @override
  Widget build(BuildContext context) {
    final atlPct = coin.atl > 0 ? (coin.price / coin.atl - 1) * 100 : 0.0;
    return SurfaceCard(
      child: Column(
        children: [
          _row(
            context,
            label: 'All-time high',
            value: 'ATH ${formatPrice(coin.ath)}',
            date: formatDate(coin.athDate),
            change: coin.athChangePct,
          ),
          Divider(height: 24, color: dividerColor(context)),
          _row(
            context,
            label: 'All-time low',
            value: 'ATL ${formatPrice(coin.atl)}',
            date: formatDate(coin.atlDate),
            change: atlPct,
            changeLabel: percentWhole(atlPct),
          ),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context, {
    required String label,
    required String value,
    required String date,
    required double change,
    String? changeLabel,
  }) {
    final muted = mutedText(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: muted, fontSize: 13)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: TextStyle(color: strongText(context), fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: '  ·  $date', style: TextStyle(color: muted, fontSize: 13)),
                  ],
                ),
              ),
            ),
            ChangeChip(change: change, label: changeLabel),
          ],
        ),
      ],
    );
  }
}
