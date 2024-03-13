import 'dart:async';

import 'package:flutter_master_cache/util/base_cache.dart';

class SyncManagedCache<K, V> extends BaseCache<K, V> {
  SyncManagedCache({
    this.expireDuration,
    this.onExpired,
  });

  final Duration? expireDuration;
  final void Function(K k, V? v)? onExpired;

  final Map<K, _ManagedItem<K, V>> _cache = {};

  @override
  V? get(K k, {V? fallback}) {
    if (exist(k)) {
      return _cache[k]?.value;
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
    for (final key in _cache.keys) {
      remove(key);
    }
  }

  @override
  void dispose() {}

  void _expiredItem(K k, V? v) {
    remove(k);

    onExpired?.call(k, v);
  }
}

class _ManagedItem<K, V> {
  _ManagedItem({
    required this.key,
    this.value,
    this.expireDuration,
    this.onExpired,
  }) {
    timer = expire();
  }

  late final Timer? timer;
  final Duration? expireDuration;
  final void Function(K k, V? v)? onExpired;
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

  void dispose() {
    timer?.cancel();
  }
}
