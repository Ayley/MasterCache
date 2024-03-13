import 'package:flutter_master_cache/util/base_cache.dart';

class SyncCache<K, V> extends BaseCache<K, V> {
  final Map<K, V> _cache = {};

  @override
  V? get(K k, {V? fallback}) {
    if (exist(k)) {
      return _cache[k];
    }

    if (fallback != null) {
      return fallback;
    }

    return null;
  }

  @override
  bool set(K k, V v) {
    final result = _cache.containsKey(k);

    _cache[k] = v;

    return result;
  }

  @override
  bool add(K k, V v) {
    if (_cache.containsKey(k)) {
      return false;
    }

    _cache[k] = v;

    return true;
  }

  @override
  bool exist(K k) {
    return _cache.containsKey(k);
  }

  @override
  V? remove(K k) {
    return _cache.remove(k);
  }

  @override
  void clear() {
    _cache.clear();
  }

  @override
  void dispose() {}
}
