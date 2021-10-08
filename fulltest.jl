using Dizkord

client = Client(
    readlines("token.txt")[1], # token in token.txt
    830208012668764250,
    intents(GUILDS, GUILD_MESSAGES)
)

on_message!(client) do (ctx) 
    println("Received message: $(ctx.message.content)")
    if ctx.message.author.id != 830208012668764250
        Dizkord.reply(client, ctx.message, content="<@$(ctx.message.author.id)>, $(ctx.message.content)")
    end
end

on_ready!(client) do (ctx)
    println!("successfully logged in as $(ctx.user.username)")
end

start(client)
