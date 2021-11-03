using Dizkord
using Distributed

client = Client(
    ENV["DISCORD_TOKEN"], 
    ENV["APPLICATION_ID"] isa Number ? ENV["APPLICATION_ID"] : parse(UInt, ENV["APPLICATION_ID"]),
    intents(GUILDS, GUILD_MESSAGES)
)

TESTGUILD = ENV["TESTGUILD"] isa Number ? ENV["TESTGUILD"] : parse(Int, ENV["TESTGUILD"])

on_message!(client) do (ctx) 
    if ctx.message.author.id != me(client).id
        Dizkord.reply(client, ctx, content="<@$(ctx.message.author.id)>, $(ctx.message.content) TEST")
    end
end

command!(client, TESTGUILD, "boom", "Go boom!") do (ctx) 
    Dizkord.reply(client, ctx, content="<@$(ctx.interaction.member.user.id)> blew up!")
end

command!(client, TESTGUILD, "bam", "Go bam!") do (ctx) 
    Dizkord.reply(client, ctx, content="<@$(ctx.interaction.member.user.id)> slapped themselves!")
end

command!(client, TESTGUILD, "quit", "Ends the bot process!") do (ctx) 
    Dizkord.reply(client, ctx, content="Shutting down the bot")
    close(client)
end

command!(client, TESTGUILD, "crack", "Go crack!"; options=[opt("Some option", "Do something... probably.")]) do (ctx) 
    Dizkord.reply(client, ctx, content="<@$(ctx.interaction.member.user.id)> hit a pole")
end

command!(client, TESTGUILD, "quit", "Ends the bot process!") do (ctx) 
    Dizkord.reply(client, ctx, content="Shutting down the bot")
    close(client)
end

on_ready!(client) do (ctx)
    @info "Successfully logged in as $(ctx.user.username)"
end

start(client)
