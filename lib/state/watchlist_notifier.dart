import 'package:flutter/foundation.dart';

import 'package:coinlens/data/storage/watchlist_storage.dart';

/// Shared watchlist state. Screens listen to it, and every change is saved on the device.
class WatchlistNotifier extends ChangeNotifier {
  WatchlistNotifier(this._storage);

  final WatchlistStorage _storage;
  List<String> _ids = [];

  List<String> get ids => List.unmodifiable(_ids);

  bool contains(String id) => _ids.contains(id);

  Future<void> load() async {
    _ids = await _storage.read();
    notifyListeners();
  }

  Future<void> toggle(String id) {
    final next = [..._ids];
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    return _save(next);
  }

  Future<void> remove(String id) => _save([..._ids]..remove(id));

  Future<void> reorder(int oldIndex, int newIndex) {
    final next = [..._ids];
    if (newIndex > oldIndex) newIndex -= 1;
    next.insert(newIndex, next.removeAt(oldIndex));
    return _save(next);
  }

  Future<void> _save(List<String> next) async {
    _ids = next;
    notifyListeners();
    await _storage.write(_ids);
  }
}
