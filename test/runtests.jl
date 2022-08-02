using PairedLinkedLists
using Test

tests = ["doublylinkedlist",
         "pairedlinkedlist",
        ]

@testset "PairedLinkedLists" begin

for t in tests
    fp = joinpath(dirname(@__FILE__), "test_$t.jl")
    println("$fp ...")
    include(fp)
end

end # @testset
