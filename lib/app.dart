import 'package:flutter/material.dart';

import 'package:coinlens/core/theme.dart';
import 'package:coinlens/data/api/api_client.dart';
import 'package:coinlens/features/home/home_screen.dart';
import 'package:coinlens/state/watchlist_notifier.dart';

class CryptoNowApp extends StatelessWidget {
  const CryptoNowApp({super.key, required this.api, required this.watchlist});

  final ApiClient api;
  final WatchlistNotifier watchlist;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Now',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: HomeScreen(api: api, watchlist: watchlist),
    );
  }
}
