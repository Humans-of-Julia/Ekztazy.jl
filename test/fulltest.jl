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
        Dizkord.reply(client, ctx, content="<@$(ctx.message.author.id)>, $(ctx.message.content)")
    end
end

command!(client, 776251117616234506, "boom", "Go boom!") do (ctx) 
    print("$(ctx.user.id)")
    Dizkord.reply(client, ctx, content="<@$(ctx.int.user.id)> blew up!")
    print(t.val)
end

on_ready!(client) do (ctx)
    println("successfully logged in as $(ctx.user.username)")
end

start(client)
