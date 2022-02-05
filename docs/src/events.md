```@meta
CurrentModule = D1zk0rd
```

# Events
Events are how Discord communicates and interacts with our application.
In D1zk0rd.jl, we use the [`Handler`](@ref) type in conjunction with the [`Context`](@ref) type to handle them.

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
Note that as `OnReady` is a common event, there is a convenience method for it.
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

## Special Handlers
```@docs
on_message!
on_ready!
command!
```