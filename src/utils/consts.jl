"""
An [`Activity`](@ref)'s type. Available values are `GAME`, `STREAMING`,
`LISTENING`, `WATCHING`, and `COMPETING`.
More details [here](https://discordapp.com/developers/docs/topics/gateway#activity-object-activity-types).
"""
module ActivityType
    const GAME=0
    const STREAMING=1
    const LISTENING=2 
    const WATCHING=3
    const CUSTOM=4
    const COMPETING=5
end 
"""
Flags which indicate what an [`Activity`](@ref) payload contains.
More details [here](https://discordapp.com/developers/docs/topics/gateway#activity-object-activity-flags).
"""
module ActivityFlags
    const INSTANCE=1<<0
    const JOIN=1<<1
    const SPECTATE=1<<2
    const JOIN_REQUEST=1<<3
    const SYNC=1<<4
    const PLAY=1<<5
end
"""
[`AuditLog`](@ref) action types.
More details [here](https://discordapp.com/developers/docs/resources/audit-log#audit-log-entry-object-audit-log-events).
"""
module ActionType  
    const GUILD_UPDATE=1
    const CHANNEL_CREATE=10
    const CHANNEL_UPDATE=11
    const CHANNEL_DELETE=12
    const CHANNEL_OVERWRITE_CREATE=13
    const CHANNEL_OVERWRITE_UPDATE=14
    const CHANNEL_OVERWRITE_DELETE=15
    const MEMBER_KICK=20
    const MEMBER_PRUNE=21
    const MEMBER_BAN_ADD=22
    const MEMBER_BAN_REMOVE=23
    const MEMBER_UPDATE=24
    const MEMBER_ROLE_UPDATE=25
    const ROLE_CREATE=30
    const ROLE_UPDATE=31
    const ROLE_DELETE=32
    const INVITE_CREATE=40
    const INVITE_UPDATE=41
    const INVITE_DELETE=42
    const WEBHOOK_CREATE=50
    const WEBHOOK_UPDATE=51
    const WEBHOOK_DELETE=52
    const EMOJI_CREATE=60
    const EMOJI_UPDATE=61
    const EMOJI_DELETE=62
    const MESSAGE_DELETE=72
end
"""
A [`DiscordChannel`](@ref)'s type. See full list
at https://discord.com/developers/docs/resources/channel#channel-object-channel-types
"""
module ChannelTypes 
    const GUILD_TEXT = 0
    const DM = 1
    const GUILD_VOICE = 2
    const GROUP_DM = 3
    const GUILD_CATEGORY = 4
    const GUILD_NEWS = 5
    const GUILD_STORE = 6
    const GUILD_NEWS_THREAD = 10
    const GUILD_PUBLIC_THREAD = 11
    const GUILD_PRIVATE_THREAD = 12
    const GUILD_STAGE_VOICE = 13
end
"""
A [`Guild`](@ref)'s verification level.
More details [here](https://discordapp.com/developers/docs/resources/guild#guild-object-verification-level).
"""
module VerificationLevel 
    const NONE = 0
    const LOW = 1
    const MEDIUM = 2 
    const HIGH = 3 
    const VERY_HIGH = 4
end

"""
A [`Guild`](@ref)'s default message notification level.
More details [here](https://discordapp.com/developers/docs/resources/guild#guild-object-default-message-notification-level).
"""
module MessageNotificationLevel 
    const ALL_MESSAGES = 0
    const ONLY_MENTIONS = 1 
end

"""
A [`Guild`](@ref)'s explicit content filter level.
More details [here](https://discordapp.com/developers/docs/resources/guild#guild-object-explicit-content-filter-level).
"""
module ExplicitContentFilterLevel 
    const DISABLED = 0
    const MEMBERS_WITHOUT_ROLES = 1
    const ALL_MEMBERS = 2
end
"""
A [`Guild`](@ref)'s MFA level.
More details [here](https://discordapp.com/developers/docs/resources/guild#guild-object-mfa-level).
"""
module MFALevel 
    const NONE = 0
    const ELEVATED = 1
end

module InteractionType 
    const PING = 1
    const APPLICATIONCOMMAND = 2
    const MESSAGECOMPONENT = 3
end

module ApplicationCommandType
    const CHATINPUT = 1
    const UI = 2
    const MESSAGE = 3
end

module ComponentType 
    const ACTIONROW = 1
    const BUTTON = 2
    const SELECTMENU = 3
end

module OptionType 
    const SUB_COMMAND = 1
    const SUB_COMMAND_GROUP = 2
    const STRING = 3
    const INTEGER = 4
    const BOOLEAN = 5
    const USER = 6
    const CHANNEL = 7
    const ROLE = 8
    const MENTIONABLE = 9
    const NUMBER = 10
end

"""
A [`Message`](@ref)'s type.
More details [here](https://discordapp.com/developers/docs/resources/channel#message-object-message-types).
"""
module MessageType
    const DEFAULT = 0
    const RECIPIENT_ADD = 1
    const RECIPIENT_REMOVE = 2
    const CALL = 3
    const CHANNEL_NAME_CHANGE = 4
    const CHANNEL_ICON_CHANGE = 5
    const CHANNEL_PINNED_MESSAGE = 6
    const GUILD_MEMBER_JOIN = 7
    const USER_PREMIUM_GUILD_SUBSCRIPTION = 8
    const USER_PREMIUM_GUILD_SUBSCRIPTION_TIER_1 = 9
    const USER_PREMIUM_GUILD_SUBSCRIPTION_TIER_2 = 10
    const USER_PREMIUM_GUILD_SUBSCRIPTION_TIER_3 = 11
    const CHANNEL_FOLLOW_ADD = 12
    const GUILD_DISCOVERY_DISQUALIFIED = 14
    const GUILD_DISCOVERY_REQUALIFIED = 15
    const GUILD_DISCOVERY_GRACE_PERIOD_INITIAL_WARNING = 16
    const GUILD_DISCOVERY_GRACE_PERIOD_FINAL_WARNING = 17
    const THREAD_CREATED = 18
    const REPLY = 19
    const CHAT_INPUT_COMMAND = 20
    const THREAD_STARTER_MESSAGE = 21
    const GUILD_INVITE_REMINDER = 22
    const CONTEXT_MENU_COMMAND = 23
end 

"""
A [`Message`](@ref)'s activity type.
More details [here](https://discordapp.com/developers/docs/resources/channel#message-object-message-activity-types).
"""
module MessageActivityType 
    const JOIN = 1
    const SPECTATE = 2
    const LISTEN = 3
    const JOIN_REQUEST = 5
end