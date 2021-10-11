using Documenter, Dizkord

makedocs(;
    modules=[Dizkord],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md"
    ]
    repo="https://github.com/Kyando2/Dizkord.jl/blob/{commit}{path}#L{line}",
    sitename="Dizkord.jl",
    authors="Xh4H <sindur.esl@gmail.com>, christopher-dG <chrisadegraaf@gmail.com> Kyando <izawa.iori.tan@gmail.com>",
)