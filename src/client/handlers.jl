export on_message!

# helper function
function on_message!(f::Function, c::Client) 
    sym = :OnMessageCreate
    h = eval(sym)(f)
    haskey(c.handlers, sym) ? push!(c.handlers[sym], h) : c.handlers[sym] = [h] 
end

function context(T::Type{OnMessageCreate}, data::Dict) 
    @debug "Creating context object" event=Symbol(T)
    object = Message(data)
    @debug "Created context object" context=object
    OnMessageContext(object)
end

tohandler(t::Type{<:AbstractEvent}) = Symbol("On"*String(Symbol(t)))

function handle(c::Client, handlers::Vector{<:AbstractHandler}, data::Dict) 
    @debug "Sending to handlers" logkws(c; handles=length(handlers))...
    ctx = context(eltype(handlers), data::Dict)
    @debug "Found context" context=ctx
    for h = handlers
        @debug "Running handler" handler=h.f
        @async begin 
            x = h.f(ctx)
            @debug "Got return value" ret=x
        end
    end
    @debug "Finished running handlers" 
end
function handle(c::Client, t::Symbol, data::Dict)
    haskey(c.handlers, t) ? handle(c, c.handlers[t], data) : @debug "No handlers" logkws(c; event=t)...
end
function handle(c::Client, T::Type{<:AbstractEvent}, data::Dict) 
    sym = String(tohandler(T))
    @debug "Finding handle" logkws(c; handle=sym)...
    handle(c, tohandler(T), data::Dict)
end
handle(c::Client, T::Type{<:AbstractEvent}; kwargs...) = handle(c, T, Dict(kwargs))