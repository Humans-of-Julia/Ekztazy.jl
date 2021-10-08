function create_application_command(c::Client; kwargs...) 
    return Response{ApplicationCommand}(c, :POST, "/applications/$appid/commands"; body=kwargs)
end

function create_application_command(c::Client, guild::Snowflake; kwargs...)
    appid = c.application_id
    return Response{ApplicationCommand}(c, :POST, "/applications/$appid/guilds/$guild/commands"; body=kwargs)
end