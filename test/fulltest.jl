using Dizkord
using Distributed

client = Client(
    ENV["DISCORD_TOKEN"], 
    ENV["APPLICATION_ID"] isa Number ? ENV["APPLICATION_ID"] : parse(UInt, ENV["APPLICATION_ID"]),
    intents(GUILDS, GUILD_MESSAGES)
)

ENV["JULIA_DEBUG"] = Dizkord

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

function ff(ctx) 
    Dizkord.reply(client, ctx, content="You pressed the button!!")
end

command!(client, TESTGUILD, "water", "Water a plant"; options=[opt(name="howmuch", description="How long do you want to water the plant?")]) do (ctx) 
    cm = component!(ff, client, "magic"; type=2, style=1, label="Wow, a Button!?")
    Dizkord.reply(client, ctx, components=[Dizkord.Component(; type=1, components=[cm])], content="<@$(ctx.interaction.member.user.id)> watered their plant for $(opt(ctx)["howmuch"]) hours. So much that the plant grew taller than them!")
end

command!(client, TESTGUILD, "quit", "Ends the bot process!") do (ctx) 
    Dizkord.reply(client, ctx, content="Shutting down the bot")
    close(client)
end

on_ready!(client) do (ctx)
    @info "Successfully logged in as $(ctx.user.username)" # obtain(client, User).username
end

start(client)
