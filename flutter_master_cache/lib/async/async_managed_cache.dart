import 'dart:async';

import 'package:flutter_master_cache/util/async_base_cache.dart';

class AsyncManagedCache<K, V> extends AsyncBaseCache<K, V> {
  AsyncManagedCache({
    this.expireDuration,
    this.onExpired,
    this.reloadDuration,
    this.onReloaded,
  });

  //Expire
  final Duration? expireDuration;
  final void Function(K k, V? v)? onExpired;

  //Reload
  final Duration? reloadDuration;
  final void Function(K k)? onReloaded;

  final Map<K, Future<V?> Function()> _futures = {};

  final Map<K, _ManagedItem<K, V>> _cache = {};

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
    if (exist(k)) {
      return _cache[k]?.value;
    }

    if (_futures.containsKey(k)) {
      final res = await _futures[k]?.call();
      _cache[k] = _ManagedItem(
        key: k,
        value: res,
        expireDuration: expireDuration,
        onExpired: _expiredItem,
        reloadDuration: reloadDuration,
        onReload: _reloadItem,
      );

      return res;
    }

    if (fallback != null) {
      return fallback;
    }

    return null;
  }

  @override
  bool set(K k, V v) {
    final result = _cache.containsKey(k);

    _cache[k] = _ManagedItem(
      key: k,
      value: v,
      expireDuration: expireDuration,
      onExpired: _expiredItem,
      reloadDuration: reloadDuration,
      onReload: _reloadItem,
    );

    return result;
  }

  @override
  bool add(K k, V v) {
    if (_cache.containsKey(k)) {
      return false;
    }

    _cache[k] = _ManagedItem(
      key: k,
      value: v,
      expireDuration: expireDuration,
      onExpired: _expiredItem,
      reloadDuration: reloadDuration,
      onReload: _reloadItem,
    );

    return true;
  }

  @override
  bool exist(K k) {
    return _cache.containsKey(k);
  }

  @override
  V? remove(K k) {
    final val = _cache[k];

    val?.dispose();

    return _cache.remove(k)?.value;
  }

  @override
  void clear() {
    _cache.clear();
  }

  @override
  void dispose() {}

  @override
  Future<V?> update(K k) async {
    if(!_futures.containsKey(k)){
      return null;
    }

    final res = await _futures[k]?.call();

    if(res != null){
      _cache[k] = _ManagedItem(
        key: k,
        value: res,
        expireDuration: expireDuration,
        onExpired: _expiredItem,
        reloadDuration: reloadDuration,
        onReload: _reloadItem,
      );

      onReloaded?.call(k);
    }

    return res;
  }

  void _expiredItem(K k, V? v) {
    remove(k);

    onExpired?.call(k, v);
  }

  Future<void> _reloadItem(_ManagedItem<K, V> item) async {
    if (!_futures.containsKey(item.key)) {
      return;
    }

    final future = _futures[item.key]!;

    item.value = await future.call();

    onReloaded?.call(item.key);
  }
}

class _ManagedItem<K, V> {
  _ManagedItem({
    required this.key,
    this.value,
    this.expireDuration,
    this.onExpired,
    this.reloadDuration,
    this.onReload,
  }) {
    expireTimer = expire();
    reloadTimer = reload();
  }

  //Expire
  late final Timer? expireTimer;
  final Duration? expireDuration;
  final void Function(K k, V? v)? onExpired;

  //Reload
  late final Timer? reloadTimer;
  final Duration? reloadDuration;
  final void Function(_ManagedItem<K, V> item)? onReload;

  final K key;
  V? value;

  Timer? expire() {
    if (expireDuration == null) return null;

    return Timer(
      expireDuration!,
      () {
        onExpired?.call(key, value);
      },
    );
  }

  Timer? reload() {
    if (reloadDuration == null) return null;

    return Timer.periodic(reloadDuration!, (time) async {
      onReload?.call(this);
    });
  }

  void dispose() {
    expireTimer?.cancel();
    reloadTimer?.cancel();
  }
}
