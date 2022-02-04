using Dizkord
using Distributed

client = Client()

ENV["JULIA_DEBUG"] = Dizkord

TESTGUILD = ENV["TESTGUILD"]

on_message!(client) do (ctx) 
    (!isme(client, ctx)) && reply(client, ctx, content="$(mention(ctx.message.author)), $(ctx.message.content) TEST")
end

command!(client, TESTGUILD, "boom", "Go boom!") do (ctx) 
    reply(client, ctx, content="$(mention(ctx)) blew up!")
end

command!(client, TESTGUILD, "bam", "Go bam!") do (ctx) 
    reply(client, ctx, content="$(mention(ctx)) slapped themselves!")
end

command!(client, TESTGUILD, "double", "Doubles a number!", legacy=false, options=[
    Option(Int, name="number", description="The number to double!")
]) do ctx, number
    reply(client, ctx, content="$(number*2)")
end

command!(client, TESTGUILD, "multiply", "Multiplies numbers!", legacy=false, options=Options(
    [Int, "a", "the first number"],
    [Int, "b", "the second number"]
)) do ctx, a::Int, b::Int
    reply(client, ctx, content="$(a*b)")
end

command!(client, TESTGUILD, "greet", "Greets a user", legacy=false, options=Options(
    [User, "u", "The user to greet"]
)) do ctx, u::Member
    reply(client, ctx, content="Hello, $(u)!")
end

command!(client, TESTGUILD, "water", "Water a plant", legacy=false, options=[
    Option(Int, "howmuch", "How long do you want to water the plant?")
]) do ctx, howmuch 
    cm = component!(client, "magic"; auto_ack=false, type=2, style=1, label="Wow, a Button!?") do context
        update(client, context, content="You pressed the button!")
    end
    reply(client, ctx, components=[cm], content="$(mention(ctx)) watered their plant for $(howmuch) hours. So much that the plant grew taller than them!")
end

command!(client, TESTGUILD, "quit", "Ends the bot process!") do (ctx) 
    reply(client, ctx, content="Shutting down the bot")
    close(client)
end

on_ready!(client) do (ctx)
    @info "Successfully logged in as $(ctx.user.username)" # obtain(client, User).username
end

start(client)
