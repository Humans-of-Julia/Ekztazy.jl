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

function create_followup_message(c::Client, int_token::String; kwargs...)
    appid = c.application_id
    return Response{Message}(c, :POST, "/webhooks/$appid/$int_token"; body=kwargs)
end