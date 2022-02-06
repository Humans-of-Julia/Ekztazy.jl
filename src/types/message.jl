export Message
"""
A [`Message`](@ref) activity.
More details [here](https://discordapp.com/developers/docs/resources/channel#message-object-message-activity-structure).
"""
struct MessageActivity
    type::Int
    party_id::Optional{String}
end
@boilerplate MessageActivity :constructors :docs :lower :merge :mock

"""
A Rich Presence [`Message`](@ref)'s application information.
More details [here](https://discordapp.com/developers/docs/resources/channel#message-object-message-application-structure).
"""
struct MessageApplication <: DiscordObject
    id::Snowflake
    cover_image::Optional{String}
    description::String
    icon::String
    name::String
end
@boilerplate MessageApplication :constructors :docs :lower :merge :mock
struct MessageReference <: DiscordObject
    message_id::Snowflake
    channel_id::Optional{Snowflake}
    guild_id::Optional{Snowflake}
    fail_if_not_exists::Optional{Bool}
end
@boilerplate MessageReference :constructors :lower :merge

"""
A message sent to a [`DiscordChannel`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/channel#message-object).
"""
struct Message <: DiscordObject
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
    message_reference::Optional{MessageReference}
    embeds::Optional{Vector{Embed}}
    reactions::Optional{Vector{Reaction}}
    nonce::OptionalNullable{Snowflake}
    pinned::Optional{Bool}
    webhook_id::Optional{Snowflake}
    type::Optional{Int}
    activity::Optional{MessageActivity}
    application::Optional{MessageApplication}
end
@boilerplate Message :constructors :docs :lower :merge :mock


