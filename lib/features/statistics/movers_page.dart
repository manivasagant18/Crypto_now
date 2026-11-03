import 'package:flutter/material.dart';

import 'package:coinlens/core/theme.dart';
import 'package:coinlens/features/statistics/widgets/movers_card.dart';
import 'package:coinlens/models/coin_market.dart';

/// Full list of gainers or losers, opened from "See all".
class MoversPage extends StatelessWidget {
  const MoversPage({super.key, required this.title, required this.coins});

  final String title;
  final List<CoinMarket> coins;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: coins.isEmpty
          ? const Center(child: Text('No coins to show'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: coins.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: dividerColor(context)),
              itemBuilder: (context, i) => MoverRow(coin: coins[i]),
            ),
    );
  }
}
