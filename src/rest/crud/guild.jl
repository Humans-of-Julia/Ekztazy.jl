create(c::Client, ::Type{Guild}; kwargs...) = create_guild(c; kwargs...)
create(c::Client, g::Guild, s::ScheduledEvent; kwargs...) = create_guild_scheduled_event(c, g, s; kwargs...)
create(c::Client, g::Guild; kwargs...) = create(c, g, ScheduledEvent(; kwargs...))

retrieve(c::Client, ::Type{Guild}, guild::Integer) = get_guild(c, guild)
retrieve(c::Client, ::Type{Guild}; kwargs...) = get_current_user_guilds(c; kwargs...)
retrieve(c::Client, g::Guild, s::Snowflake; kwargs...) = get_guild_scheduled_event(c, g, s; kwargs...)

update(c::Client, g::AbstractGuild; kwargs...) = modify_guild(c, g.id; kwargs...)
# TODO: kwargs version of this that auto updates ScheduledEvent fields
# for scheduledevents get guild from ScheduledEvent.guild_id
update(c::Client, g::Guild, s::ScheduledEvent; kwargs...) = modify_guild_scheduled_event(c, g, s; kwargs...)

delete(c::Client, g::AbstractGuild) = delete_guild(c, g.id)
