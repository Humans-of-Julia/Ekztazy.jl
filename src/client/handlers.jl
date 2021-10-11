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
    (ctx::OnMessageCreateContext) -> Any 
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
    (ctx::OnReadyContext) -> Any 
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
    (ctx::OnInteractionCreateContext) -> Any 
```
"""
function command!(f::Function, c::Client, name::AbstractString, description::AbstractString; kwargs...)
    add_handler!(c, OnInteractionCreate(f, name))
    add_command!(c; name=name, description=description, kwargs...)
end
function command!(f::Function, c::Client, g::Int64, name::AbstractString, description::AbstractString; kwargs...)
    add_handler!(c, OnInteractionCreate(f, name))
    add_command!(c, Snowflake(g); name=name, description=description, kwargs...)
end

"""
    context(::Type{<:AbstractHandler}, data) -> AbstractContext
Generates the context for a Handler based on the given data.
"""
context(::Type{OnInteractionCreate}, data::Dict) = OnInteractionCreateContext(Interaction(data))
context(::Type{OnGuildUpdate}, data::Dict) = OnGuildUpdateContext(Guild(data))
context(::Type{OnMessageCreate}, data::Dict) = OnMessageCreateContext(Message(data))
context(::Type{OnReady}, data::Dict) = OnReadyContext(data)
context(::Type{OnGuildCreate}, data::Dict) = OnGuildCreateContext(Guild(data))

tohandler(t::Type{<:AbstractEvent}) = Symbol("On"*String(Symbol(t)))

"""
    handle(
        c::Client
        handlers,
        data
    )
Determines whether handlers are appropriate to call and calls them if so.
Creates an `AbstractContext` based on the event using the `data` provided and passes it to the handler.
"""
function handle(c::Client, handlers::Vector{<:AbstractHandler}, data::Dict)
    ctx = context(eltype(handlers), data::Dict)
    for h = handlers
        if !(h isa OnInteractionCreate) || h.name == ctx.interaction.data.name
            f = h.f
            @spawn begin 
                try
                    f(ctx)
                catch err
                    @error "Running handlers unexpectedly errored" event=eltype(handlers) error=err
                end
            end
        end
    end
end
"""
Calls handle with a list of all found handlers.
"""
function handle(c::Client, t::Symbol, data::Dict)
    haskey(c.handlers, t) ? handle(c, c.handlers[t], data) : return nothing
end
"""
Calls handle with the handler type symbol based on the event type.
"""
handle(c::Client, T::Type{<:AbstractEvent}, data::Dict) = handle(c, tohandler(T), data::Dict)
handle(c::Client, T::Type{<:AbstractEvent}; kwargs...) = handle(c, T, Dict(kwargs))