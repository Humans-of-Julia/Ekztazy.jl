export OnMessageContext,
    OnMessageCreate
    
macro named(T) 
    quote
        name(x::$T) = Symbol($T)
    end
end

macro name(T) 
    quote
        Symbol($T)
    end
end

abstract type AbstractHandler end
abstract type AbstractContext end

struct OnMessageContext <: AbstractContext
    message::Message
end
@boilerplate OnMessageContext :constructors

"""
Handler for a `Message Create` event
"""
struct OnMessageCreate <: AbstractHandler 
    f::Function
end
@named OnMessageCreate