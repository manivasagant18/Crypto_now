import 'package:flutter/material.dart';

import 'package:coinlens/core/format.dart';
import 'package:coinlens/core/theme.dart';
import 'package:coinlens/models/coin_market.dart';
import 'package:coinlens/widgets/coin/coin_icon.dart';
import 'package:coinlens/widgets/common/change_chip.dart';
import 'package:coinlens/widgets/common/surface_card.dart';

/// Card with the top few gainers or losers.
class MoversCard extends StatelessWidget {
  const MoversCard({super.key, required this.coins, required this.emptyText});

  final List<CoinMarket> coins;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    if (coins.isEmpty) {
      return SurfaceCard(child: Text(emptyText, style: TextStyle(color: mutedText(context))));
    }
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        children: [
          for (var i = 0; i < coins.length; i++) ...[
            MoverRow(coin: coins[i]),
            if (i < coins.length - 1) Divider(height: 1, color: dividerColor(context)),
          ],
        ],
      ),
    );
  }
}

/// Coin icon, name and symbol, price, and 24h change for the gainers and losers lists.
class MoverRow extends StatelessWidget {
  const MoverRow({super.key, required this.coin});

  final CoinMarket coin;

  @override
  Widget build(BuildContext context) {
    final muted = mutedText(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CoinIcon(symbol: coin.symbol, imageUrl: coin.image, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    coin.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: strongText(context), fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 6),
                Text(coin.symbol, style: TextStyle(color: muted, fontSize: 12)),
              ],
            ),
          ),
          Text(
            formatPrice(coin.price),
            style: TextStyle(color: muted, fontSize: 14, fontFeatures: kTabular),
          ),
          const SizedBox(width: 12),
          ChangeChip(change: coin.change24h, compact: true),
        ],
      ),
    );
  }
}
