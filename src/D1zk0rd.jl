module D1zk0rd

using Dates
using Distributed
using HTTP
using InteractiveUtils
using JSON3
using StructTypes
using OpenTrick
using Setfield
using TimeToLive

const D1ZKORD_JL_VERSION = v"0.6.1"
const API_VERSION = 9
const DISCORD_API = "https://discordapp.com/api"

# Shortcuts for common unions.
const Optional{T} = Union{T, Missing}
const Nullable{T} = Union{T, Nothing}
const OptionalNullable{T} = Union{T, Missing, Nothing}
const StringOrChar = Union{AbstractString, AbstractChar}

# Shortcut functions .
jsonify(x) = JSON3.write(x)

# Constant functions.
donothing(args...; kwargs...) = nothing
alwaystrue(args...; kwargs...) = true
alwaysfalse(args...; kwargs...) = false

# Run a function with an acquired semaphore.
function withsem(f::Function, s::Base.Semaphore)
    Base.acquire(s)
    try f() finally Base.release(s) end
end

# Precompile all methods of a function, running it if force is set.
function compile(f::Function, force::Bool; kwargs...)
    for m in methods(f)
        types = Tuple(m.sig.types[2:end])
        precompile(f, types)
        force && try f(mock.(types; kwargs...)...) catch end
    end
end

function method_argnames(m::Method)
    argnames = ccall(:jl_uncompress_argnames, Vector{Symbol}, (Any,), m.slot_syms)
    isempty(argnames) && return argnames
    return argnames[2:m.nargs]
end

function method_argtypes(m::Method)
    return m.sig.types[2:end]
end

"""
    method_args(m::Method) -> Vector{Tuple{Symbol, Type}}
"""
function method_args(m::Method) 
    n, t, v = method_argnames(m), method_argtypes(m), []
    for x = 1:length(n)
        push!(v, (n[x], t[x]))
    end
    v
end

include(joinpath("utils", "consts.jl"))
include(joinpath("types", "types.jl"))
include(joinpath("client", "client.jl"))
include(joinpath("client", "handlers.jl"))
include(joinpath("gateway", "gateway.jl"))
include(joinpath("rest", "rest.jl"))
include(joinpath("utils", "helpers.jl"))

end