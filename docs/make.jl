using PairedLinkedLists
using Documenter

DocMeta.setdocmeta!(PairedLinkedLists, :DocTestSetup, :(using PairedLinkedLists); recursive=true)

makedocs(;
    modules=[PairedLinkedLists],
    authors="Tom McGrath <tmcgrath325@gmail.com> and contributors",
    repo="https://github.com/tmcgrath325/PairedLinkedLists.jl/blob/{commit}{path}#{line}",
    sitename="PairedLinkedLists.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://tmcgrath325.github.io/PairedLinkedLists.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/tmcgrath325/PairedLinkedLists.jl",
    devbranch="main",
)
