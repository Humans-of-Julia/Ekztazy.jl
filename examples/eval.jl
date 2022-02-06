module Eval

using Ekztazy

c = Client()
g = ENV["TESTGUILD"]

command!(c, g, "eval", "evaluates a string as julia code", legacy=false, options=Options(
    [String, "str", "the string to evaluate"]
)) do ctx, str::String 
    @info "$str"
    reply(c, ctx, content="```julia\n$(eval(Meta.parse(str)))\n```")
end

start(c)

end