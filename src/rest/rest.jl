export fetchval

const SHOULD_SEND = Dict(:PATCH => true, :POST => true, :PUT => true)

"""
A wrapper around a response from the REST API. Every function which wraps a Discord REST
API endpoint returns a `Future` which will contain a value of this type. To retrieve the
`Response` from the `Future`, use `fetch`. See also: [`fetchval`](@ref).

## Fields
- `val::Nullable{T}`: The object contained in the HTTP response. For example, for a
  call to [`get_channel_message`](@ref), this value will be a [`Message`](@ref).
- `ok::Bool`: The state of the request. If `true`, then it is safe to access `val`.
- `http_response::Nullable{HTTP.Messages.Response}`: The underlying HTTP response, if
  a request was made.
- `exception::Nullable{Exception}`: The caught exception, if one is thrown.

## Examples
Multiple API calls which immediately return `Future`s and can be awaited:
```julia
futures = map(i -> create_message(c, channel_id; content=string(i)), 1:10);
other_work_here()
resps = fetch.(futures)
```
Skipping error checks and returning the value directly:
```julia
guild = fetchval(create_guild(c; name="foo"))
```
"""
struct Response{T}
    val::Nullable{T}
    ok::Bool
    http_response::Nullable{HTTP.Messages.Response}
    exception::Nullable{Exception}
end

# HTTP response with no body.
function Response{Nothing}(r::HTTP.Messages.Response)
    return Response{Nothing}(nothing, r.status < 300, r, nothing)
end

# HTTP response with body (maybe).
function Response{T}(c::Client, r::HTTP.Messages.Response) where T
    if T == Nothing 
        return Response{Nothing}(r)
    end
    r.status == 204 && return Response{T}(nothing, true, r, nothing)
    r.status >= 300 && return Response{T}(nothing, false, r, nothing)

    val = if HTTP.header(r, "Content-Type") == "application/json"
        symbolize(JSON3.read(String(copy(r.body)), T))
    else
        copy(r.body)
    end

    return Response{T}(val, true, r, nothing)
end

# HTTP request with no expected response body.
function Response(
    c::Client,
    method::Symbol,
    endpoint::AbstractString;
    body="",
    kwargs...
)
    return Response{Nothing}(c, method, endpoint; body=body, kwargs...)
end

# HTTP request.
function Response{T}(
    c::Client,
    method::Symbol,
    endpoint::AbstractString,
    cachetest::Function=alwaystrue;
    headers=Dict(),
    body=HTTP.nobody,
    kwargs...
) where T
    f = Future()
    @spawn begin
        kws = (
            channel=cap("channels", endpoint),
            guild=cap("guilds", endpoint),
            message=cap("messages", endpoint),
            user=cap("users", endpoint),
        )

        # Retrieve the value from the cache, maybe.
        @debug "Preparing Request: Looking in cache" Time=now()
        if c.use_cache && method === :GET
            val = get(c.state, T; kws...)
            if val !== nothing
                try
                    # Only use the value if it satisfies the cache test.
                    if cachetest(val) === true
                        put!(f, Response{T}(val, true, nothing, nothing))
                        return
                    end
                catch
                    # TODO: Log this?
                end
            end
        end
        # Prepare the request.
        url = "$DISCORD_API/v$(c.version)$endpoint"
        @debug "Preparing Request: Did not find in cache, preparing request" Time=now()
        isempty(kwargs) || (url *= "?" * HTTP.escapeuri(kwargs))
        headers = merge(Dict(
            "User-Agent" => "Discord.jl $DISCORD_JL_VERSION",
            "Content-Type" => "application/json",
            "Authorization" => c.token,
        ), Dict(headers))
        args = [method, url, headers]
        @debug "Preparing Request: Type of request: $T" Time=now()
        if get(SHOULD_SEND, method, false)
            push!(args, headers["Content-Type"] == "application/json" ? JSON3.write(body) : body)
        end

        @debug "Preparing Request: Enqueuing request" Time=now()
        # Queue a job to be run within the rate-limiting constraints.
        enqueue!(c.limiter, method, endpoint) do
            @debug "Enqueued job running"
            http_r = nothing

            try
                # Make an HTTP request, and generate a Response.
                # If we hit an upstream rate limit, return the response immediately.
                http_r = HTTP.request(args...; status_exception=false)
                @debug "Sent http request" Time=now()
                if http_r.status - 200 >= 100 
                    @warn "Got an unexpected response" To=args[2] Code=http_r.status Body=http_r Sent=args[4]
                end
                http_r.status == 429 && return http_r
                r = Response{T}(c, http_r)

                if r.ok && r.val !== nothing
                    # Cache the value, and also replace any missing data
                    # in the response with data from the cache.
                    r = @set r.val = put!(c.state, r.val; kws...)
                end

                # Store the successful Response to the Future.
                put!(f, r)
                @debug "Got response"
            catch e
                kws = logkws(c; conn=undef, exception=(e, catch_backtrace()))
                @error "Creating response failed" kws...
                put!(f, Response{T}(nothing, false, http_r, e))
            end
            
            @debug "Request completed" url=args[2]
            return http_r
        end
    end
    @debug "Returning future" Time=now()
    return f
end

Base.eltype(::Response{T}) where T = T
Base.eltype(::Type{Response{T}}) where T = T

"""
    fetchval(f::Future{Response{T}}) -> Nullable{T}

Shortcut for `fetch(f).val`: Fetch a [`Response`](@ref) and return its value. Note that
there are no guarantees about the response's success and the value being returned, and it
discards context that can be useful for debugging, such as HTTP responses and caught
exceptions.
"""
fetchval(f::Future) = fetch(f).val

# Capture an ID from a string.
function cap(path::AbstractString, s::AbstractString)
    m = match(Regex("/$path/(\\d+)"), s)
    return m === nothing ? nothing : parse(Snowflake, first(m.captures))
end

include(joinpath("endpoints", "endpoints.jl"))
include(joinpath("crud", "crud.jl"))
