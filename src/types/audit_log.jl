export AuditLog

const AUDIT_LOG_CHANGE_TYPES = Dict(
    "name"                          => (String, Guild),
    "icon_hash"                     => (String, Guild) ,
    "splash_hash"                   => (String, Guild),
    "owner_id"                      => (Snowflake, Guild),
    "region"                        => (String, Guild),
    "afk_channel_id"                => (Snowflake, Guild),
    "afk_timeout"                   => (Int, Guild),
    "mfa_level"                     => (Int, Guild),
    "verification_level"            => (Int, Guild),
    "explicit_content_filter"       => (Int, Guild),
    "default_message_notifications" => (Int, Guild),
    "vanity_url_code"               => (String, Guild),
    "\$add"                         => (Vector{Role}, Guild),
    "\$remove"                      => (Vector{Role}, Guild),
    "prune_delete_days"             => (Int, Guild),
    "widget_enabled"                => (Bool, Guild),
    "widget_channel_id"             => (Snowflake, Guild),
    "position"                      => (Int, DiscordChannel),
    "topic"                         => (String, DiscordChannel),
    "bitrate"                       => (Int, DiscordChannel),
    "permission_overwrites"         => (Vector{Overwrite}, DiscordChannel),
    "nsfw"                          => (Bool, DiscordChannel),
    "application_id"                => (Snowflake, DiscordChannel),
    "permissions"                   => (String, Role),
    "color"                         => (Int, Role),
    "hoist"                         => (Bool, Role),
    "mentionable"                   => (Bool, Role),
    "allow"                         => (Int, Role),
    "deny"                          => (Int, Role),
    "code"                          => (String, Invite),
    "channel_id"                    => (Snowflake, Invite),
    "inviter_id"                    => (Snowflake, Invite),
    "max_uses"                      => (Int, Invite),
    "uses"                          => (Int, Invite),
    "max_age"                       => (Int, Invite),
    "temporary"                     => (Bool, Invite),
    "deaf"                          => (Bool, User),
    "mute"                          => (Bool, User),
    "nick"                          => (String, User),
    "avatar_hash"                   => (String, User),
    "id"                            => (Snowflake, Any),
    "type"                          => (Any, Any),
    # Undocumented.
    "rate_limit_per_user"           => (Int, DiscordChannel),
)

"""
A change item in an [`AuditLogEntry`](@ref).

The first type parameter is the type of `new_value` and `old_value`. The second is the type
of the entity that `new_value` and `old_value` belong(ed) to.

More details [here](https://discordapp.com/developers/docs/resources/audit-log#audit-log-change-object).
"""
struct AuditLogChange{T, U}
    new_value::Optional{T}
    old_value::Optional{T}
    key::String
    type::Type{U}
end
@boilerplate AuditLogChange :docs :mock

AuditLogChange(d::Dict{Symbol, Any}) = AuditLogChange(; d...)
function AuditLogChange(; kwargs...)
    return if haskey(AUDIT_LOG_CHANGE_TYPES, kwargs[:key])
        T, U = AUDIT_LOG_CHANGE_TYPES[kwargs[:key]]
        func = if T === Any
            identity
        elseif T === Snowflake
            snowflake
        elseif T <: Vector
            eltype(T)
        else
            T
        end

        new_value = if haskey(kwargs, :new_value)
            if kwargs[:new_value] isa Vector
                func.(kwargs[:new_value])
            else
                func(kwargs[:new_value])
            end
        else
            missing
        end
        old_value = if haskey(kwargs, :old_value)
            if kwargs[:old_value] isa Vector
                func.(kwargs[:old_value])
            else
                func(kwargs[:old_value])
            end
        else
            missing
        end

        AuditLogChange{T, U}(new_value, old_value, kwargs[:key], U)
    else
        AuditLogChange{Any, Any}(
            get(kwargs, :new_value, missing),
            get(kwargs, :old_value, missing),
            kwargs[:key],
            Any,
        )
    end
end

"""
Optional information in an [`AuditLogEntry`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/audit-log#audit-log-entry-object-optional-audit-entry-info).
"""
struct AuditLogOptions <: DiscordObject
    delete_member_days::Optional{Int}
    members_removed::Optional{Int}
    channel_id::Optional{Snowflake}
    count::Optional{Int}
    id::Optional{Snowflake}
    type::Optional{Int}
    role_name::Optional{String}
end
@boilerplate AuditLogOptions :docs :merge :mock

AuditLogOptions(d::Dict{Symbol, Any}) = AuditLogOptions(; d...)
function AuditLogOptions(; kwargs...)
    dmd = if haskey(kwargs, :delete_member_days)
        parse(Int, kwargs[:delete_member_days])
    else
        missing
    end
    return AuditLogOptions(
        dmd,
        haskey(kwargs, :members_removed) ? parse(Int, kwargs[:members_removed]) : missing,
        haskey(kwargs, :channel_id) ? snowflake(kwargs[:channel_id]) : missing,
        haskey(kwargs, :count) ? parse(Int, kwargs[:count]) : missing,
        haskey(kwargs, :id) ? snowflake(kwargs[:id]) : missing,
        haskey(kwargs, :type) ? OverwriteType(kwargs[:type]) : missing,
        get(kwargs, :role_name, missing),
    )
end

"""
An entry in an [`AuditLog`](@ref).
More details [here](https://discordapp.com/developers/docs/resources/audit-log#audit-log-entry-object).
"""
struct AuditLogEntry
    target_id::Nullable{Snowflake}
    changes::Optional{Vector{AuditLogChange}}
    user_id::Snowflake
    id::Snowflake
    action_type::Int
    options::Optional{AuditLogOptions}
    reason::Optional{String}
end
@boilerplate AuditLogEntry :constructors :docs :lower :merge :mock

"""
An audit log.
More details [here](https://discordapp.com/developers/docs/resources/audit-log#audit-log-object).
"""
struct AuditLog
    webhooks::Vector{Webhook}
    users::Vector{User}
    audit_log_entries::Vector{AuditLogEntry}
end
@boilerplate AuditLog :constructors :docs :lower :merge :mock
