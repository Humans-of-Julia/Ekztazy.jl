<div align="center">
  <img src="https://github.com/Humans-of-Julia/Dizkord.jl/blob/master/docs/src/assets/logo.png?raw=true" width = "100" height = "100" style="align: center">


| Documentation | Build |
| -- | -- |
| [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://humans-of-julia.github.io/Dizkord.jl/stable/) [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://humans-of-julia.github.io/Dizkord.jl/dev/)| [![CI](https://github.com/Humans-of-Julia/Dizkord.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/Humans-of-Julia/Dizkord.jl/actions/workflows/ci.yml) |
</div>

Dizkord.jl is the spiritual successor to [Discord.jl](https://github.com/Xh4H/Discord.jl). It is a maintained Julia Pkg for creating simple yet efficient [Discord](https://discord.com) bots.

* Strong, expressive type system: No fast-and-loose JSON objects here.
* Non-blocking: API calls return immediately and can be awaited when necessary.
* Simple: Multiple dispatch allows for a [small, elegant core API](https://Humans-of-Julia.github.io/Dizkord.jl/stable/rest.html#CRUD-API-1).
* Fast: Julia is [fast like C but still easy like Python](https://julialang.org/blog/2012/02/why-we-created-julia).
* Robust: Resistant to bad event handlers and/or requests. Errors are introspectible for debugging.
* Lightweight: Cache what is important but shed dead weight with [TTL](https://en.wikipedia.org/wiki/Time_to_live).
* Gateway independent: Ability to interact with Discord's API without establishing a gateway connection.
* Distributed: [Process-based sharding](https://Humans-of-Julia.github.io/Dizkord.jl/stable/client.html#Dizkord.Client) requires next to no intervention and you can even run shards on separate machines.

Dizkord.jl has not been released.
It can be added from the Git repository with the following command:

```julia
] add https://github.com/Humans-of-Julia/Dizkord.jl
```

# Example

```julia
# Discord Token and Application ID should be saved in Env vars
client = Client()

# Guild to register the command in 
TESTGUILD = ENV["TESTGUILD"]

command!(client, TESTGUILD, "double", "Doubles a number!", options=[opt(name="number", description="The number to double!")]) do (ctx) 
    Dizkord.reply(client, ctx, content="$(parse(Int, opt(ctx)["number"])*2)")
end

on_ready!(client) do (ctx)
    @info "Successfully logged in as $(ctx.user.username)"
end

start(client)
```

Big thanks to [@Xh4H](https://github.com/Xh4H) for Discord.jl which this relied heavily on.
