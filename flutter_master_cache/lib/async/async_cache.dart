import 'package:flutter_master_cache/util/async_base_cache.dart';

class AsyncCache<K, V> extends AsyncBaseCache<K, V>{

  final Map<K, Future<V>  Function()> _futures = {};

  final Map<K, V> _cache = {};

  @override
  void register(K k, Future<V> Function() future) {
    _futures[k] = future;
  }

  @override
  bool unregister(K k) {
    return _futures.remove(k) != null;
  }

  @override
  Future<V?> get(K k, {V? fallback}) async {
    if(exist(k)){
      return _cache[k];
    }

    if(_futures.containsKey(k)){
      final res = await _futures[k]?.call();
      _cache[k] = res as V;

      return res;
    }

    if(fallback != null){
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
    if(_cache.containsKey(k)){
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
