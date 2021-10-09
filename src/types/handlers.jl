export OnMessageContext,
    OnMessageCreate,
    OnReady,
    OnReadyContext,
    OnGuildCreate,
    OnGuildCreateContext


abstract type AbstractHandler end
abstract type AbstractContext end

struct OnMessageContext <: AbstractContext
    message::Message
end
@boilerplate OnMessageContext :constructors

struct OnGuildCreateContext <: AbstractContext
    guild::Guild
end

struct OnReadyContext <: AbstractContext 
    v::Int
    user::Optional{User}
    guilds::Vector{UnavailableGuild}
    session_id::String
    shard::Optional{Vector{Int}}
end
@boilerplate OnReadyContext :constructors

struct OnReady <: AbstractHandler 
    f::Function
end
"""
Handler for a `Message Create` event
"""
struct OnMessageCreate <: AbstractHandler 
    f::Function
end

struct OnGuildCreate <: AbstractHandler 
    f::Function
end