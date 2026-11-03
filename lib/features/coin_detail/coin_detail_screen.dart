import 'package:flutter/material.dart';

import 'package:coinlens/core/theme.dart';
import 'package:coinlens/data/api/api_client.dart';
import 'package:coinlens/features/coin_detail/widgets/about_card.dart';
import 'package:coinlens/features/coin_detail/widgets/ath_atl_card.dart';
import 'package:coinlens/features/coin_detail/widgets/price_header.dart';
import 'package:coinlens/features/coin_detail/widgets/stats_grid.dart';
import 'package:coinlens/features/coin_detail/widgets/supply_card.dart';
import 'package:coinlens/features/coin_detail/widgets/timeframe_selector.dart';
import 'package:coinlens/models/chart_point.dart';
import 'package:coinlens/models/coin_detail.dart';
import 'package:coinlens/models/coin_market.dart';
import 'package:coinlens/state/watchlist_notifier.dart';
import 'package:coinlens/widgets/charts/price_chart.dart';
import 'package:coinlens/widgets/coin/coin_icon.dart';
import 'package:coinlens/widgets/feedback/attribution_footer.dart';

/// One coin: price, chart with ranges, stats, supply, ATH/ATL and description.
/// Opens straight away with the list row's data, then fills in the rest.
class CoinDetailScreen extends StatefulWidget {
  const CoinDetailScreen({
    super.key,
    required this.api,
    required this.watchlist,
    required this.coin,
  });

  final ApiClient api;
  final WatchlistNotifier watchlist;
  final CoinMarket coin;

  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  CoinDetail? _detail;
  ApiException? _detailError;

  List<ChartPoint> _points = [];
  ApiException? _chartError;
  bool _chartLoading = true;
  int _days = 1;

  @override
  void initState() {
    super.initState();
    // The chart goes first so it gets the free API's calls before the description does.
    _loadChart().whenComplete(() {
      if (mounted) _loadDetail();
    });
  }

  Future<void> _loadDetail() async {
    try {
      final r = await widget.api.coin(widget.coin.id);
      if (!mounted) return;
      setState(() {
        _detail = r.data;
        _detailError = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _detailError = e);
    }
  }

  Future<void> _loadChart() async {
    final days = _days;
    try {
      final r = await widget.api.chart(widget.coin.id, days, symbol: widget.coin.symbol);
      if (!mounted || days != _days) return;
      setState(() {
        _points = r.data;
        _chartError = null;
        _chartLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted || days != _days) return;
      setState(() {
        _chartError = e;
        _chartLoading = false;
      });
    }
  }

  void _setRange(int days) {
    if (days == _days) return;
    setState(() {
      _days = days;
      _chartLoading = true;
      _chartError = null;
    });
    _loadChart();
  }

  void _retryChart() {
    setState(() {
      _chartLoading = true;
      _chartError = null;
    });
    _loadChart();
  }

  void _retryDetail() {
    setState(() => _detailError = null);
    _loadDetail();
  }

  @override
  Widget build(BuildContext context) {
    final coin = _detail ?? widget.coin;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CoinIcon(symbol: coin.symbol, imageUrl: coin.image, size: 26),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                coin.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ),
          ],
        ),
        actions: [
          ListenableBuilder(
            listenable: widget.watchlist,
            builder: (context, _) {
              final watched = widget.watchlist.contains(coin.id);
              return IconButton(
                tooltip: watched ? 'Remove from watchlist' : 'Add to watchlist',
                icon: Icon(watched ? Icons.star : Icons.star_border, color: watched ? kAccent : null),
                onPressed: () => widget.watchlist.toggle(coin.id),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PriceHeader(coin: coin),
          const SizedBox(height: 16),
          _chartArea(),
          const SizedBox(height: 12),
          TimeframeSelector(days: _days, onSelected: _setRange),
          const SizedBox(height: 16),
          StatsGrid(coin: coin),
          const SizedBox(height: 12),
          SupplyCard(coin: coin),
          const SizedBox(height: 12),
          AthAtlCard(coin: coin),
          const SizedBox(height: 12),
          AboutCard(
            coinName: coin.name,
            description: _detail?.description,
            failed: _detailError != null,
            onRetry: _retryDetail,
          ),
          const SizedBox(height: 16),
          const AttributionFooter(),
        ],
      ),
    );
  }

  Widget _chartArea() {
    final decoration = BoxDecoration(
      color: cardColor(context),
      borderRadius: BorderRadius.circular(12),
    );
    if (_chartLoading) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: decoration,
        child: const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (_chartError != null) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        decoration: decoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Couldn't load the chart",
              textAlign: TextAlign.center,
              style: TextStyle(color: mutedText(context)),
            ),
            TextButton(onPressed: _retryChart, child: const Text('Retry')),
          ],
        ),
      );
    }
    return PriceChart(points: _points);
  }
}
