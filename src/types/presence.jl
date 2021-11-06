export Presence

"""
A [`User`](@ref)'s presence.
More details [here](https://discordapp.com/developers/docs/topics/gateway#presence-update).
"""
struct Presence
    user::User
    roles::Optional{Vector{Snowflake}}
    game::Nullable{Activity}
    guild_id::Optional{Snowflake}
    status::String
    activities::Vector{Activity}
end
@boilerplate Presence :constructors :docs :lower :merge :mock
