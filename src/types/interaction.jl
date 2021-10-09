export Interaction,
    ApplicationCommand,
    ApplicationCommandOption,
    ApplicationCommandChoice

@enum InteractionType begin 
    PING = 1
    APPLICATIONCOMMAND = 2
    MESSAGECOMPONENT = 3
end
@boilerplate InteractionType :export :lower :convertenum

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

@enum ApplicationCommandType begin
    CHATINPUT = 1
    UI = 2
    MESSAGE = 3
end
@boilerplate ApplicationCommandType :export :lower :convertenum

@enum ComponentType begin 
    ACTIONROW = 1
    BUTTON = 2
    SELECTMENU = 3
end
@boilerplate ComponentType :export :lower :merge :convertenum

@enum OptionType begin 
    SUB_COMMAND = 1
    SUB_COMMAND_GROUP = 2
    STRING = 3
    INTEGER = 4
    BOOLEAN = 5
    USER = 6
    CHANNEL = 7
    ROLE = 8
    MENTIONABLE = 9
    NUMBER = 10
end
@boilerplate OptionType :export :lower

struct ResolvedData 
    users::Optional{Dict{Snowflake, User}}
    members::Optional{Dict{Snowflake, Member}}
    roles::Optional{Dict{Snowflake, Role}}
    channels::Optional{Dict{Snowflake, Channel}}
    messages::Optional{Dict{Snowflake, Message}}
end
@boilerplate ResolvedData :constructors :docs :lower :merge 

struct ApplicationCommandChoice 
    name::String
    value::Union{String, Number}
end
@boilerplate ApplicationCommandChoice :constructors :docs :lower :merge

struct ApplicationCommandOption 
    name::Optional{String}
    type::OptionType
    value::Optional{Any}
    required::Optional{Bool}
    choices::Optional{Vector{ApplicationCommandChoice}}
    options::Optional{Vector{ApplicationCommandOption}}
    channel_types::Optional{Vector{ChannelTypes}}
end
@boilerplate ApplicationCommandOption :constructors :docs :lower :merge

struct ApplicationCommand 
    id::Nullable{Snowflake}
    type::Optional{ApplicationCommandType}
    application_id::Snowflake
    guild_id::Optional{Snowflake}
    name::String
    description::String
    options::Optional{Vector{ApplicationCommandOption}}
    default_permissions::Optional{Bool}
    version::Optional{Snowflake}
end
@boilerplate ApplicationCommand :constructors :docs :lower :merge :mock

struct InteractionData 
    id::Nullable{Snowflake}
    name::String
    type::ApplicationCommandType
    resolved::Optional{ResolvedData}
    options::Optional{Vector{ApplicationCommandOption}}
    custom_id::OptionalNullable{String}
    component_type::OptionalNullable{ComponentType}
    values::Optional{Vector{String}}
    target_id::Nullable{Snowflake}
end
@boilerplate InteractionData :constructors :docs :lower :merge

"""
An interaction.
More details [here](https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-interaction-structure).
"""
struct Interaction
    id::Nullable{Snowflake}
    application_id::Nullable{Snowflake}
    type::InteractionType
    data::OptionalNullable{InteractionData}
    guild_id::Optional{Snowflake}
    channel_id::Optional{Snowflake}
    member::Optional{Member}
    user::Optional{User}
    token::String
    version::Optional{Int}
    message::Optional{Message}
end
@boilerplate Interaction :constructors :docs :lower :merge :mock