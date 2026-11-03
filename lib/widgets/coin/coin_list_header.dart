import 'package:flutter/material.dart';

import 'package:coinlens/core/theme.dart';

/// Column labels that line up with CoinTile.
class CoinListHeader extends StatelessWidget {
  const CoinListHeader({super.key, this.showRank = true});

  final bool showRank;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(color: mutedText(context), fontSize: 12);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          if (showRank) SizedBox(width: 24, child: Text('#', style: style)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 42),
              child: Text('Coin', style: style),
            ),
          ),
          SizedBox(
            width: 104,
            child: Text('Price\nMarket cap', textAlign: TextAlign.right, style: style),
          ),
          SizedBox(
            width: 78,
            child: Text('24h %', textAlign: TextAlign.center, style: style),
          ),
        ],
      ),
    );
  }
}
