export OnMessageCreateContext,
    OnMessageCreate,
    # Messages ↑
    OnInteractionCreate,
    OnReady,
    OnReadyContext,
    OnResumed,
    OnResumedContext,
    # Misc ↑
    OnGuildCreate,
    OnGuildCreateContext,
    OnGuildUpdate,
    OnGuildUpdateContext,
    OnGuildDelete,
    OnGuildDeleteContext,
    OnGuildMemberAdd,
    OnGuildMemberAddContext,
    # Guild ↑
    OnChannelCreate,
    OnChannelCreateContext,
    OnChannelUpdate,
    OnChannelUpdateContext, 
    OnChannelDelete,
    OnChannelDeleteContext,
    OnChannelPinsUpdate,
    OnChannelPinsUpdateContext
    # Channel ↑

abstract type AbstractHandler end
abstract type AbstractContext end

macro ctx(U::Symbol, T::Symbol) 
    n = Symbol(lowercase(String(T)))
    k = Symbol(String(U)*"Context")
    quote
        struct $k <: AbstractContext
            $n::$T
        end
    end
end

macro handler(T::Symbol)
    n = Symbol("On"*String(T))
    quote
        struct $n <: AbstractHandler 
            f::Function
        end
    end
end

macro handlerctx(T::Symbol, C::Symbol)
    event_name = String(T)
    inner = Symbol(lowercase(String(C)))
    handler_name = Symbol("On"*String(T))
    context_name = Symbol(String(handler_name)*"Context")
    handler_doc = "Handler for [`$event_name`](@ref) event"
    context_doc = "Context passed to [`$handler_name`](@ref) handler"
    quote
        struct $handler_name <: AbstractHandler
            f::Function
        end
        struct $context_name <: AbstractContext 
            $inner::$C
        end
        context(::Type{$handler_name}, data::Dict) = $context_name($C(data))
        @doc $handler_doc $handler_name
        @doc $context_doc $context_name
    end
end

@handlerctx(MessageCreate, Message)
@handlerctx(MessageUpdate, Message)
@handlerctx(MessageDelete, Message)
@handlerctx(GuildCreate, Guild)
@handlerctx(GuildUpdate, Guild)
@handlerctx(GuildDelete, Guild)
@handlerctx(ChannelCreate, Channel)
@handlerctx(ChannelUpdate, Channel)
@handlerctx(ChannelDelete, Channel)
@boilerplate OnGuildCreateContext :constructors :docs
@boilerplate OnGuildCreate :docs
@boilerplate OnGuildUpdateContext :constructors :docs
@boilerplate OnGuildUpdate :docs
@boilerplate OnMessageCreateContext :constructors :docs
@boilerplate OnMessageCreate :docs

@ctx(OnInteractionCreate, Interaction)

struct OnReadyContext <: AbstractContext 
    v::Int
    user::Optional{User}
    guilds::Vector{UnavailableGuild}
    session_id::String
    shard::Optional{Vector{Int}}
end
@boilerplate OnReadyContext :constructors
@handler(Ready)

struct OnInteractionCreate <: AbstractHandler 
    f::Function
    name::String
end

struct OnResumedContext <: AbstractContext
    _trace::Vector{String}
end
@boilerplate OnResumedContext :constructors
@handler(Resumed)

struct OnChannelPinsUpdateContext <: AbstractContext
    channel_id::Snowflake
    last_pin_timestamp::Nullable{DateTime}
end
@boilerplate OnChannelPinsUpdateContext :constructors
@handler(ChannelPinsUpdate)

struct OnGuildMemberAddContext <: AbstractContext
    guild_id::Snowflake
    member::Member
end
@boilerplate OnGuildMemberAddContext :constructors
@handler(OnGuildMemberAdd)
"""
    context(::Type{<:AbstractHandler}, data) -> AbstractContext
Generates the context for a Handler based on the given data.
"""
context(::Type{OnGuildMemberAddContext}, data::Dict) = OnGuildMemberAddContext(data)
context(::Type{OnResumed}, data::Dict) = OnResumedContext(data)
context(::Type{OnInteractionCreate}, data::Dict) = OnInteractionCreateContext(Interaction(data))
context(::Type{OnGuildUpdate}, data::Dict) = OnGuildUpdateContext(Guild(data))
context(::Type{OnMessageCreate}, data::Dict) = OnMessageCreateContext(Message(data))
context(::Type{OnReady}, data::Dict) = OnReadyContext(data)
context(::Type{OnGuildCreate}, data::Dict) = OnGuildCreateContext(Guild(data))
