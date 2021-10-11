export on_message!,
    on_ready!,
    command!

# shortcut functions
on_message!(f::Function, c::Client) = add_handler!(c, OnMessageCreate(f))
on_ready!(f::Function, c::Client) = add_handler!(c, OnReady(f))
function command!(f::Function, c::Client, name::AbstractString, description::AbstractString; kwargs...)
    add_handler!(c, OnInteractionCreate(f, name))
    add_command!(c; name=name, description=description, kwargs...)
end
function command!(f::Function, c::Client, g::Int64, name::AbstractString, description::AbstractString; kwargs...)
    add_handler!(c, OnInteractionCreate(f, name))
    add_command!(c, Snowflake(g); name=name, description=description, kwargs...)
end

context(::Type{OnInteractionCreate}, data::Dict) = OnInteractionCreateContext(Interaction(data))
context(::Type{OnGuildUpdate}, data::Dict) = OnGuildUpdateContext(Guild(data))
context(::Type{OnMessageCreate}, data::Dict) = OnMessageContext(Message(data))
context(::Type{OnReady}, data::Dict) = OnReadyContext(data)
context(::Type{OnGuildCreate}, data::Dict) = OnGuildCreateContext(Guild(data))

tohandler(t::Type{<:AbstractEvent}) = Symbol("On"*String(Symbol(t)))

function handle(c::Client, handlers::Vector{<:AbstractHandler}, data::Dict)
    ctx = context(eltype(handlers), data::Dict)
    for h = handlers
        if !(h isa OnInteractionCreate) || h.name == ctx.int.data.name
            f = h.f
            @spawn begin 
                try
                    f(ctx)
                catch err
                    @error "Running handlers unexpectedly errored" event=eltype(handlers) error=err
                    println(err)
                end
            end
        end
    end
end
function handle(c::Client, t::Symbol, data::Dict)
    haskey(c.handlers, t) ? handle(c, c.handlers[t], data) : return nothing
end
handle(c::Client, T::Type{<:AbstractEvent}, data::Dict) = handle(c, tohandler(T), data::Dict)
handle(c::Client, T::Type{<:AbstractEvent}; kwargs...) = handle(c, T, Dict(kwargs))