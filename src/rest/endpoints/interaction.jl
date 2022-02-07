"""
    create_application_command(c::Client; kwargs...) -> ApplicationCommand

Creates a global [`ApplicationCommand`](@ref).
"""
function create_application_command(c::Client; kwargs...) 
    return Response{ApplicationCommand}(c, :POST, "/applications/$appid/commands"; body=kwargs)
end
"""
    create_application_command(c::Client, guild::Snowflake; kwargs...) -> ApplicationCommand

Creates a guild [`ApplicationCommand`](@ref).
"""
function create_application_command(c::Client, guild::Snowflake; kwargs...)
    appid = c.application_id
    return Response{ApplicationCommand}(c, :POST, "/applications/$appid/guilds/$guild/commands"; body=kwargs)
end

"""
    get_application_commands(c::Client) -> Vector{ApplicationCommand}

Gets all global [`ApplicationCommand`](@ref)s for the logged in client.
"""
function get_application_commands(c::Client)
    appid = c.application_id
    return Response{Vector{ApplicationCommand}}(c, :GET, "/applications/$appid/commands")
end
"""
    get_application_commands(c::Client, guild::Snowflake) -> Vector{ApplicationCommand}

Gets all guild [`ApplicationCommand`](@ref)s for the logged in client.
"""
function get_application_commands(c::Client, guild::Snowflake)
    appid = c.application_id
    return Response{Vector{ApplicationCommand}}(c, :GET, "/applications/$appid/guilds/$guild/commands")
end

"""
    respond_to_interaction(c::Client, int_id::Snowflake, int_token::String; kwargs...) -> Message

Respond to an interaction with code 4.
"""
function respond_to_interaction(c::Client, int_id::Snowflake, int_token::String; kwargs...)
    dict = Dict{Symbol, Any}(
        :data => kwargs,
        :type => 4,
    )
    return Response{Message}(c, :POST, "/interactions/$int_id/$int_token/callback"; body=dict)
end

"""
    ack_interaction(c::Client, int_id::Snowflake, int_token::String; kwargs...)

Respond to an interaction with code 5.
"""
function ack_interaction(c::Client, int_id::Snowflake, int_token::String; kwargs...)
    dict = Dict{Symbol, Any}(
        :type => 5,
    )
    return Response(c, :POST, "/interactions/$int_id/$int_token/callback"; body=dict)
end

"""
    update_ack_interaction(c::Client, int_id::Snowflake, int_token::String; kwargs...) -> Message

Respond to an interaction with code 6.
"""
function update_ack_interaction(c::Client, int_id::Snowflake, int_token::String; kwargs...)
    dict = Dict{Symbol, Any}(
        :type => 6,
    )
    return Response{Message}(c, :POST, "/interactions/$int_id/$int_token/callback"; body=dict)
end

"""
    update_message_int(c::Client, int_id::Snowflake, int_token::String; kwargs...)

Respond to an interaction with code 7.
"""
function update_message_int(c::Client, int_id::Snowflake, int_token::String; kwargs...)
    dict = Dict{Symbol, Any}(
        :data => kwargs,
        :type => 7,
    )
    return Response(c, :POST, "/interactions/$int_id/$int_token/callback"; body=dict)
end

"""
    create_followup_message(c::Client, int_id::Snowflake, int_token::String; kwargs...) -> Message

Creates a followup message for an interaction.
"""
function create_followup_message(c::Client, int_id::Snowflake, int_token::String; kwargs...)
    appid = c.application_id
    return Response{Message}(c, :POST, "/webhooks/$appid/$int_token)"; body=kwargs)
end

"""
    edit_interaction(c::Client, int_id::Snowflake, int_token::String; kwargs...)

Edit a followup message for an interaction.
"""
function edit_interaction(c::Client, int_token::String, mid::Snowflake; kwargs...)
    appid = c.application_id
    return Response(c, :PATCH, "/webhooks/$appid/$int_token/messages/$mid"; body=kwargs)
end

"""
    bulk_overwrite_application_commands(c::Client, guild::Snowflake, cmds::Vector{ApplicationCommand}) -> Vector{ApplicationCommand}

Overwrites global [`ApplicationCommand`](@ref)s with the given cmds vector.
"""
function bulk_overwrite_application_commands(c::Client, guild::Snowflake, cmds::Vector{ApplicationCommand})
    appid = c.application_id
    return Response{Vector{ApplicationCommand}}(c, :PUT, "/applications/$appid/guilds/$guild/commands"; body=cmds)
end
"""
    bulk_overwrite_application_commands(c::Client, guild::Snowflake, cmds::Vector{ApplicationCommand}) -> Vector{ApplicationCommand}

Overwrites guild [`ApplicationCommand`](@ref)s with the given cmds vector.
"""
function bulk_overwrite_application_commands(c::Client, cmds::Vector{ApplicationCommand})
    appid = c.application_id
    return Response{Vector{ApplicationCommand}}(c, :PUT, "/applications/$appid/commands"; body=cmds)
end