```@meta
CurrentModule = Ekztazy
```

# Events
Events are how Discord communicates and interacts with our application.
In Ekztazy.jl, we use the [`Handler`](@ref) type in conjunction with the [`Context`](@ref) type to handle them.

## Handler
A Handler is simple to register for an event.
To register a handler for the Ready event:
```julia
# `c` is a client generated previously.
h = OnReady() do (ctx)
    println("I'm ready!")
end

add_handler!(c, h)
```
There is also a convenience method to create handlers.
As such the following code is fully equivalent:
```julia
on_ready!(c) do (ctx)
    println("I'm ready!")
end
```
(on_ready! creates an OnReady handler and adds it to the client.)
You can find a list of all gateway events [here](https://discord.com/developers/docs/topics/gateway#commands-and-events-gateway-events).
Simply add `On` before their NAME to get the name of the associated handler!
```@docs
Handler
```
## Context
The context is simply the payload received from the interaction. Exceptions: 
- The `MessageCreate` context contains a [`Message`](@ref).
- The `OnGuildCreate` and `OnGuildUpdate` contexts contain a [`Guild`](@ref).
- The `OnInteractionCreate` context contains an [`Interaction`](@ref).

You can find the expected payloads for events [here](https://discord.com/developers/docs/topics/gateway#commands-and-events-gateway-events).
```@docs
Context
```

# Commands
Commands are the core of any Discord Application, and as such they are also the core of Ekztazy. Let us define the most basic of functions there can be.
```julia
# ... c is a client struct 
# ... g is a guild id for testing
command!(ctx->reply(c, ctx, content="pong"), c, g, "ping", "Ping!")
```
For more information on each of the arguments, check the documentation of [`command!`](@ref) below. For more complicated functions, there are two ways for them to work. The default Discord.jl inspired "legacy style", which is deprecated, and the "new style". Let us look at both of these with two more complicated commands.
`New style`
```julia
# ... c is a client struct 
# ... g is a guild id for testing
command!(c, g, "greet", "greets a user", legacy=false, options=Options(
    [User, "u", "The user to greet"]
)) do ctx, u::Member
    reply(client, ctx, content="Hello, $(u)!")
end

command!(c, g, "eval", "evaluates a string as julia code", options=Options(
    [String, "str", "the string to evaluate"]
)) do ctx, str::String 
    @info "$str"
    reply(c, ctx, content="```julia\n$(eval(Meta.parse(str)))\n```")
end
```
`Legacy style`
```julia
# ... c is a client struct 
# ... g is a guild id for testing
command!(c, g, "greet", "greets a user", options=[
    opt("u", "the user to greet")
]) do ctx
    reply(client, ctx, content="Hello, <@$(opt(ctx)["u"])>!")
end

command!(c, g, "eval", "evaluates a string as julia code", options=[
    opt("str", "the string to evaluate")
]) do ctx 
    reply(c, ctx, content="```julia\n$(eval(Meta.parse(opt(ctx)["str"])))\n```")
end
```
There a few key differences. In the legacy style, we have to use the [`opt`](@ref) function to get a Dict of Option name => User input, in the new style these are automatically provided to the handler function and are automatically type converted to the right type. In the legacy style, all command options are string, in the new style they can be strings, ints, bools, [`User`](@ref)s, [`Role`](@ref)s and [`DiscordChannel`](@ref)s. You can check examples to see many different command definitions.

## Handlers
```@docs
command!
component!
on_message_create!
on_guild_members_chunk!
on_channel_delete!
on_guild_integrations_update!
on_guild_member_update!
on_presence_update!
on_channel_create!
on_message_delete_bulk!
on_message_reaction_add!
on_guild_role_delete!
on_ready!
on_user_update!
on_guild_create!
on_guild_member_remove!
on_typing_start!
on_message_update!
on_guild_emojis_update!
on_interaction_create!
on_guild_delete!
on_voice_state_update!
on_guild_member_add!
on_guild_ban_remove!
on_guild_role_update!
on_guild_role_create!
on_voice_server_update!
on_guild_ban_add!
on_message_reaction_remove_all!
on_channel_pins_update!
on_resumed!
on_guild_update!
on_message_delete!
on_webhooks_update!
on_channel_update!
on_message_reaction_remove!
```