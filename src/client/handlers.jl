export command!,
    component!,
    modal!
    
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
function command!(c::Client, f::Function, name::AbstractString, desc::AbstractString, legacy::Bool; auto_ack=true, kwargs...)
    haskey(kwargs, :options) && check_option.(kwargs[:options])
    namecheck(name, r"^[\w-]{1,32}$", 32, "ApplicationCommand Name")
    namecheck(name, 100, "ApplicationCommand Description")
    if !auto_ack push!(c.no_auto_ack, name) end
    legacy ? add_handler!(c, OnInteractionCreate(f; name=name)) : add_handler!(c, OnInteractionCreate(generate_command_func(f); name=name))
end

function command!(f::Function, c::Client, name::AbstractString, description::AbstractString; legacy::Bool=true, auto_ack=true, kwargs...)
    command!(c, f, name, description, legacy; auto_ack=auto_ack, kwargs...)
    add_command!(c; name=name, description=description, kwargs...)
end
function command!(f::Function, c::Client, g::Number, name::AbstractString, description::AbstractString; legacy::Bool=true, auto_ack=true, kwargs...)
    command!(c, f, name, description, legacy; auto_ack=auto_ack, kwargs...)
    add_command!(c, Snowflake(g); name=name, description=description, kwargs...)
end
command!(f::Function, c::Client, g::String, name::AbstractString, description::AbstractString; kwargs...) = command!(f, c, parse(Int, g), name, description; kwargs...)

function modal!(f::Function, c::Client, custom_id::String, int::Interaction; kwargs...)
    add_handler!(c, OnInteractionCreate(generate_command_func(f), custom_id=custom_id))
    push!(c.no_auto_ack, custom_id)
    respond_to_interaction_with_a_modal(c, int.id, int.token; custom_id=custom_id, kwargs...)
end
modal!(f::Function, c::Client, custom_id::String, ctx::Context; kwargs...) = modal!(f, c, custom_id, ctx.interaction; compkwfix(; kwargs...)...)

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
    v = []
    args = args[2:end]
    if length(args) == 0
        return v
    end
    o = opt(ctx)
    for x = args 
        t = last(x)
        arg =  get(o, string(first(x)), :ERR)
        push!(v, conv(t, arg, ctx))
    end
    v
end

function conv(::Type{T}, arg, ctx::Context) where T
    if T in [String, Int, Bool, Any] 
        return arg 
    end
    id = snowflake(arg)
    if T == User 
        return ctx.interaction.data.resolved.users[id]
    elseif T == Member
        u = ctx.interaction.data.resolved.users[id]
        m = ctx.interaction.data.resolved.members[id]
        m.user = u
        return m 
    elseif T == Role 
        return ctx.interaction.data.resolved.roles[id]
    elseif T == DiscordChannel 
        return ctx.interaction.data.resolved.channels[id]
    end
    arg
end

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
    if !auto_ack push!(c.no_auto_ack, custom_id) end
    if auto_update_ack push!(c.auto_update_ack, custom_id) end
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
    @debug "$(repr.(handlers))" currrent = repr(ctx)
    for hh in handlers 
        isvalid(hh) && (runhandler(c, hh, ctx, t))
    end
end

function handle_ack(c::Client, ctx::Context)
    iscomp = !ismissing(ctx.interaction.data.custom_id)
    !ismissing(ctx.interaction.data.type) && ctx.interaction.data.type == 5 && return
    if !iscomp || !(ctx.interaction.data.custom_id in c.no_auto_ack)
        @debug "Acking interaction" name=ctx.interaction.data.name custom_id=ctx.interaction.data.custom_id
        if iscomp && (ctx.interaction.data.custom_id in c.auto_update_ack)
            update_ack_interaction(c, ctx.interaction.id, ctx.interaction.token)
        elseif (!ismissing(ctx.interaction.data.name) && !(ctx.interaction.data.name in c.no_auto_ack)) || iscomp
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
            kws = logkws(c; handler=t, exception=(e, catch_backtrace()))
            @warn "Handler errored" kws...
    end end
end

"""
Calls handle with a list of all found handlers.
"""
function handle(c::Client, t::Symbol, data::Dict)
    haskey(c.handlers, t) ? handle(c, c.handlers[t], data, t) : return nothing
end