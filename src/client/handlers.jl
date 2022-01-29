export on_message!,
    on_ready!,
    command!,
    component!,
    component

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

function component!(f::Function, c::Client, custom_id::AbstractString; kwargs...)
    add_handler!(c, OnInteractionCreate(f; custom_id=custom_id))
    return Component(custom_id=custom_id; kwargs...)
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
    isvalidcommand = (h) -> return (!hasproperty(h, :name) || (!ismissing(ctx.interaction.data.name) && h.name == ctx.interaction.data.name))
    isvalidcomponent = (h) -> return (!hasproperty(h, :custom_id) || (!ismissing(ctx.interaction.data.custom_id) && h.custom_id == ctx.interaction.data.custom_id))
    isvalid = (h) -> return isvalidcommand(h) && isvalidcomponent(h)
    for hh in handlers 
        isvalid(hh) && (runhandler(c, hh, ctx, t))
    end
end

"""
Runs a handler with given context
"""
function runhandler(c::Client, h::Handler, ctx::Context, t::Symbol) 
    if hasproperty(h, :name) || hasproperty(h, :custom_id)
        ack_interaction(c, ctx.interaction.id, ctx.interaction.token)
    end
    h.f(ctx)
end

"""
Calls handle with a list of all found handlers.
"""
function handle(c::Client, t::Symbol, data::Dict)
    haskey(c.handlers, t) ? handle(c, c.handlers[t], data, t) : return nothing
end