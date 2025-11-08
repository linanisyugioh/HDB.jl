using HDB
using Documenter

DocMeta.setdocmeta!(HDB, :DocTestSetup, :(using HDB); recursive=true)

makedocs(;
    modules=[HDB],
    authors="linan <linanisyugioh@163.com> and contributors",
    sitename="HDB.jl",
    format=Documenter.HTML(;
        canonical="https://linanisyugioh.github.io/HDB.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/linanisyugioh/HDB.jl",
    devbranch="main",
)
