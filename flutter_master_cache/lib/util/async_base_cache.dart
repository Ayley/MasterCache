abstract class AsyncBaseCache<K, V> {

  ///Register future for key
  void register(K k, Future<V> Function() future);

  ///Register future by key
  ///Returns true when the key was existing
  bool unregister(K k);

  ///Get value in cache or get fallback or null
  Future<V?> get(K k, {V? fallback});

  ///Set value in cache, if the value is present it will be overwritten
  ///Returns true when element is overwritten otherwise false
  bool set(K k, V v);

  ///Add value in cache only it the element doesn't exist
  ///Returns true when element is added otherwise false
  bool add(K k, V v);

  ///Returns true when the key is existing otherwise false
  bool exist(K k);

  ///Remove value by key
  V? remove(K k);

  ///Clear all entries
  void clear();

  ///Dispose cache
  void dispose();

}
