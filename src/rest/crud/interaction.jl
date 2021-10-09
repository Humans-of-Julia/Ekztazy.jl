create(c::Client, ::Type{ApplicationCommand}, name::AbstractString, description::AbstractString; kwargs...) = create_application_command(c; name=name, description=description, kwargs...)
create(c::Client, ::Type{ApplicationCommand}, name::AbstractString, description::AbstractString, g::Snowflake; kwargs...) = create_application_command(c, g; name=name, description=description, kwargs...)
create(c::Client, ::Type{Message}, interaction::Interaction; kwargs...) = create_followup_message(c, interaction.token; kwargs...)

retrieve(c::Client, ::Type{Vector{ApplicationCommand}}) = get_application_commands(c)
retrieve(c::Client, ::Type{Vector{ApplicationCommand}}, g::Snowflake) = get_application_commands(c, g)

