create(c::Client, ::Type{ApplicationCommand}, name::AbstractString, description::AbstractString; kwargs...) = create_application_command(c; name=name, description=description, kwargs...)
create(c::Client, ::Type{ApplicationCommand}, name::AbstractString, description::AbstractString, g::Snowflake; kwargs...) = create_application_command(c, g; name=name, description=description, kwargs...)
create(c::Client, ::Type{Message}, interaction::Interaction; kwargs...) = create_followup_message(c, interaction.id, interaction.token; compkwfix(; kwargs...)...)
create(c::Client, ::Type{Vector{ApplicationCommand}}, cmds::Vector{ApplicationCommand}) = bulk_overwrite_application_commands(c, cmds)
create(c::Client, ::Type{Vector{ApplicationCommand}}, g::Snowflake, cmds::Vector{ApplicationCommand}) = bulk_overwrite_application_commands(c, g, cmds)

retrieve(c::Client, ::Type{Vector{ApplicationCommand}}) = get_application_commands(c)
retrieve(c::Client, ::Type{Vector{ApplicationCommand}}, g::Snowflake) = get_application_commands(c, g)

update(c::Client, ctx::Context, m::Message; kwargs...) = edit_interaction(c, ctx.interaction.token, m.id; compkwfix(; kwargs...)...)
update(c::Client, ctx::Context; kwargs...) = hasproperty(ctx, :interaction) ?  update_message_int(c, ctx.interaction.id, ctx.interaction.token; compkwfix(; kwargs...)...) : update(c, ctx.message; compkwfix(; kwargs...)...)
