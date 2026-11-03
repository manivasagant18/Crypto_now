/// In-memory cache where every entry expires after its own time-to-live.
/// Expired entries are kept, so a caller can fall back to them when a refresh fails.
class TtlCache<T> {
  TtlCache({DateTime Function()? clock}) : _now = clock ?? DateTime.now;

  final DateTime Function() _now;
  final _entries = <String, _Entry<T>>{};

  /// The value for [key] if it has not expired yet, otherwise null.
  T? fresh(String key) {
    final e = _entries[key];
    return e != null && _now().isBefore(e.expires) ? e.value : null;
  }

  /// The value for [key] even if it has expired, or null if there never was one.
  T? any(String key) => _entries[key]?.value;

  void put(String key, T value, Duration ttl) {
    _entries[key] = _Entry(value, _now().add(ttl));
  }
}

class _Entry<T> {
  _Entry(this.value, this.expires);

  final T value;
  final DateTime expires;
}
