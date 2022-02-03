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
    (ctx::Context, args...) -> Any 
```
Where args is a list of all the Command Options

For example a command that takes a user u and a number n as input should have this signature:
```
(ctx::Context, u::User, n::Int) -> Any
```
and the arguments would automatically get converted.

**Note:** The argument names **must** match the Option names. The arguments can be ordered in any way. If no type is specified, no conversion will be performed, so Discord objects will be `Snowflake`s.
"""
function command!(c::Client, f::Function, name::AbstractString, desc::AbstractString, legacy::Bool; kwargs...)
    haskey(kwargs, :options) && check_option.(kwargs[:options])
    namecheck(name, r"^[\w-]{1,32}$", 32, "ApplicationCommand Name")
    namecheck(name, 100, "ApplicationCommand Description")
    legacy ? add_handler!(c, OnInteractionCreate(f; name=name)) : add_handler!(c, OnInteractionCreate(generate_command_func(f); name=name))
end

function command!(f::Function, c::Client, name::AbstractString, description::AbstractString; legacy::Bool=true, kwargs...)
    command!(c, f, name, description, legacy; kwargs...)
    add_command!(c; name=name, description=description, kwargs...)
end
function command!(f::Function, c::Client, g::Number, name::AbstractString, description::AbstractString; legacy::Bool=true, kwargs...)
    command!(c, f, name, description, legacy; kwargs...)
    add_command!(c, Snowflake(g); name=name, description=description, kwargs...)
end
command!(f::Function, c::Client, g::String, name::AbstractString, description::AbstractString; kwargs...) = command!(f, c, parse(Int, g), name, description; kwargs...)

function check_option(o::ApplicationCommandOption)
    namecheck(o.name, r"^[\w-]{1,32}$", 32, "ApplicationCommandOption Name")
    namecheck(o.description, 100, "ApplicationCommandOption Description")
end

namecheck(val::String, patt::Regex, len::Int, of::String) = (!occursin(patt, val) || length(val) > len) && throw(NamingError(val, of))
namecheck(val::String, patt::Regex, of::String) = namecheck(val, patt, 32, of)
namecheck(val::String, len::Int, of::String) = namecheck(val, r"", len, of)
namecheck(val::String, of::String) = namecheck(val, 32, of)

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
function component!(f::Function, c::Client, custom_id::AbstractString; auto_ack::Bool=true, auto_update_ack::Bool=true, kwargs...)
    add_handler!(c, OnInteractionCreate(f; custom_id=custom_id))
    if !auto_ack
        push!(c.no_auto_ack, custom_id)
    elseif auto_update_ack
        push!(c.auto_update_ack, custom_id)
    end
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
    hasproperty(ctx, :interaction) && handle_ack(c, ctx)
    isvalidcommand = (h) -> return (!hasproperty(h, :name) || (!ismissing(ctx.interaction.data.name) && h.name == ctx.interaction.data.name))
    isvalidcomponent = (h) -> return (!hasproperty(h, :custom_id) || (!ismissing(ctx.interaction.data.custom_id) && h.custom_id == ctx.interaction.data.custom_id))
    isvalid = (h) -> return isvalidcommand(h) && isvalidcomponent(h)
    for hh in handlers 
        isvalid(hh) && (runhandler(c, hh, ctx, t))
    end
end

function handle_ack(c::Client, ctx::Context)
    iscomp = !ismissing(ctx.interaction.data.custom_id)
    if !iscomp || !(ctx.interaction.data.custom_id in c.no_auto_ack)
        @debug "Acking interaction"
        if iscomp && (ctx.interaction.data.custom_id in c.auto_update_ack)
            update_ack_interaction(c, ctx.interaction.id, ctx.interaction.token)
        else
            ack_interaction(c, ctx.interaction.id, ctx.interaction.token)
        end
    end
end

"""
Runs a handler with given context
"""
function runhandler(c::Client, h::Handler, ctx::Context, t::Symbol) 
    @debug "Running handler" h=Handler type=t
    @spawn begin try h.f(ctx) catch e
            showerror(stderr, e)
            @warn "Got an error running handler" err=e
    end end
end

"""
Calls handle with a list of all found handlers.
"""
function handle(c::Client, t::Symbol, data::Dict)
    haskey(c.handlers, t) ? handle(c, c.handlers[t], data, t) : return nothing
end