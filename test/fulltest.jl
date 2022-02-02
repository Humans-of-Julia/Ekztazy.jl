using Dizkord
using Distributed

client = Client()

ENV["JULIA_DEBUG"] = Dizkord

TESTGUILD = ENV["TESTGUILD"]

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

command!(client, TESTGUILD, "double", "Doubles a number!", false, options=[
    Option(Int, name="number", description="The number to double!")
]) do ctx, number
    @info "$(typeof(ctx, number))"
    Dizkord.reply(client, ctx, content="$(number*2)")
end

command!(client, TESTGUILD, "multiply", "Multiplies numbers!", options=[opt(name="a", description="The first number."), opt(name="b", description="The second number.")]) do (ctx) 
    Dizkord.reply(client, ctx, content="$(parse(Int, opt(ctx)["a"])*parse(Int, opt(ctx)["b"]))")
end

command!(client, TESTGUILD, "water", "Water a plant", true; options=[
    Option(String, name="howmuch", description="How long do you want to water the plant?")
]) do (ctx) 
    cm = component!(client, "magic", false; type=2, style=1, label="Wow, a Button!?") do (context)
        Dizkord.edit_interaction(client, context, content="You pressed the button!")
    end
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
