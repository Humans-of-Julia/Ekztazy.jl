```@meta
CurrentModule = Dizkord
```

# Client

```@docs
Client
enable_cache!
disable_cache!
me
```

## Gateway

```@docs
Base.open
Base.isopen
Base.close
Base.wait
request_guild_members
update_voice_state
update_status
heartbeat_ping
```

## Caching

```@docs
CacheStrategy
CacheForever
CacheNever
CacheTTL
CacheLRU
CacheFilter
```
