import 'package:flutter/material.dart';

import 'package:coinlens/data/api/api_client.dart';
import 'package:coinlens/features/market/market_screen.dart';
import 'package:coinlens/features/statistics/statistics_screen.dart';
import 'package:coinlens/features/watchlist/watchlist_screen.dart';
import 'package:coinlens/state/watchlist_notifier.dart';

/// Bottom navigation with three tabs. IndexedStack keeps each tab's state alive once opened.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.api, required this.watchlist});

  final ApiClient api;
  final WatchlistNotifier watchlist;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  /// Tabs are built the first time they are opened, so startup only builds and loads Market.
  final _opened = <int>{0};

  void _select(int i) => setState(() {
        _index = i;
        _opened.add(i);
      });

  Widget _tab(int i, Widget Function() build) => _opened.contains(i) ? build() : const SizedBox.shrink();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          _tab(0, () => MarketScreen(api: widget.api, watchlist: widget.watchlist)),
          _tab(1, () => StatisticsScreen(api: widget.api)),
          _tab(
            2,
            () => WatchlistScreen(
              api: widget.api,
              watchlist: widget.watchlist,
              onBrowseMarket: () => _select(0),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.show_chart_outlined),
            selectedIcon: Icon(Icons.show_chart),
            label: 'Market',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Statistics',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_border),
            selectedIcon: Icon(Icons.star),
            label: 'Watchlist',
          ),
        ],
      ),
    );
  }
}
