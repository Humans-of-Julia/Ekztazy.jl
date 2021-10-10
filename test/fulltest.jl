using Dizkord

client = Client(
    ENV["DISCORD_TOKEN"], 
    830208012668764250,
    intents(GUILDS, GUILD_MESSAGES)
)

on_message!(client) do (ctx) 
    if ctx.message.author.id != me(client).id
        Dizkord.reply(client, ctx, content="<@$(ctx.message.author.id)>, $(ctx.message.content)")
    end
end

command!(client, 776251117616234506, "boom", "Go boom!") do (ctx) 
    Dizkord.reply(client, ctx, content="<@$(ctx.int.member.user.id)> blew up!")
end

command!(client, 776251117616234506, "bam", "Go bam!") do (ctx) 
    Dizkord.reply(client, ctx, content="<@$(ctx.int.member.user.id)> slapped themselves!")
end

command!(client, 776251117616234506, "quit", "Go bam!") do (ctx) 
    close(client)
    throw(InterruptException)
end


on_ready!(client) do (ctx)
    println("successfully logged in as $(ctx.user.username)")
end

start(client)
