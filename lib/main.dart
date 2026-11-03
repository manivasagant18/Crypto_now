import 'package:flutter/material.dart';

import 'package:coinlens/app.dart';
import 'package:coinlens/core/config.dart';
import 'package:coinlens/data/api/api_client.dart';
import 'package:coinlens/data/api/coingecko_client.dart';
import 'package:coinlens/data/api/mock_client.dart';
import 'package:coinlens/data/storage/watchlist_storage.dart';
import 'package:coinlens/state/watchlist_notifier.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final ApiClient api = kUseMock ? MockApiClient() : CoinGeckoClient();
  final watchlist = WatchlistNotifier(WatchlistStorage())..load();
  runApp(CryptoNowApp(api: api, watchlist: watchlist));
}
