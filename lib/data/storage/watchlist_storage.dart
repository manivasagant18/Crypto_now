import 'package:shared_preferences/shared_preferences.dart';

/// Saves the ordered list of watched coin ids on the device.
class WatchlistStorage {
  static const _key = 'watchlist';

  Future<List<String>> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> write(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, ids);
  }
}
