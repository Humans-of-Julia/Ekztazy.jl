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
function command!(f::Function, c::Client, name::AbstractString, description::AbstractString, legacy::Bool=true; kwargs...)
    if !legacy
        g = generate_command_func(f)
        add_handler!(c, OnInteractionCreate(g; name=name))
        add_command!(c; name=name, description=description, kwargs...)
    else
        add_handler!(c, OnInteractionCreate(f; name=name))
        add_command!(c; name=name, description=description, kwargs...)
    end
end
function command!(f::Function, c::Client, g::Number, name::AbstractString, description::AbstractString, legacy::Bool=true; kwargs...)
    if !legacy
        h = generate_command_func(f)
        add_handler!(c, OnInteractionCreate(h; name=name))
        add_command!(c, Snowflake(g); name=name, description=description, kwargs...)
    else
        add_handler!(c, OnInteractionCreate(f; name=name))
        add_command!(c, Snowflake(g); name=name, description=description, kwargs...)
    end
end
command!(f::Function, c::Client, g::String, name::AbstractString, description::AbstractString, legacy::Bool=true; kwargs...) = command!(f, c, parse(Int, g), name, description, legacy; kwargs...)

function generate_command_func(f::Function)
    args = handlerargs(f)
    @debug "Generating typed args" args=args
    g = (ctx::Context) -> begin
        a = makeargs(ctx, args)
        f(ctx, a...)  
    end
    g
end

function makeargs(ctx::Context, args) 
    o = opt(ctx)
    v = []
    args = args[2:end]
    if length(args) == 0
        return v
    end
    for x = args 
        t = last(x)
        arg =  get(o, string(first(x)), :ERR)
        push!(v, convert(t, arg, ctx))
    end
    v
end

#// Todo: make converters for User etc
convert(::Type{T}, arg, ctx::Context) where T = return arg

const TYPEIND = Dict{Type, Int64}(
    String => 3,
    Int => 4,
    Bool => 5,
    User => 6,
    DiscordChannel => 7,
    Role => 8, 
)

"""
component!(
    f::Function
    c::Client
    custom_id::AbstractString
    kwargs...
)

Adds a handler for INTERACTION CREATE gateway events where the InteractionData's `custom_id` field matches `custom_id`.
The `f` parameter signature should be:
```
(ctx::Context) -> Any 
```
"""
function component!(f::Function, c::Client, custom_id::AbstractString, auto_ack::Bool; kwargs...)
    add_handler!(c, OnInteractionCreate(f; custom_id=custom_id))
    if !auto_ack
        push!(c.no_auto_ack, custom_id)
    end
    return Component(custom_id=custom_id; kwargs...)
end

component(a, b, c; kwargs...) = component!(a, b, c, false; kwargs...)
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
    if hasproperty(ctx, :interaction)
        if ismissing(ctx.interaction.data.custom_id) || !(ctx.interaction.data.custom_id in c.no_auto_ack)
            @debug "Acking interaction"
            ack_interaction(c, ctx.interaction.id, ctx.interaction.token)
        end
    end
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
    @debug "Running handler" h=Handler type=t
    begin 
        h.f(ctx) 
    end
end

"""
Calls handle with a list of all found handlers.
"""
function handle(c::Client, t::Symbol, data::Dict)
    haskey(c.handlers, t) ? handle(c, c.handlers[t], data, t) : return nothing
end