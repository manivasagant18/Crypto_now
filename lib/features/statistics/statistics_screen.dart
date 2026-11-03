import 'package:flutter/material.dart';

import 'package:coinlens/core/format.dart';
import 'package:coinlens/core/theme.dart';
import 'package:coinlens/data/api/api_client.dart';
import 'package:coinlens/features/statistics/movers_page.dart';
import 'package:coinlens/features/statistics/widgets/dominance_donut.dart';
import 'package:coinlens/features/statistics/widgets/movers_card.dart';
import 'package:coinlens/models/coin_market.dart';
import 'package:coinlens/models/global_stats.dart';
import 'package:coinlens/widgets/common/stat_card.dart';
import 'package:coinlens/widgets/common/surface_card.dart';
import 'package:coinlens/widgets/feedback/attribution_footer.dart';
import 'package:coinlens/widgets/feedback/error_state.dart';

/// Whole-market numbers, BTC/ETH dominance, and the day's top gainers and losers.
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key, required this.api});

  final ApiClient api;

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  GlobalStats? _global;
  List<CoinMarket> _coins = [];
  bool _loading = true;
  ApiException? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait<Object>([widget.api.global(), widget.api.markets()]);
      final g = results[0] as Fetched<GlobalStats>;
      final m = results[1] as Fetched<List<CoinMarket>>;
      if (!mounted) return;
      setState(() {
        _global = g.data;
        _coins = m.data;
        _error = null;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _retry() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    await _load();
  }

  List<CoinMarket> get _gainers =>
      _coins.where((c) => c.change24h > 0).toList()..sort((a, b) => b.change24h.compareTo(a.change24h));

  List<CoinMarket> get _losers =>
      _coins.where((c) => c.change24h < 0).toList()..sort((a, b) => a.change24h.compareTo(b.change24h));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global market', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22)),
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null || _global == null) {
      return ErrorState(
        title: "Couldn't load statistics",
        message: _error?.message ?? 'Check your connection and try again',
        onRetry: _retry,
      );
    }
    final g = _global!;
    final others = (100 - g.btcDominance - g.ethDominance).clamp(0.0, 100.0).toDouble();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.2,
            children: [
              StatCard(label: 'Total market cap', value: compactUsd(g.totalMarketCap), sub: 'All cryptocurrencies'),
              StatCard(label: '24h volume', value: compactUsd(g.totalVolume), sub: 'Spot, all exchanges'),
              StatCard(label: 'Active coins', value: formatInt(g.activeCoins), sub: 'Tracked cryptocurrencies'),
              StatCard(label: 'Markets', value: formatInt(g.markets), sub: 'Exchanges tracked'),
            ],
          ),
          const SizedBox(height: 16),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Market dominance',
                  style: TextStyle(color: strongText(context), fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    DominanceDonut(btc: g.btcDominance, eth: g.ethDominance, others: others),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        children: [
                          DominanceLegendRow(color: kAccent, label: 'Bitcoin', pct: g.btcDominance),
                          DominanceLegendRow(color: kEthBlue, label: 'Ethereum', pct: g.ethDominance),
                          DominanceLegendRow(color: kOthersGrey, label: 'Others', pct: others),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _sectionHeader(context, 'Top gainers', () => _openMovers('Top gainers', _gainers)),
          MoversCard(coins: _gainers.take(3).toList(), emptyText: 'No gainers right now'),
          const SizedBox(height: 20),
          _sectionHeader(context, 'Top losers', () => _openMovers('Top losers', _losers)),
          MoversCard(coins: _losers.take(3).toList(), emptyText: 'No losers right now'),
          const SizedBox(height: 20),
          const AttributionFooter(),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title, VoidCallback onSeeAll) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(color: strongText(context), fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        TextButton(onPressed: onSeeAll, child: const Text('See all')),
      ],
    );
  }

  void _openMovers(String title, List<CoinMarket> coins) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MoversPage(title: title, coins: coins)),
    );
  }
}
