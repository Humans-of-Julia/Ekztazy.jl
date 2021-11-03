export on_message!,
    on_ready!,
    command!

"""
    on_message!(
        f::Function
        c::Client
    )

Adds a handler for the MESSAGE_CREATE gateway event.
The `f` parameter's signature should be:
```
    (ctx::Context) -> Any 
```
"""
on_message!(f::Function, c::Client) = add_handler!(c, OnMessageCreate(f))
"""
    on_ready!(
        f::Function
        c::Client
    )

Adds a handler for the READY gateway event.
The `f` parameter signature should be:
```
    (ctx::Context) -> Any 
```
"""
on_ready!(f::Function, c::Client) = add_handler!(c, OnReady(f))
"""
    command!(
        f::Function
        c::Client
        name::AbstractString
        description::AbstractString;
        kwargs...
    )

Adds a handler for INTERACTION CREATE gateway events where the InteractionData's `name` field matches `name`.
Adds this command to `c.commands` or `c.guild_commands` based on the presence of `guild`.
The `f` parameter signature should be:
```
    (ctx::Context) -> Any 
```
"""
function command!(f::Function, c::Client, name::AbstractString, description::AbstractString; kwargs...)
    add_handler!(c, OnInteractionCreate(f; name=name))
    add_command!(c; name=name, description=description, kwargs...)
end
function command!(f::Function, c::Client, g::Number, name::AbstractString, description::AbstractString; kwargs...)
    add_handler!(c, OnInteractionCreate(f; name=name))
    add_command!(c, Snowflake(g); name=name, description=description, kwargs...)
end

"""
    handle(
        c::Client
        handlers,
        data
    )
Determines whether handlers are appropriate to call and calls them if so.
Creates an `AbstractContext` based on the event using the `data` provided and passes it to the handler.
"""
function handle(c::Client, handlers::Vector{Handler}, data::Dict, t::Symbol)
    ctx = context(t, data::Dict)
    for h = handlers
        if !hasproperty(h, :name) || h.name == ctx.interaction.data.name
            f = h.f
            @spawn begin 
                try
                    f(ctx)
                catch err
                    @error "Running handlers unexpectedly errored" event=String(t) error=err
                end
            end
        end
    end
end
"""
Calls handle with a list of all found handlers.
"""
function handle(c::Client, t::Symbol, data::Dict)
    haskey(c.handlers, t) ? handle(c, c.handlers[t], data, t) : return nothing
end