create(c::Client, ::Type{ApplicationCommand}, name::AbstractString, description::AbstractString; kwargs...) = create_application_command(c; name=name, description=description, kwargs...)
create(c::Client, ::Type{ApplicationCommand}, g::Guild; kwargs...) = create_application_command(c, g.id; kwargs...)
retrieve(c::Client, ::Type{Vector{ApplicationCommand}}) = get_application_commands(c)
retrieve(c::Client, ::Type{Vector{ApplicationCommand}}, g::Guild) = get_application_commands(c, g.id)