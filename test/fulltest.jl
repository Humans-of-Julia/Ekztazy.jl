using Dizkord
using Distributed

client = Client(
    ENV["DISCORD_TOKEN"], 
    830208012668764250,
    intents(GUILDS, GUILD_MESSAGES)
)

on_message!(client) do (ctx) 
    println("Received message: $(ctx.message.content)")
    if ctx.message.author.id != 830208012668764250
        Dizkord.reply(client, ctx.message, content="<@$(ctx.message.author.id)>, $(ctx.message.content)")
    end
end

command!(client, 776251117616234506, "boom", "Go boom!") do (ctx) 
    println("Command ran!")
end

on_ready!(client) do (ctx)
    println("successfully logged in as $(ctx.user.username)")
end

start(client)
