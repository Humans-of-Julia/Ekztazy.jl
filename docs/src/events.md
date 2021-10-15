```@meta
CurrentModule = Discord
```

# Events

Note that `Snowflake === UInt64`.
`Union`s with `Nothing` indicate that a field is nullable, whereas `Union`s with `Missing` indicate that a field is optional. 
---
**NOTE**

The Event types are deprecated. They will be removed in `0.3.z`.
---

```@docs
AbstractEvent
FallbackEvent
UnknownEvent
```

## Channels

```@docs
ChannelCreate
ChannelUpdate
ChannelDelete
ChannelPinsUpdate
```

## Guilds

```@docs
GuildCreate
GuildUpdate
GuildDelete
GuildBanAdd
GuildBanRemove
GuildEmojisUpdate
GuildIntegrationsUpdate
GuildMemberAdd
GuildMemberRemove
GuildMemberUpdate
GuildMembersChunk
GuildRoleCreate
GuildRoleUpdate
GuildRoleDelete
```

## Messages

```@docs
MessageCreate
MessageUpdate
MessageDelete
MessageDeleteBulk
MessageReactionAdd
MessageReactionRemove
MessageReactionRemoveAll
```

## Presence

```@docs
PresenceUpdate
TypingStart
UserUpdate
```

## Voice

```@docs
VoiceStateUpdate
VoiceServerUpdate
```

## Webhooks

```@docs
WebhooksUpdate
```

## Connecting

```@docs
Ready
Resumed
```

# Handlers

`Handlers` are mirrors of `Events` prefixed with `On`. They always contain a function that takes a `Context` as an argument. Each handler has an analog context, that context is simply the handler suffixed with `Context`. For example the [`MessageCreate`](@ref) event has a handler called [`OnMessageCreate`](@ref) and a context called [`OnMessageCreateContext`].

## Channels

```@docs
ChannelCreate
ChannelUpdate
ChannelDelete
ChannelPinsUpdate
```

## Guilds

```@docs
OnGuildCreate
OnGuildUpdate
OnGuildDelete
```

## Messages

```@docs
MessageCreate
MessageUpdate
MessageDelete
```

## Connecting

```@docs
Ready
Resumed
```

