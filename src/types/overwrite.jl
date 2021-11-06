export Overwrite

"""
A permission overwrite.
More details [here](https://discordapp.com/developers/docs/resources/channel#overwrite-object).
"""
struct Overwrite <: DiscordObject
    id::Snowflake 
    type::Int
    allow::String
    deny::String
end
@boilerplate Overwrite :constructors :docs :lower :merge :mock
