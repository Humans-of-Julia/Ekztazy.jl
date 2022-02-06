export Handler,
    Context

const EVENT_TYPES = Dict{String, Symbol}(
    "READY"                       => :Ready,
    "RESUMED"                     => :Resumed,
    "CHANNEL_CREATE"              => :ChannelCreate,
    "CHANNEL_UPDATE"              => :ChannelUpdate,
    "CHANNEL_DELETE"              => :ChannelDelete,
    "CHANNEL_PINS_UPDATE"         => :ChannelPinsUpdate,
    "GUILD_CREATE"                => :GuildCreate,
    "GUILD_UPDATE"                => :GuildUpdate,
    "GUILD_DELETE"                => :GuildDelete,
    "GUILD_BAN_ADD"               => :GuildBanAdd,
    "GUILD_BAN_REMOVE"            => :GuildBanRemove,
    "GUILD_EMOJIS_UPDATE"         => :GuildEmojisUpdate,
    "GUILD_INTEGRATIONS_UPDATE"   => :GuildIntegrationsUpdate,
    "GUILD_MEMBER_ADD"            => :GuildMemberAdd,
    "GUILD_MEMBER_REMOVE"         => :GuildMemberRemove,
    "GUILD_MEMBER_UPDATE"         => :GuildMemberUpdate,
    "GUILD_MEMBERS_CHUNK"         => :GuildMembersChunk,
    "GUILD_ROLE_CREATE"           => :GuildRoleCreate,
    "GUILD_ROLE_UPDATE"           => :GuildRoleUpdate,
    "GUILD_ROLE_DELETE"           => :GuildRoleDelete,
    "MESSAGE_CREATE"              => :MessageCreate,
    "MESSAGE_UPDATE"              => :MessageUpdate,
    "MESSAGE_DELETE"              => :MessageDelete,
    "MESSAGE_DELETE_BULK"         => :MessageDeleteBulk,
    "MESSAGE_REACTION_ADD"        => :MessageReactionAdd,
    "MESSAGE_REACTION_REMOVE"     => :MessageReactionRemove,
    "MESSAGE_REACTION_REMOVE_ALL" => :MessageReactionRemoveAll,
    "INTERACTION_CREATE"          => :InteractionCreate,
    "PRESENCE_UPDATE"             => :PresenceUpdate,
    "TYPING_START"                => :TypingStart,
    "USER_UPDATE"                 => :UserUpdate,
    "VOICE_STATE_UPDATE"          => :VoiceStateUpdate,
    "VOICE_SERVER_UPDATE"         => :VoiceServerUpdate,
    "WEBHOOKS_UPDATE"             => :WebhooksUpdate,
)

""" 
    Handler(
        f::Function
        d::Dict{Symbol, Any}
    )

Handler is a wrapper for a `Dict{Symbol, Any}` that also contains a function.
"""
struct Handler 
    f::Function
    d::Dict{Symbol, Any}
end

"""
    Handler(; kwargs...) -> Handler

Generates a handler based on kwargs and a function.
"""
Handler(f; kwargs...) = Handler(f, Dict(kwargs))

"""
    Context(
        data::Dict{Symbol, Any}
    )

Context is a wrapper for a `Dict{Symbol, Any}` with some special functionality.
"""
struct Context 
    data::Dict{Symbol, Any}
end
"""
    Context(; kwargs...) -> Context

Generates a context based on kwargs.
"""
Context(; kwargs...) = Context(Dict(kwargs))


context(data::Dict{Symbol, Any}) = Context(data)
"""
    context(t::Symbol, data::Dict{Symbol, Any}) -> Context 

Checks if the Context needs to be created in a special way based on the event provided by `t`.\n 
Then, returns the generated context.
"""
function context(t::Symbol, data::Dict{Symbol, Any})
    t == :OnMessageCreate && return Context(; message=Message(data))
    t ∈ [:OnGuildCreate, :OnGuildUpdate] && return Context(; guild=Guild(data))
    t ∈ [:OnMessageReactionAdd, :OnMessageReactionRemove] && return Context(; 
        emoji=make(Emoji, data, :emoji), 
        channel=DiscordChannel(; id=data[:channel_id]),
        message=Message(; id=data[:message_id], channel_id=data[:channel_id]), 
        data...)
    t  == :OnReady && return Context(; user=make(User, data, :user), data...)
    t == :OnInteractionCreate && return Context(; interaction=Interaction(data))
    Context(data)
end

make(::Type{T}, data::Dict{Symbol, Any}, k::Symbol) where T <: DiscordObject = T(pop!(data, k, missing))

for v in values(EVENT_TYPES)
    nm = Symbol("On"*String(v))
    @eval ($nm)(f::Function; kwargs...) = Handler(f; type=Symbol($nm), kwargs...)
end

Base.getproperty(ctx::Context, sym::Symbol) = getfield(ctx, :data)[sym]
Base.hasproperty(ctx::Context, sym::Symbol) = haskey(getfield(ctx, :data), sym)

Base.getproperty(h::Handler, sym::Symbol) = sym != :f ? getfield(h, :d)[sym] : getfield(h, sym)
Base.hasproperty(h::Handler, sym::Symbol) = haskey(getfield(h, :d), sym)

handlerkind(h::Handler) = h.type
handlerargs(f::Function) = method_args(first(methods(f)))
