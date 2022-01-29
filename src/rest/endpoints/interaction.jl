export create_application_command,
    get_application_commands,
    respond_to_interaction,
    create_followup_message,
    ack_interaction,
    bulk_overwrite_application_commands

"""
    create_application_command(c::Client; kwargs...) -> ApplicationCommand

Creates an [`ApplicationCommand`](@ref).\n
More details [here](https://discord.com/developers/docs/interactions/application-commands#create-global-application-command)
"""
function create_application_command(c::Client; kwargs...) 
    return Response{ApplicationCommand}(c, :POST, "/applications/$appid/commands"; body=kwargs)
end
"""
    create_application_command(c::Client, guild::Snowflake; kwargs...) -> ApplicationCommand

Creates an [`ApplicationCommand`](@ref) for a specified guild.
"""
function create_application_command(c::Client, guild::Snowflake; kwargs...)
    appid = c.application_id
    return Response{ApplicationCommand}(c, :POST, "/applications/$appid/guilds/$guild/commands"; body=kwargs)
end

"""
    get_application_commands(c::Client) -> Vector{ApplicationCommand}

Gets a list of all global [`ApplicationCommand`](@ref)s.
"""
function get_application_commands(c::Client)
    appid = c.application_id
    return Response{Vector{ApplicationCommand}}(c, :GET, "/applications/$appid/commands")
end
"""
    get_application_commands(c::Client, guild::Snowflake) -> Vector{ApplicationCommand}

Gets a list of all guild [`ApplicationCommand`](@ref)s.
"""
function get_application_commands(c::Client, guild::Snowflake)
    appid = c.application_id
    return Response{Vector{ApplicationCommand}}(c, :GET, "/applications/$appid/guilds/$guild/commands")
end

"""
    respond_to_interaction(c::Client, int_id::Snowflake, int_token::String; kwargs...) -> Message

Respond to an interaction with a [`Message`](@ref). `kwargs` should contain at list one of the following keys:
- content
- attachments
- embeds
\nint_id is the [`Interaction`](@ref) id.\n
int_token is the [`Interaction`](@ref) token.
"""
function respond_to_interaction(c::Client, int_id::Snowflake, int_token::String; kwargs...)
    dict = Dict{Symbol, Any}(
        :data => kwargs,
        :type => 4,
    )
    return Response{Message}(c, :POST, "/interactions/$int_id/$int_token/callback"; body=dict)
end

"""
    create_followup_message(c::Client, int_id::Snowflake, int_token::String; kwargs...)

Creates a followup message for an interaction that has been acked or responded to.\n
Note: This does **not** return a [`Message`](@ref).
\nint_id is the [`Interaction`](@ref) id.\n
int_token is the [`Interaction`](@ref) token.
"""
function create_followup_message(c::Client, int_id::Snowflake, int_token::String; kwargs...)
    appid = c.application_id
    return Response(c, :POST, "/webhooks/$appid/$int_token)"; body=kwargs)
end

"""
    ack_interaction(c::Client, int_id::Snowflake, int_token::String; kwargs...)

Ack an interaction to create a followup message later.
\nint_id is the [`Interaction`](@ref) id.\n
int_token is the [`Interaction`](@ref) token.
"""
function ack_interaction(c::Client, int_id::Snowflake, int_token::String; kwargs...)
    dict = Dict{Symbol, Any}(
        :type => 5,
    )
    return Response(c, :POST, "/interactions/$int_id/$int_token/callback"; body=dict)
end

"""
    bulk_overwrite_application_commands(c::Client, guild::Snowflake, cmds::Vector{ApplicationCommand}) -> ApplicationCommand

Bulk register a list of guild [`ApplicationCommand`](@ref)s.
"""
function bulk_overwrite_application_commands(c::Client, guild::Snowflake, cmds::Vector{ApplicationCommand})
    appid = c.application_id
    return Response{Vector{ApplicationCommand}}(c, :PUT, "/applications/$appid/guilds/$guild/commands"; body=cmds)
end
"""
    bulk_overwrite_application_commands(c::Client, guild::Snowflake, cmds::Vector{ApplicationCommand}) -> ApplicationCommand

Bulk register a list of global [`ApplicationCommand`](@ref)s.
"""
function bulk_overwrite_application_commands(c::Client, cmds::Vector{ApplicationCommand})
    appid = c.application_id
    return Response{Vector{ApplicationCommand}}(c, :PUT, "/applications/$appid/commands"; body=cmds)
end