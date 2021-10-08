create(c::Client, ::Type{ApplicationCommand}, name::AbstractString, description::AbstractString; kwargs...) = create_application_command(c; name=name, description=description, kwargs...)
create(c::Client, ::Type{ApplicationCommand}, g::Guild; kwargs...) = create_application_command(c, g.id; kwargs...)
