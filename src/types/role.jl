export Role

"""
A [`User`](@ref) role.
More details [here](https://discordapp.com/developers/docs/topics/permissions#role-object).
"""
struct Role <: DiscordObject
    id::Snowflake
    name::String
    color::Optional{Int}  # These fields are missing in audit log entries.
    hoist::Optional{Bool}
    position::Optional{Int}
    permissions::Optional{String}
    managed::Optional{Bool}
    mentionable::Optional{Bool}
end
@boilerplate Role :constructors :docs :lower :merge :mock
