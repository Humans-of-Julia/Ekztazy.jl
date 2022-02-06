```@meta
CurrentModule = Ekztazy
```
## Index

### Introduction
Welcome to Ekztazy.jl

Ekztazy.jl is the spiritual successor to Discord.jl. It is a maintained Julia Pkg for creating simple yet efficient Discord bots.

- Strong, expressive type system: No fast-and-loose JSON objects here.
- Non-blocking: API calls return immediately and can be awaited when necessary.
- Simple: Multiple dispatch allows for a small, elegant core API.
- Fast: Julia is fast like C but still easy like Python.
- Robust: Resistant to bad event handlers and/or requests. Errors are introspectible for debugging.
- Lightweight: Cache what is important but shed dead weight with TTL.
- Gateway independent: Ability to interact with Discord's API without establishing a gateway connection.
- Distributed: Process-based sharding requires next to no intervention and you can even run shards on separate machines.

### Getting Started
You can add Ekztazy.jl from Git using the following command in the REPL:
```julia
] add https://github.com/Humans-of-Julia/Ekztazy.jl
```
The most important type when working with Ekztazy.jl is the [`Client`](@ref). 
Most applications will start in a similar fashion to this:
```julia
using Ekztazy

client = Client()
```
This will create a [`Client`](@ref) using default parameters. This expects two environment variables:
- APPLICATION_ID, the bot's application id
- DISCORD_TOKEN, the bot's secret token

These can also be specified.
```julia
using Ekztazy

client = Client(
    discord_token,
    application_id,
    intents(GUILDS, GUILD_MESSAGES)
)
``` 
(Assuming discord\_token is a String and applicaton\_id is an Int).
For a more complete list of parameters for creating a [`Client`](@ref). Check the Client documentation.

Usually when working with Ekztazy, we will either want to handle messages, or commands. Let's start with messages.

```julia 
# ... 

on_message!(client) do (ctx) 
    if ctx.message.author.id != me(client).id
        reply(client, ctx, content="I received the following message: $(ctx.message.content).")
    end
end

start(client)
```
Let's analyze this code. First we are using the [`on_message!`](@ref) function which generates adds a [`Handler`](@ref). (For more information on this, check the events documentation). Then in the handling function we start by checking if the the message author's id isn't the same as the the bot's. This is sensible, as we wouldn't want the bot to indefinitely respond to itself. Finally, we use the [`reply`](@ref) function to reply to the message! Under the hood, the reply function appraises the context, and finds a way to reply to it, the `kwargs` passed to it are then made into the request body. Here, in the message we use interpolation to send the message's content. We finish by calling [`start`](@ref) on the client.


Next, commands.
```julia
# ...
g = ENV["MY_TESTING_GUILD"]

command!(client, g, "double", "Doubles a number!", options=[opt(name="number", description="The number to double!")]) do (ctx) 
    Ekztazy.reply(client, ctx, content="$(parse(Int, opt(ctx)["number"])*2)")
end

start(client)
```
Let's analyze this code again. First we are using the [`command!`](@ref) function. This creates a command with the specified parameters. We are also uisng the helper [`opt`](@ref) method, to generate and get options. Calling opt with a name and description will create an option, using it on a context will get the values the user provided for each option in a Dict. Like in the previous example we are using the magic [`reply`](@ref) function that creates a followup message for the interaction. (This does not strictly reply to the interaction. Interactions instantly get ACKd by Ekztazy.jl to prevent your handling implementation from exceeding the interaction's 3s reply time limit.)

Here is the equivalent using the new system. The old system is deprecated and will be removed in the next major version.
```julia
# ...
g = ENV["MY_TESTING_GUILD"]

command!(client, g, "double", "Doubles a number!", legacy=false, options=Options(
    [Int, "num", "The number to double!"]
) do ctx, num::Int
    reply(client, ctx, content="$(num*2)")
end

start(client)
```
The option `num` will magically be passed to the handler to be used directly.

Sometimes we may also want to do things without waiting for user input. However putting such code in the top scope would never be executed as [`start`](@ref) is blocking. This is where [`on_ready!`](@ref) comes in.

```julia
# ...

CHID = 776251117616234509 # Testing channel ID
on_ready!(client) do (ctx)
    cm = component!(client, "ar00"; type=2, style=1, label="Really??") do (ctx)
        Ekztazy.reply(client, ctx, content="Yes!")
    end
    create_message(client, CHID, content="I am ready!", components=[Ekztazy.Component(type=1, components=[cm])])
end
```
Let's get right into it. First we are using the [`on_ready!`](@ref). This is called as soon as the bot is ready. We are then creating a [`Component`](@ref) and a handler for it.
The component's handler simply replies with "Yes!", as usual using the [`reply`](@ref) function. Next we have a new function, [`create_message`](@ref). This simply sends message to the specificed channel id. Here the message content is simply "I am ready". It also has a component. The component we created previously is of type 2, it's a button. It cannot be sent directly and needs to be wrapped in an action row of type 1, this is what we do by creating a new [`Component`](@ref) of type 1.


This is all you should need for most Discord bot projects! For any question please join the [Humans of Julia Discord](https://discord.gg/C5h9D4j), and look for me @Kyando#0001!


```@index
```