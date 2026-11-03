import 'package:flutter/material.dart';

import 'package:coinlens/core/format.dart';
import 'package:coinlens/models/coin_market.dart';
import 'package:coinlens/widgets/common/stat_card.dart';

/// Two-column grid: market cap, volume, supplies and rank.
class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key, required this.coin});

  final CoinMarket coin;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.0,
      children: [
        StatCard(label: 'Market cap', value: compactUsd(coin.marketCap)),
        StatCard(label: '24h volume', value: compactUsd(coin.volume24h)),
        StatCard(label: 'Circulating supply', value: formatSupply(coin.circulatingSupply, coin.symbol)),
        StatCard(
          label: 'Total supply',
          value: coin.totalSupply == null ? '—' : formatSupply(coin.totalSupply!, coin.symbol),
        ),
        StatCard(
          label: 'Max supply',
          value: coin.maxSupply == null ? 'Uncapped' : formatSupply(coin.maxSupply!, coin.symbol),
        ),
        StatCard(label: 'Rank', value: '#${coin.rank}'),
      ],
    );
  }
}
