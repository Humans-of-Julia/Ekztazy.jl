export Message

"""
A [`Message`](@ref)'s type.
More details [here](https://discordapp.com/developers/docs/resources/channel#message-object-message-types).
"""
@enum MessageType begin
    DEFAULT = 0
    RECIPIENT_ADD = 1
    RECIPIENT_REMOVE = 2
    CALL = 3
    CHANNEL_NAME_CHANGE = 4
    CHANNEL_ICON_CHANGE = 5
    CHANNEL_PINNED_MESSAGE = 6
    GUILD_MEMBER_JOIN = 7
    USER_PREMIUM_GUILD_SUBSCRIPTION = 8
    USER_PREMIUM_GUILD_SUBSCRIPTION_TIER_1 = 9
    USER_PREMIUM_GUILD_SUBSCRIPTION_TIER_2 = 10
    USER_PREMIUM_GUILD_SUBSCRIPTION_TIER_3 = 11
    CHANNEL_FOLLOW_ADD = 12
    GUILD_DISCOVERY_DISQUALIFIED = 14
    GUILD_DISCOVERY_REQUALIFIED = 15
    GUILD_DISCOVERY_GRACE_PERIOD_INITIAL_WARNING = 16
    GUILD_DISCOVERY_GRACE_PERIOD_FINAL_WARNING = 17
    THREAD_CREATED = 18
    REPLY = 19
    CHAT_INPUT_COMMAND = 20
    THREAD_STARTER_MESSAGE = 21
    GUILD_INVITE_REMINDER = 22
    CONTEXT_MENU_COMMAND = 23
end
@boilerplate MessageType :export :lower

"""
A [`Message`](@ref)'s activity type.
More details [here](https://discordapp.com/developers/docs/resources/channel#message-object-message-activity-types).
"""
@enum MessageActivityType MAT_JOIN MAT_SPECTATE MAT_LISTEN MAT_JOIN_REQUEST
@boilerplate MessageActivityType :export :lower

"""
A [`Message`](@ref) activity.
More details [here](https://discordapp.com/developers/docs/resources/channel#message-object-message-activity-structure).
"""
struct MessageActivity
    type::MessageActivityType
    party_id::Optional{String}
end
@boilerplate MessageActivity :constructors :docs :lower :merge :mock

"""
A Rich Presence [`Message`](@ref)'s application information.
More details [here](https://discordapp.com/developers/docs/resources/channel#message-object-message-application-structure).
"""
struct MessageApplication
    id::Snowflake
    cover_image::Optional{String}
    description::String
    icon::String
    name::String
end
@boilerplate MessageApplication :constructors :docs :lower :merge :mock

"""
A message sent to a [`DiscordChannel`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/channel#message-object).
"""
struct Message
    id::Snowflake
    channel_id::Snowflake
    # MessageUpdate only requires the ID and channel ID.
    guild_id::Optional{Snowflake}
    author::Optional{User}
    member::Optional{Member}
    content::Optional{String}
    timestamp::Optional{DateTime}
    edited_timestamp::OptionalNullable{DateTime}
    tts::Optional{Bool}
    mention_everyone::Optional{Bool}
    mentions::Optional{Vector{User}}
    mention_roles::Optional{Vector{Snowflake}}
    attachments::Optional{Vector{Attachment}}
    embeds::Optional{Vector{Embed}}
    reactions::Optional{Vector{Reaction}}
    nonce::OptionalNullable{Snowflake}
    pinned::Optional{Bool}
    webhook_id::Optional{Snowflake}
    type::Optional{MessageType}
    activity::Optional{MessageActivity}
    application::Optional{MessageApplication}
end

@boilerplate Message :constructors :docs :lower :merge :mock
