function create_application_command(c::Client; kwargs...) 
    return Response{ApplicationCommand}(c, :POST, "/applications/$appid/commands"; body=kwargs)
end
function create_application_command(c::Client, guild::Snowflake; kwargs...)
    appid = c.application_id
    return Response{ApplicationCommand}(c, :POST, "/applications/$appid/guilds/$guild/commands"; body=kwargs)
end

function get_application_commands(c::Client)
    appid = c.application_id
    return Response{Vector{ApplicationCommand}}(c, :GET, "/applications/$appid/commands")
end
function get_application_commands(c::Client, guild::Snowflake)
    appid = c.application_id
    return Response{Vector{ApplicationCommand}}(c, :GET, "/applications/$appid/guilds/$guild/commands")
end

function respond_to_interaction(c::Client, int_id::Snowflake, int_token::String; kwargs...)
    dict = Dict{Symbol, Any}(
        :data => kwargs,
        :type => 4,
    )
    return Response{Message}(c, :POST, "/interactions/$int_id/$int_token/callback"; body=dict)
end

function ack_interaction(c::Client, int_id::Snowflake, int_token::String; kwargs...)
    dict = Dict{Symbol, Any}(
        :type => 5,
    )
    return Response(c, :POST, "/interactions/$int_id/$int_token/callback"; body=dict)
end

function update_ack_interaction(c::Client, int_id::Snowflake, int_token::String; kwargs...)
    dict = Dict{Symbol, Any}(
        :type => 6,
    )
    return Response{Message}(c, :POST, "/interactions/$int_id/$int_token/callback"; body=dict)
end

function update_message_int(c::Client, int_id::Snowflake, int_token::String; kwargs...)
    dict = Dict{Symbol, Any}(
        :data => kwargs,
        :type => 7,
    )
    return Response(c, :POST, "/interactions/$int_id/$int_token/callback"; body=dict)
end

function create_followup_message(c::Client, int_id::Snowflake, int_token::String; kwargs...)
    appid = c.application_id
    return Response{Message}(c, :POST, "/webhooks/$appid/$int_token)"; body=kwargs)
end

function edit_interaction(c::Client, int_token::String, mid::Snowflake; kwargs...)
    appid = c.application_id
    return Response(c, :PATCH, "/webhooks/$appid/$int_token/messages/$mid"; body=kwargs)
end

function bulk_overwrite_application_commands(c::Client, guild::Snowflake, cmds::Vector{ApplicationCommand})
    appid = c.application_id
    return Response{Vector{ApplicationCommand}}(c, :PUT, "/applications/$appid/guilds/$guild/commands"; body=cmds)
end

function bulk_overwrite_application_commands(c::Client, cmds::Vector{ApplicationCommand})
    appid = c.application_id
    return Response{Vector{ApplicationCommand}}(c, :PUT, "/applications/$appid/commands"; body=cmds)
end