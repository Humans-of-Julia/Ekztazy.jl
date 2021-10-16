export DiscordChannel

"""
A [`DiscordChannel`](@ref)'s type. Prefix with `CT_`. See full list
at https://discord.com/developers/docs/resources/channel#channel-object-channel-types
"""
@enum ChannelTypes begin 
    GUILD_TEXT = 0
    DM = 1
    GUILD_VOICE = 2
    GROUP_DM = 3
    GUILD_CATEGORY = 4
    GUILD_NEWS = 5
    GUILD_STORE = 6
    GUILD_NEWS_THREAD = 10
    GUILD_PUBLIC_THREAD = 11
    GUILD_PRIVATE_THREAD = 12
    GUILD_STAGE_VOICE = 13
end
@boilerplate ChannelTypes :export :lower :convertenum
"""
A Discord channel.
More details [here](https://discordapp.com/developers/docs/resources/channel#channel-object).

Note: The name `Channel` is already used, hence the prefix.
"""
struct DiscordChannel <: DiscordObject
    id::Snowflake
    type::ChannelTypes
    guild_id::Optional{Snowflake}
    position::Optional{Int}
    permission_overwrites::Optional{Vector{Overwrite}}
    name::Optional{String}
    topic::OptionalNullable{String}
    nsfw::Optional{Bool}
    last_message_id::OptionalNullable{Snowflake}
    bitrate::Optional{Int}
    user_limit::Optional{Int}
    rate_limit_per_user::Optional{Int}
    recipients::Optional{Vector{User}}
    icon::OptionalNullable{String}
    owner_id::Optional{Snowflake}
    application_id::Optional{Snowflake}
    parent_id::OptionalNullable{Snowflake}
    last_pin_timestamp::OptionalNullable{DateTime}  # Not supposed to be nullable.
end
@boilerplate DiscordChannel :constructors :docs :lower :merge :mock
