import 'package:flutter/material.dart';

import 'package:coinlens/core/theme.dart';
import 'package:coinlens/data/api/api_client.dart';
import 'package:coinlens/features/coin_detail/coin_detail_screen.dart';
import 'package:coinlens/models/coin_market.dart';
import 'package:coinlens/state/watchlist_notifier.dart';
import 'package:coinlens/widgets/coin/coin_list_header.dart';
import 'package:coinlens/widgets/coin/coin_tile.dart';
import 'package:coinlens/widgets/feedback/attribution_footer.dart';
import 'package:coinlens/widgets/feedback/empty_state.dart';
import 'package:coinlens/widgets/feedback/error_state.dart';
import 'package:coinlens/widgets/feedback/loading_list.dart';
import 'package:coinlens/widgets/feedback/stale_banner.dart';

/// The user's followed coins. Drag to reorder, swipe to remove, or use Edit to remove with a button.
class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({
    super.key,
    required this.api,
    required this.watchlist,
    required this.onBrowseMarket,
  });

  final ApiClient api;
  final WatchlistNotifier watchlist;
  final VoidCallback onBrowseMarket;

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final Map<String, CoinMarket> _byId = {};
  bool _loading = true;
  bool _stale = false;
  DateTime? _updated;
  ApiException? _error;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    widget.watchlist.addListener(_onWatchlistChanged);
    _load();
  }

  @override
  void dispose() {
    widget.watchlist.removeListener(_onWatchlistChanged);
    super.dispose();
  }

  void _onWatchlistChanged() {
    if (!mounted) return;
    final missing = widget.watchlist.ids.any((id) => !_byId.containsKey(id));
    if (missing) {
      _load();
    } else {
      setState(() {});
    }
  }

  Future<CoinMarket?> _tryCoin(String id) async {
    try {
      return (await widget.api.coin(id)).data;
    } on ApiException {
      return null;
    }
  }

  Future<void> _load() async {
    final ids = widget.watchlist.ids;
    if (ids.isEmpty) {
      setState(() {
        _byId.clear();
        _loading = false;
        _error = null;
      });
      return;
    }
    setState(() {
      _loading = _byId.isEmpty;
      _error = null;
    });
    try {
      final markets = await widget.api.markets();
      final found = {for (final c in markets.data) c.id: c};
      // Coins outside the top 250 are fetched one by one.
      final missing = ids.where((id) => !found.containsKey(id)).toList();
      final extras = await Future.wait(missing.map(_tryCoin));
      for (final c in extras) {
        if (c != null) found[c.id] = c;
      }
      if (!mounted) return;
      setState(() {
        _byId
          ..clear()
          ..addAll(found);
        _loading = false;
        _stale = markets.stale;
        _updated = markets.data.isEmpty ? DateTime.now() : (markets.data.first.lastUpdated ?? DateTime.now());
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e;
      });
    }
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
    return ListenableBuilder(
      listenable: widget.watchlist,
      builder: (context, _) {
        final ids = widget.watchlist.ids;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Watchlist', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22)),
            actions: [
              if (ids.isNotEmpty)
                TextButton(
                  onPressed: () => setState(() => _editing = !_editing),
                  child: Text(_editing ? 'Done' : 'Edit'),
                ),
            ],
          ),
          body: _body(context, ids),
        );
      },
    );
  }

  Widget _body(BuildContext context, List<String> ids) {
    if (ids.isEmpty) {
      return EmptyState(
        icon: Icons.star_border,
        title: 'Your watchlist is empty',
        subtitle: 'Tap the star on any coin to follow it',
        actionLabel: 'Browse market',
        onAction: widget.onBrowseMarket,
      );
    }
    if (_loading && _byId.isEmpty) return const LoadingList(rows: 5);
    if (_error != null && _byId.isEmpty) {
      return ErrorState(
        title: "Couldn't load prices",
        message: 'Check your connection and try again',
        onRetry: _load,
      );
    }

    return Column(
      children: [
        if (_stale) StaleBanner(updated: _updated, onRefresh: _load),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cardColor(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.swap_vert, size: 16, color: mutedText(context)),
                  const SizedBox(width: 6),
                  Text(
                    'Sorted by: Custom',
                    style: TextStyle(color: mutedText(context), fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
        const CoinListHeader(showRank: false),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: ReorderableListView.builder(
              buildDefaultDragHandles: false,
              itemCount: ids.length,
              onReorder: (oldIndex, newIndex) => widget.watchlist.reorder(oldIndex, newIndex),
              itemBuilder: (context, i) => _row(context, ids[i], i),
            ),
          ),
        ),
        const AttributionFooter(),
      ],
    );
  }

  Widget _row(BuildContext context, String id, int index) {
    final coin = _byId[id];
    final muted = mutedText(context);
    final dragHandle = ReorderableDragStartListener(
      index: index,
      child: Icon(Icons.drag_handle, color: muted),
    );

    final Widget content = coin == null
        ? ListTile(
            leading: CircleAvatar(radius: 16, child: Text(id.substring(0, 1).toUpperCase())),
            title: Text(id),
            subtitle: const Text('Details unavailable right now'),
            trailing: dragHandle,
          )
        : CoinTile(
            coin: coin,
            showRank: false,
            watched: true,
            onTap: () => _openDetail(coin),
            leading: _editing
                ? IconButton(
                    tooltip: 'Remove',
                    icon: const Icon(Icons.remove_circle, color: kNegative),
                    onPressed: () => widget.watchlist.remove(id),
                  )
                : null,
            trailing: dragHandle,
          );

    return Dismissible(
      key: ValueKey(id),
      direction: _editing ? DismissDirection.none : DismissDirection.endToStart,
      background: Container(
        color: kNegative,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => widget.watchlist.remove(id),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          content,
          Divider(height: 1, color: dividerColor(context)),
        ],
      ),
    );
  }
}
