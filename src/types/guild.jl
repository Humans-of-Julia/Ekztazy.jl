export Guild

"""
A Discord guild (server).
Can either be an [`UnavailableGuild`](@ref) or a [`Guild`](@ref).
"""
abstract type AbstractGuild <: DiscordObject end
function AbstractGuild(; kwargs...)
    return if get(kwargs, :unavailable, length(kwargs) <= 2) === true
        UnavailableGuild(; kwargs...)
    else
        Guild(; kwargs...)
    end
end
AbstractGuild(d::Dict{Symbol, Any}) = AbstractGuild(; d...)
mock(::Type{AbstractGuild}) = mock(rand(Bool) ? UnavailableGuild : Guild)

"""
An unavailable Discord guild (server).
More details [here](https://discordapp.com/developers/docs/resources/guild#unavailable-guild-object).
"""
struct UnavailableGuild <: AbstractGuild
    id::Snowflake
    unavailable::Optional{Bool}
end
@boilerplate UnavailableGuild :constructors :docs :lower :merge :mock

"""
A Discord guild (server).
More details [here](https://discordapp.com/developers/docs/resources/guild#guild-object).
"""
struct Guild <: AbstractGuild
    id::Snowflake
    name::String
    icon::Nullable{String}
    splash::OptionalNullable{String}
    owner::Optional{Bool}
    owner_id::Optional{Snowflake}  # Missing in Invite.
    permissions::Optional{String}
    region::Optional{String}  # Invite
    afk_channel_id::OptionalNullable{Snowflake}  # Invite
    afk_timeout::Optional{Int}  # Invite
    embed_enabled::Optional{Bool}
    embed_channel_id::OptionalNullable{Snowflake}  # Not supposed to be nullable.
    verification_level::Optional{Int}
    default_message_notifications::Optional{Int}  # Invite
    explicit_content_filter::Optional{Int}  # Invite
    roles::Optional{Vector{Role}}  # Invite
    emojis::Optional{Vector{Emoji}}  # Invite
    features::Optional{Vector{String}}
    mfa_level::Optional{Int}  # Invite
    application_id::OptionalNullable{Snowflake}  # Invite
    widget_enabled::Optional{Bool}
    widget_channel_id::OptionalNullable{Snowflake}  # Not supposed to be nullable.
    system_channel_id::OptionalNullable{Snowflake}  # Invite
    joined_at::Optional{DateTime}
    large::Optional{Bool}
    unavailable::Optional{Bool}
    member_count::Optional{Int}
    max_members::Optional{Int}
    voice_states::Optional{Vector{VoiceState}}
    members::Optional{Vector{Member}}
    channels::Optional{Vector{DiscordChannel}}
    presences::Optional{Vector{Presence}}
    max_presences::OptionalNullable{Int}
    vanity_url_code::OptionalNullable{String}
    description::OptionalNullable{String}
    banner::OptionalNullable{String} # Hash
    djl_users::Optional{Set{Snowflake}}
    djl_channels::Optional{Set{Snowflake}}
end
@boilerplate Guild :constructors :docs :lower :merge :mock

Base.merge(x::UnavailableGuild, y::Guild) = y
Base.merge(x::Guild, y::UnavailableGuild) = x

struct EntityMetadata <: DiscordObject
    location::Optional{String}
end
@boilerplate EntityMetadata :constructors :docs :lower :merge :mock

mutable struct ScheduledEvent <: DiscordObject 
    id::Snowflake
    guild_id::Snowflake
    channel_id::Optional{Snowflake}
    creator_id::Optional{Snowflake}
    name::Optional{String}
    description::Optional{String}
    scheduled_start_time::Optional{DateTime}
    scheduled_end_time::Optional{DateTime}
    privacy_level::Optional{Int} # convert to enum
    status::Optional{Int} # convert to enum
    entity_type::Optional{Int} # convert to enum
    entity_id::Optional{Snowflake}
    entity_metadata::Optional{EntityMetadata}
    creator::Optional{User}
    user_count::Optional{Int}
    image::Optional{String}
end
@boilerplate ScheduledEvent :constructors :docs :lower :merge :mock