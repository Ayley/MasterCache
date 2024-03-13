# flutter_master_cache

## Caches
There are four types of caches at this time. Two for sync operations and two for async operations.

The caches are very similar.

### SyncCache
```
    final SyncCache<int, String> _cache = SyncCache(); //Create cache
    
    _cache.get( 0 ); //Get value of key i in the cache when its cached otherwise it returns null
    _cache.get( 0 , fallback: 'Hello World'); //Get value of key i in the cache or the fallback value 'Hello World'
    
    _cache.set( 0 , 'Hello World' ); //Set the value 'Hello World' for key i 
```
There are more methods so look at the dart file.

### SyncManagedCache
```
    //Create a cache that deletes an element after 5 seconds after adding it. When the time is up the onExpired will called.
    final SyncManagedCache<int, String> _cache = SyncManagedCache(expireDuration: Duration(seconds: 5), onExpired: (key, value?) {});
```

And there is a async variant that can also retrieve http request.

### AsyncCache
```
    final AsyncCache<int, String> _cache = SyncCache(); //Create cache
    
    //When you want that somthing will fetch by calling get on a specific key, register your future on key
    _cache.register(0, () async { return 'HelloWorld!'; });
    
    _cache.get( 0 ); //Get value of key i in the cache when its cached otherwise it will call the registerd future
    _cache.get( 0 ,fallback: 'Hello World'); //Get value of key i in the cache or the fallback value 'Hello World'
    _cache.get( 0 ); //When there is no future or fallback it will return null
    
    _cache.set( 0 , 'Hello World' ); //Set the value 'Hello World' for key i 
```
There are more methods so look at the dart file.

### AsyncManagedCache
```
    //Create a cache that deletes an element after 5 seconds after adding it. When the time is up the onExpired will called.
    final AsyncManagedCache<int, String> _cache = AsyncManagedCache(expireDuration: Duration(seconds: 5), onExpired: (key, value?) {});
```
There is also the possibility to reload/update your items automatically so its anytime up to date.
Look at the dart files!