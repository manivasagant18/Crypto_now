import 'dart:async';

import 'package:flutter/material.dart';

import 'package:coinlens/core/theme.dart';
import 'package:coinlens/data/api/api_client.dart';
import 'package:coinlens/features/coin_detail/coin_detail_screen.dart';
import 'package:coinlens/features/market/filter_sheet.dart';
import 'package:coinlens/features/market/market_filters.dart';
import 'package:coinlens/models/coin_market.dart';
import 'package:coinlens/state/watchlist_notifier.dart';
import 'package:coinlens/widgets/coin/coin_list_header.dart';
import 'package:coinlens/widgets/coin/coin_tile.dart';
import 'package:coinlens/widgets/common/app_logo.dart';
import 'package:coinlens/widgets/common/pill_chip.dart';
import 'package:coinlens/widgets/feedback/attribution_footer.dart';
import 'package:coinlens/widgets/feedback/empty_state.dart';
import 'package:coinlens/widgets/feedback/error_state.dart';
import 'package:coinlens/widgets/feedback/loading_list.dart';
import 'package:coinlens/widgets/feedback/stale_banner.dart';

/// Top coins with search, sort chips and a filter sheet. Refreshes every minute.
class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key, required this.api, required this.watchlist});

  final ApiClient api;
  final WatchlistNotifier watchlist;

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  List<CoinMarket> _coins = [];
  bool _loading = true;
  bool _stale = false;
  DateTime? _updated;
  ApiException? _error;

  Timer? _refreshTimer;

  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  String _query = '';
  SortField _sort = SortField.marketCap;
  bool _descending = true;
  MarketFilters _filters = const MarketFilters();

  @override
  void initState() {
    super.initState();
    _load();
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final r = await widget.api.markets(category: _filters.category);
      if (!mounted) return;
      setState(() {
        _coins = r.data;
        _stale = r.stale;
        _updated = r.data.isEmpty ? DateTime.now() : (r.data.first.lastUpdated ?? DateTime.now());
        _loading = false;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e;
      });
      if (_coins.isNotEmpty && !silent) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  bool _matchesQuery(CoinMarket c) {
    final q = _query.trim().toLowerCase();
    return q.isEmpty || c.name.toLowerCase().contains(q) || c.symbol.toLowerCase().contains(q);
  }

  List<CoinMarket> get _visible {
    final list = _coins.where((c) => _matchesQuery(c) && _filters.matches(c)).toList();
    list.sort((a, b) => _descending ? compareCoins(_sort, b, a) : compareCoins(_sort, a, b));
    return list;
  }

  void _selectSort(SortField f) {
    setState(() {
      if (_sort == f) {
        _descending = !_descending;
      } else {
        _sort = f;
        _descending = f != SortField.name;
      }
    });
  }

  String _sortLabel(SortField f) {
    final base = kSortLabels[f]!;
    if (f != _sort) return base;
    return '$base ${_descending ? '↓' : '↑'}';
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() => _query = '');
  }

  void _clearFilters() {
    final hadCategory = _filters.category.isNotEmpty;
    setState(() => _filters = const MarketFilters());
    if (hadCategory) _load();
  }

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<MarketFilters>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => FilterSheet(
        initial: _filters,
        countFor: (f) => _coins.where((c) => f.matches(c) && _matchesQuery(c)).length,
      ),
    );
    if (result == null || !mounted) return;
    final categoryChanged = result.category != _filters.category;
    setState(() => _filters = result);
    if (categoryChanged) _load();
  }

  void _openDetail(CoinMarket c) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CoinDetailScreen(api: widget.api, watchlist: widget.watchlist, coin: c),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            AppLogo(size: 30),
            SizedBox(width: 10),
            Text(
              'Crypto Now',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () => _searchFocus.requestFocus(),
          ),
          IconButton(
            tooltip: 'Filters',
            onPressed: _openFilters,
            icon: Badge(
              isLabelVisible: _filters.isActive,
              child: const Icon(Icons.tune),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _searchField(context),
          _sortChips(),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _searchField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: TextField(
        controller: _searchCtrl,
        focusNode: _searchFocus,
        onChanged: (v) => setState(() => _query = v),
        decoration: InputDecoration(
          hintText: 'Search coins',
          prefixIcon: Icon(Icons.search, color: mutedText(context)),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.cancel_outlined),
                  tooltip: 'Clear',
                  onPressed: _clearSearch,
                ),
          filled: true,
          fillColor: cardColor(context),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _sortChips() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final f in SortField.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: PillChip(
                label: _sortLabel(f),
                selected: _sort == f,
                onTap: () => _selectSort(f),
              ),
            ),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading && _coins.isEmpty) return const LoadingList();
    if (_error != null && _coins.isEmpty) {
      return ErrorState(
        title: "Couldn't load prices",
        message: 'Check your connection and try again',
        onRetry: () => _load(),
      );
    }
    if (_coins.isEmpty) {
      return const EmptyState(
        icon: Icons.inbox_outlined,
        title: 'No coins available',
        subtitle: 'Pull down to try again',
      );
    }
    final visible = _visible;
    if (visible.isEmpty) return _emptyResults();

    return ListenableBuilder(
      listenable: widget.watchlist,
      builder: (context, _) => _list(context, visible),
    );
  }

  Widget _emptyResults() {
    if (_query.trim().isNotEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: 'No coins match ‘${_query.trim()}’',
        subtitle: 'Check the spelling or search by symbol, e.g. BTC',
        actionLabel: 'Clear search',
        onAction: _clearSearch,
      );
    }
    return EmptyState(
      icon: Icons.filter_alt_off_outlined,
      title: 'No coins match your filters',
      subtitle: 'Try removing a filter or widening the market cap tier',
      actionLabel: 'Clear filters',
      onAction: _clearFilters,
    );
  }

  Widget _list(BuildContext context, List<CoinMarket> visible) {
    return RefreshIndicator(
      onRefresh: () => _load(silent: true),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: visible.length + 2,
        itemBuilder: (context, i) {
          if (i == 0) {
            return Column(
              children: [
                if (_stale) StaleBanner(updated: _updated, onRefresh: () => _load(silent: true)),
                const CoinListHeader(),
              ],
            );
          }
          if (i == visible.length + 1) {
            return const AttributionFooter();
          }
          final c = visible[i - 1];
          return Column(
            children: [
              CoinTile(
                coin: c,
                watched: widget.watchlist.contains(c.id),
                onTap: () => _openDetail(c),
              ),
              Divider(height: 1, color: dividerColor(context)),
            ],
          );
        },
      ),
    );
  }
}
