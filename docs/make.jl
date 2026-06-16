using PairedLinkedLists
using Documenter

DocMeta.setdocmeta!(PairedLinkedLists, :DocTestSetup, :(using PairedLinkedLists); recursive=true)

makedocs(;
    modules=[PairedLinkedLists],
    authors="Tom McGrath <tmcgrath325@gmail.com> and contributors",
    sitename="PairedLinkedLists.jl",
    format=Documenter.HTML(;
        canonical="https://tmcgrath325.github.io/PairedLinkedLists.jl",
        edit_link="main",
    ),
    pages=[
        "Home" => "index.md",
    ],
    checkdocs=:exports,
)

deploydocs(;
    repo="github.com/tmcgrath325/PairedLinkedLists.jl",
    devbranch="main",
)
