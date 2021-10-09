export on_message!,
    on_ready!

# just-a-shortcut function
on_message!(f::Function, c::Client) = add_handler!(c, OnMessageCreate(f))
on_ready!(f::Function, c::Client) = add_handler!(c, OnReady(f))
function command!(f::Function, c::Client, name::AbstractString, description::AbstractString; kwargs...)
    begin
        for app = retrieve(c, Vector{ApplicationCommand})
            app.name == name && return false
        end
        true
    end && create(c, name, description; kwargs...)
    command!(f, c)
end
function command!(f::Function, c::Client, g::Guild, name::AbstractString, description::AbstractString; kwargs...)
    begin
        for app = retrieve(c, Vector{ApplicationCommand}, g)
            app.name == name && return false
        end
        true
    end && create(c, name, description, g; kwargs...)
    command!(f, c)
end
command!(f::Function, c::Client) = add_handler!(c, OnInteractionCreate(f))

context(::Type{OnInteractionCreate}, data::Dict) = OnInteractionCreateContext(Interaction(data))
context(::Type{OnGuildUpdate}, data::Dict) = OnGuildUpdateContext(Guild(data))
context(::Type{OnMessageCreate}, data::Dict) = OnMessageContext(Message(data))
context(::Type{OnReady}, data::Dict) = OnReadyContext(data)
context(::Type{OnGuildCreate}, data::Dict) = OnGuildCreateContext(Guild(data))

tohandler(t::Type{<:AbstractEvent}) = Symbol("On"*String(Symbol(t)))

function handle(c::Client, handlers::Vector{<:AbstractHandler}, data::Dict)
    ctx = context(eltype(handlers), data::Dict)
    for h = handlers
        f = h.f
        @spawn begin 
            try
                f(ctx)
            catch
                return
            end
        end
    end
    @debug "Finished running handlers" 
end
function handle(c::Client, t::Symbol, data::Dict)
    haskey(c.handlers, t) ? handle(c, c.handlers[t], data) : @debug "No handlers" logkws(c; event=t)...
end
handle(c::Client, T::Type{<:AbstractEvent}, data::Dict) = handle(c, tohandler(T), data::Dict)
handle(c::Client, T::Type{<:AbstractEvent}; kwargs...) = handle(c, T, Dict(kwargs))