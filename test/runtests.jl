using Dizkord
using Test 

client = Client(
    "ODMwMjA4MDEyNjY4NzY0MjUw.YHDVdg.98_US-9CVfQImroXOF4DowNDM6M", 
    830208012668764250,
    intents(GUILDS, GUILD_MESSAGES)
)

on_message!(client) do (ctx) 
    print("Received Message: $(ctx.content)")
    return nothing
end

open(client)