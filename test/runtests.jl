using PairedLinkedLists
using Test
using Aqua

tests = ["doublylinkedlist",
         "pairedlinkedlist",
         "targetedlinkedlist",
         "skiplist",
         "pairedskiplist",
         "targetkind",
         "hash",
         "bounds",
        ]

@testset "PairedLinkedLists" begin

for t in tests
    fp = joinpath(dirname(@__FILE__), "test_$t.jl")
    println("$fp ...")
    include(fp)
end

Aqua.test_all(PairedLinkedLists)

end
