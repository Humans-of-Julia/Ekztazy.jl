using Dizkord
using Documenter

DocMeta.setdocmeta!(Dizkord, :DocTestSetup, :(using Dizkord); recursive=true)

makedocs(;
    modules=[Dizkord],
    authors="Kyando2",
    repo="https://github.com/Kyando2/Dizkord.jl/blob/{commit}{path}#{line}",
    sitename="Dizkord",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://github.com/Kyando2/Dizkord.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="https://github.com/Kyando2/Dizkord.jl",
    devbranch="master",
)
