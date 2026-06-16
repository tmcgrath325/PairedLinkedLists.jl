using PairedLinkedLists
using Test
using Aqua
using ExplicitImports

tests = [
    "doublylinkedlist",
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

    @testset "ExplicitImports" begin
        test_explicit_imports(
            PairedLinkedLists;
            ignore = (:SizeUnknown, :promote_op),
            all_explicit_imports_are_public = VERSION >= v"1.11",
            all_qualified_accesses_are_public = VERSION >= v"1.11"
        )
    end

end
