using Dizkord
using Distributed


client = Client(
    ENV["DISCORD_TOKEN"], 
    parse(UInt, ENV["APPLICATION_iD"]),
    intents(GUILDS, GUILD_MESSAGES)
)

on_message!(client) do (ctx) 
    if ctx.message.author.id != me(client).id
        Dizkord.reply(client, ctx, content="<@$(ctx.message.author.id)>, $(ctx.message.content) TEST")
    end
end

command!(client, 776251117616234506, "boom", "Go boom!") do (ctx) 
    Dizkord.reply(client, ctx, content="<@$(ctx.interaction.member.user.id)> blew up!")
end

command!(client, 776251117616234506, "bam", "Go bam!") do (ctx) 
    Dizkord.reply(client, ctx, content="<@$(ctx.interaction.member.user.id)> slapped themselves!")
end

command!(client, 776251117616234506, "quit", "Ends the bot process!") do (ctx) 
    Dizkord.reply(client, ctx, content="Shutting down the bot")
    close(client)
end

command!(client, 776251117616234506, "crack", "Go crack!") do (ctx) 
    Dizkord.reply(client, ctx, content="<@$(ctx.interaction.member.user.id)> hit a pole")
end

command!(client, 776251117616234506, "quit", "Ends the bot process!") do (ctx) 
    Dizkord.reply(client, ctx, content="Shutting down the bot")
    close(client)
end

on_ready!(client) do (ctx)
    @info "Successfully logged in as $(ctx.user.username)"
end

start(client)
