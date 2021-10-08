const MESSAGES_REGEX = r"^/channels/\d+/messages/\d+$"
const ENDS_MAJOR_ID_REGEX = r"(?:channels|guilds|webhooks)/\d+$"
const ENDS_ID_REGEX = r"/\d+$"
const EXCEPT_TRAILING_ID_REGEX = r"(.*?)/\d+$"

# A rate limited job queue for one endpoint.
mutable struct JobQueue
    remaining::Nullable{Int}
    reset::Nullable{DateTime}  # UTC.
    jobs::Channel{Function}  # These functions must return an HTTP response.
    retries::Channel{Function}  # Jobs which must be retried (higher priority).

    function JobQueue(endpoint::AbstractString, limiter)
        q = new(nothing, nothing, Channel{Function}(Inf), Channel{Function}(Inf))

        @spawn while true
            # Get a job, prioritizing retries. This is really ugly.
            local f = nothing
            while true
                @debug "Waiting for jobs"
                if isready(q.retries)
                    f = take!(q.retries)
                    break
                elseif isready(q.jobs)
                    f = take!(q.jobs)
                    break
                end
                sleep(Millisecond(10))
            end

            # Wait for any existing rate limits.
            # TODO: Having the shard index would be nice for logging here.
            n = now(UTC)
            if limiter.reset !== nothing && n < limiter.reset
                time = limiter.reset - n
                @debug "Waiting for global rate limit" time=now() sleep=time
                sleep(time)
            end
            n = now(UTC)
            if q.remaining == 0 && q.reset !== nothing && n < q.reset
                time = q.reset - n
                @debug "Waiting for rate limit" time=now() endpoint=endpoint sleep=time
                sleep(time)
            end

            # Run the job, and get the HTTP response.
            r = f()
            @debug "Ran the job!"

            if r === nothing
                # Exception from the HTTP request itself, nothing to do.
                @debug "Got an error"
                @async put!(q.retries, f)   
            elseif r.status == 429
                # Update the rate limiter with the response body.
                @warn "Rate limited"
                @async begin
                    n = now(UTC)
                    d = JSON.parse(String(copy(r.body)))
                    reset = n + Millisecond(get(d, "retry_after", 0))
                    if get(d, "global", false)
                        limiter.reset = reset
                    else
                        q.remaining = 0
                        q.reset = reset
                    end
                end
                # Requeue the job with high priority.
                put!(q.retries, f)
            else
                # Update the rate limiter with the response headers.
                @debug "Updated limiter"
                rem = HTTP.header(r, "X-RateLimit-Remaining")
                @debug "1"
                isempty(rem) || (q.remaining = parse(Int, rem))
                @debug "2"
                res = HTTP.header(r, "X-RateLimit-Reset")
                @debug "3"
                @async begin 
                    if !isempty(res)
                        tim = parse(Int, res)
                        q.reset = unix2datetime(tim)
                    end
                end
                @debug "4"
            end
            @debug "Finished rate limit job handling"
        end

        return q
    end
end

# A rate limiter for all endpoints.
mutable struct Limiter
    reset::Nullable{DateTime}  # API-wide limit.
    queues::Dict{String, JobQueue}
    sem::Base.Semaphore

    Limiter() = new(nothing, Dict(), Base.Semaphore(1))
end

# Schedule a job.
function enqueue!(f::Function, l::Limiter, method::Symbol, endpoint::AbstractString)
    endpoint = parse_endpoint(endpoint, method)
    withsem(l.sem) do
        haskey(l.queues, endpoint) || (l.queues[endpoint] = JobQueue(endpoint, l))
    end
    put!(l.queues[endpoint].jobs, f)
end

# Get the endpoint which corresponds to its own rate limit.
function parse_endpoint(endpoint::AbstractString, method::Symbol)
    return if method === :DELETE && match(MESSAGES_REGEX, endpoint) !== nothing
        # Special case 1: Deleting messages has its own rate limit.
        first(match(EXCEPT_TRAILING_ID_REGEX, endpoint).captures) * " $method"
    elseif startswith(endpoint, "/invites/")
        # Special case 2: Invites are identified by a non-numeric code.
        "/invites"
    elseif match(ENDS_MAJOR_ID_REGEX, endpoint) !== nothing
        endpoint
    elseif match(ENDS_ID_REGEX, endpoint) !== nothing
        first(match(EXCEPT_TRAILING_ID_REGEX, endpoint).captures)
    else
        endpoint
    end
end
