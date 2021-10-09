export Client,
    me,
    enable_cache!,
    disable_cache!,
    start

include("limiter.jl")
include("state.jl")

# Messages are created regularly, and lose relevance quickly.
const DEFAULT_STRATEGIES = Dict{DataType, CacheStrategy}(
    Guild          => CacheForever(),
    DiscordChannel => CacheForever(),
    User           => CacheForever(),
    Member         => CacheForever(),
    Presence       => CacheForever(),
    Message        => CacheTTL(Hour(6)),
)

# A versioned WebSocket connection.
mutable struct Conn
    io
    v::Int
end

"""
    Client(
        token::String;
        prefix::String="",
        presence::Union{Dict, NamedTuple}=Dict(),
        strategies::Dict{DataType, <:CacheStrategy}=Dict(),
        version::Int=$API_VERSION,
    ) -> Client

A Discord bot. `Client`s can connect to the gateway, respond to events, and make REST API
calls to perform actions such as sending/deleting messages, kicking/banning users, etc.

### Bot Token
A bot token can be acquired by creating a new application
[here](https://discordapp.com/developers/applications). Make sure not to hardcode the token
into your Julia code! Use an environment variable or configuration file instead.

### Command Prefix
The `prefix` keyword specifies the command prefix, which is used by commands added with
[`add_command!`](@ref). It can be changed later, both globally and on a per-guild basis,
with [`set_prefix!`](@ref).

### Presence
The `presence` keyword sets the bot's presence upon connection. It also sets defaults
for future calls to [`set_game`](@ref). The schema
[here](https://discordapp.com/developers/docs/topics/gateway#update-status-gateway-status-update-structure)
must be followed.

### Cache Control
By default, most data that comes from Discord is cached for later use. However, to avoid
memory leakage, not all of it is kept forever. The default setings are to keep everything
but [`Message`](@ref)s, which are deleted after 6 hours, forever. Although the default
settings are sufficient for most workloads, you can specify your own strategies per type
with the `strategies` keyword. Keys can be any of the following:

- [`Guild`](@ref)
- [`DiscordChannel`](@ref)
- [`Message`](@ref)
- [`User`](@ref)
- [`Member`](@ref)
- [`Presence`](@ref)

For potential values, see [`CacheStrategy`](@ref).

The cache can also be disabled/enabled permanently and temporarily as a whole with
[`enable_cache!`](@ref) and [`disable_cache!`](@ref).

### API Version
The `version` keyword chooses the Version of the Discord API to use. Using anything but
`$API_VERSION` is not officially supported by the Discord.jl developers.

### Sharding
Sharding is handled automatically. The number of available processes is the number of
shards that are created. See the
[sharding example](https://github.com/Xh4H/Discord.jl/blob/master/examples/sharding.jl)
for more details.
"""
mutable struct Client
    token::AbstractString                             # Bot token
    application_id::Snowflake                         # Application ID for Interactions
    intents::Int                                      # Intents value
    handlers::Dict{Symbol, Vector{<:AbstractHandler}} # Handlers for each event
    hb_interval::Int                                  # Milliseconds between heartbeats.
    hb_seq::Nullable{Int}                             # Sequence value sent by Discord for resuming.
    last_hb::DateTime                                 # Last heartbeat send.
    last_ack::DateTime                                # Last heartbeat ack.
    version::Int                                      # Discord API version.
    state::State                                      # Client state, cached data, etc.
    shards::Int                                       # Number of shards in use.
    shard::Int                                        # Client's shard index.
    limiter::Limiter                                  # Rate limiter.
    ready::Bool                                       # Client is connected and authenticated.
    use_cache::Bool                                   # Whether or not to use the cache.
    presence::Dict                                    # Default presence options.
    conn::Conn                                        # WebSocket connection.
    p_guilds::Dict{Snowflake, String}                 # Command prefix overrides.

    function Client(
        token::String,
        application_id::Snowflake,
        intents::Int;
        # kwargs
        presence::Union{Dict, NamedTuple}=Dict(),
        strategies::Dict{DataType, <:CacheStrategy}=Dict{DataType, CacheStrategy}(),
        version::Int=API_VERSION,
    )
        token = startswith(token, "Bot ") ? token : "Bot $token"
        state = State(merge(DEFAULT_STRATEGIES, strategies))
        app_id = application_id
        conn = Conn(nothing, 0)
        presence = merge(Dict(
            "since" => nothing,
            "game" => nothing,
            "status" => PS_ONLINE,
            "afk" => false,
        ), Dict(string(k) => v for (k, v) in Dict(pairs(presence))))
        
        c = new(
            token,        # token
            app_id,       # application_id
            intents,      # intents
            Dict(),       # handlers
            0,            # hb_interval
            nothing,      # hb_seq
            DateTime(0),  # last_hb
            DateTime(0),  # last_ack
            version,      # version
            state,        # state
            nprocs(),     # shards
            myid() - 1,   # shard
            Limiter(),    # limiter
            false,        # ready
            true,         # use_cache
            presence,     # presence
            conn,         # conn
            Dict(),       # p_guilds
        )

        return c
    end
end

Client(token::String, appid::Int, intents::Int, args...) = Client(token, UInt(appid), intents, args...)

# TODO: clean
function add_handler!(c::Client, handler::AbstractHandler) 
    handle = Symbol(typeof(handler))
    haskey(c.handlers, handle) ? c.handlers[handle] = push!(c.handlers[handle], handler) : c.handlers[handle] = [handler]
end
add_handler!(c::Client, args...) = map(h -> add_handler(c, h), args)

mock(::Type{Client}; kwargs...) = Client("token")

function Base.show(io::IO, c::Client)
    print(io, "Discord.Client(shard=$(c.shard + 1)/$(c.shards), api=$(c.version), ")
    isopen(c) || print(io, "not ")
    print(io, "logged in)")
end

"""
    me(c::Client) -> Nullable{User}

Get the [`Client`](@ref)'s bot user.
"""
me(c::Client) = c.state.user

"""
    enable_cache!(c::Client)
    enable_cache!(f::Function c::Client)

Enable the cache. `do` syntax is also accepted.
"""
enable_cache!(c::Client) = c.use_cache = true
enable_cache!(f::Function, c::Client) = set_cache(f, c, true)

"""
    disable_cache!(c::Client)
    disable_cache!(f::Function, c::Client)

Disable the cache. `do` syntax is also accepted.
"""
disable_cache!(c::Client) = c.use_cache = false
disable_cache!(f::Function, c::Client) = set_cache(f, c, false)

# Compute some contextual keywords for log messages.
function logkws(c::Client; kwargs...)
    kws = Pair[:time => now()]
    c.shards > 1 && push!(kws, :shard => c.shard)
    c.conn.io === nothing || push!(kws, :conn => c.conn.v)

    for kw in kwargs
        if kw.second === undef  # Delete any keys overridden with undef.
            filter!(p -> p.first !== kw.first, kws)
        else
            # Replace any overridden keys.
            idx = findfirst(p -> p.first === kw.first, kws)
            if idx === nothing
                push!(kws, kw)
            else
                kws[idx] = kw
            end
        end
    end

    return kws
end

# Parse some data (usually a Dict from JSON), or return the thrown error.
function Base.tryparse(c::Client, T::Type, data)
    return try
        T <: Vector ? eltype(T).(data) : T(data), nothing
    catch e
        kws = logkws(c; T=T, exception=(e, catch_backtrace()))
        @error "Parsing failed" kws...
        nothing, e
    end
end

# Run some function with the cache enabled or disabled.
function set_cache(f::Function, c::Client, use_cache::Bool)
    old = c.use_cache
    c.use_cache = use_cache
    try
        f()
    finally
        # Usually the above function is going to be calling REST endpoints. The cache flag
        # is checked asynchronously, so by the time it happens there's a good chance we've
        # already returned and set the cache flag back to its original value.
        sleep(Millisecond(1))
        c.use_cache = old
    end
end

function start(c::Client)
    hcreate = OnGuildCreate() do (ctx)
        put!(c.state, ctx.guild)
    end
    hupdate = OnGuildUpdate() do (ctx)
        put!(c.state, ctx.guild)
    end
    add_handler!(c, hcreate, hupdate)

    open(c)
    wait(c)
end