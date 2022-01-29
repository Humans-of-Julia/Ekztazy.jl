export Interaction,
    InteractionData,
    ApplicationCommand,
    ApplicationCommandOption,
    ApplicationCommandChoice,
    Component,
    SelectOption,
    ResolvedData

struct ResolvedData 
    users::Optional{Dict{Snowflake, User}}
    members::Optional{Dict{Snowflake, Member}}
    roles::Optional{Dict{Snowflake, Role}}
    channels::Optional{Dict{Snowflake, Channel}}
    messages::Optional{Dict{Snowflake, Message}}
end
@boilerplate ResolvedData :constructors :lower :merge 

"""
Application Command Choice.
More details [here](https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-option-choice-structure).
"""
struct ApplicationCommandChoice 
    name::String
    value::Union{String, Number}
end
@boilerplate ApplicationCommandChoice :constructors :docs :lower :merge

# TODO: Custom type gen for `value` field of ApplicationCommandOption.
"""
Application Command Option.
More details [here](https://discord.com/developers/docs/interactions/application-commands#application-command-object-application-command-option-structure).
"""
struct ApplicationCommandOption 
    value::Any
    type::Optional{Int}
    name::Optional{String}
    description::Optional{String}
    required::Optional{Bool}
    min_value::Optional{Number}
    max_value::Optional{Number}
    autocomplete::Optional{Bool}
    choices::Optional{Vector{ApplicationCommandChoice}}
    options::Optional{Vector{ApplicationCommandOption}}
    channel_types::Optional{Vector{Int}}
    focused::Optional{Bool}
end
@boilerplate ApplicationCommandOption :constructors :docs :lower :merge

"""
An Application Command.
More details [here](https://discord.com/developers/docs/interactions/application-commands#application-commands).
"""
struct ApplicationCommand <: DiscordObject
    id::OptionalNullable{Snowflake}
    type::Optional{Int}
    application_id::Snowflake
    guild_id::Optional{Snowflake}
    name::String
    description::String
    options::Optional{Vector{ApplicationCommandOption}}
    default_permissions::Optional{Bool}
    version::Optional{Snowflake}
end
@boilerplate ApplicationCommand :constructors :docs :lower :merge :mock

"""
A select option.
More details [here](https://discord.com/developers/docs/interactions/message-components#select-menu-object-select-option-structure).
"""
struct SelectOption <: DiscordObject
    label::String
    value::String
    description::Optional{String}
    emoji::Optional{Emoji}
    default::Optional{Bool}
end
@boilerplate SelectOption :constructors :docs :lower :merge :mock

"""
An interactable component.
More details [here](https://discord.com/developers/docs/interactions/message-components).
"""
struct Component <: DiscordObject
    type::Int
    custom_id::Optional{String}
    disabled::Optional{Bool}
    style::Optional{Int}
    label::Optional{String}
    emoji::Optional{Emoji}
    url::Optional{String}
    options::Optional{Vector{SelectOption}}
    placeholder::Optional{String}
    min_values::Optional{Int}
    max_values::Optional{Int}
    components::Optional{Vector{Component}}
end
@boilerplate Component :constructors :docs :lower :merge :mock


"""
Data for an interaction.
More details [here](https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-interaction-data-structure).
"""
struct InteractionData <: DiscordObject
    id::OptionalNullable{Snowflake}
    name::OptionalNullable{String}
    type::OptionalNullable{Int}
    resolved::Optional{ResolvedData}
    options::Optional{Vector{ApplicationCommandOption}}
    custom_id::OptionalNullable{String}
    component_type::OptionalNullable{Int}
    values::Optional{Vector{String}}
    target_id::Optional{Snowflake}
end
@boilerplate InteractionData :constructors :docs :lower :merge

"""
An interaction.
More details [here](https://discord.com/developers/docs/interactions/receiving-and-responding#interaction-object-interaction-structure).
"""
struct Interaction <: DiscordObject
    id::Nullable{Snowflake}
    application_id::Nullable{Snowflake}
    type::Int
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