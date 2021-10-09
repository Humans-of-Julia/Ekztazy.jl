export on_message!,
    on_ready!

# helper function
on_message!(f::Function, c::Client) = add_handler(c, OnMessageCreate(f))

on_ready!(f::Function, c::Client) = add_handler(c, OnReady(f))


function context(T::Type{OnMessageCreate}, data::Dict) 
    @debug "Creating context object" event=Symbol(T)
    object = Message(data)
    @debug "Created context object" context=object
    OnMessageContext(object)
end

context(::Type{OnReady}, data::Dict) = OnReadyContext(data)

tohandler(t::Type{<:AbstractEvent}) = Symbol("On"*String(Symbol(t)))

function handle(c::Client, handlers::Vector{<:AbstractHandler}, data::Dict) 
    @debug "Sending to handlers" logkws(c; handles=length(handlers))...
    ctx = context(eltype(handlers), data::Dict)
    @debug "Found context" context=ctx
    for h = handlers
        @debug "Running handler" handler=h.f
        future = @spawn begin 
            fut = Future()
            print(ctx)
            @spawn h.f(ctx)
            @debug "Got return value" ret=x
            put!(fut, x)
            fut
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