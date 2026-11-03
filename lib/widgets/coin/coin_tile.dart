import 'package:flutter/material.dart';

import 'package:coinlens/core/format.dart';
import 'package:coinlens/core/theme.dart';
import 'package:coinlens/models/coin_market.dart';
import 'package:coinlens/widgets/coin/coin_icon.dart';
import 'package:coinlens/widgets/common/change_chip.dart';

/// One row: rank, icon, name and symbol, price, market cap, 24h change.
class CoinTile extends StatelessWidget {
  const CoinTile({
    super.key,
    required this.coin,
    this.showRank = true,
    this.watched = false,
    this.onTap,
    this.leading,
    this.trailing,
  });

  final CoinMarket coin;
  final bool showRank;
  final bool watched;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final muted = mutedText(context);
    final strong = strongText(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 4)],
            if (showRank)
              SizedBox(
                width: 24,
                child: Text('${coin.rank}', style: TextStyle(color: muted, fontSize: 13)),
              ),
            CoinIcon(symbol: coin.symbol, imageUrl: coin.image),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      coin.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: strong, fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(coin.symbol, style: TextStyle(color: muted, fontSize: 12)),
                  if (watched) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.star, size: 13, color: kAccent),
                  ],
                ],
              ),
            ),
            SizedBox(
              width: 104,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatPrice(coin.price),
                    style: TextStyle(
                      color: strong,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFeatures: kTabular,
                    ),
                  ),
                  Text(
                    compactUsd(coin.marketCap),
                    style: TextStyle(color: muted, fontSize: 12, fontFeatures: kTabular),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 68,
              child: Align(
                alignment: Alignment.centerRight,
                child: ChangeChip(change: coin.change24h, compact: true),
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 4), trailing!],
          ],
        ),
      ),
    );
  }
}
