export OnMessageContext,
    OnMessageCreate,
    OnInteractionCreate,
    OnReady,
    OnReadyContext,
    OnGuildCreate,
    OnGuildCreateContext,
    OnGuildUpdate,
    OnGuildUpdateContext

abstract type AbstractHandler end
abstract type AbstractContext end

struct OnMessageContext <: AbstractContext
    message::Message
end
@boilerplate OnMessageContext :constructors

struct OnGuildCreateContext <: AbstractContext
    guild::Guild
end

struct OnGuildUpdateContext <: AbstractContext
    guild::Guild
end

struct OnInteractionCreateContext <: AbstractContext
    int::Interaction
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

struct OnInteractionCreate <: AbstractHandler 
    f::Function
    name::String
end

struct OnGuildCreate <: AbstractHandler 
    f::Function
end

struct OnGuildUpdate <: AbstractHandler 
    f::Function
end