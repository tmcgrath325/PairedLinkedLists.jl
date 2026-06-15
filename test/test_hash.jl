@testset "hash / isequal" begin
    n = 5

    @testset "equal lists hash equally" begin
        # Every concrete list type: two value-equal lists are `==`, `isequal`,
        # and share a hash.
        for L in (DoublyLinkedList, SkipList, PairedLinkedList, PairedSkipList)
            a = L{Int}(1:n...)
            b = L{Int}(1:n...)
            @test a == b
            @test isequal(a, b)
            @test hash(a) == hash(b)
        end

        base = DoublyLinkedList{Int}(1:n...)
        ta = TargetedLinkedList(base); push!(ta, 1:n...)
        tb = TargetedLinkedList(base); push!(tb, 1:n...)
        @test ta == tb
        @test isequal(ta, tb)
        @test hash(ta) == hash(tb)
    end

    @testset "equality spans concrete types" begin
        # `==` ignores the concrete list type, so hashing must too.
        dl = DoublyLinkedList{Int}(1:n...)
        pl = PairedLinkedList{Int}(1:n...)
        @test dl == pl
        @test isequal(dl, pl)
        @test hash(dl) == hash(pl)
    end

    @testset "unequal lists" begin
        @test hash(DoublyLinkedList{Int}(1, 2, 3)) != hash(DoublyLinkedList{Int}(1, 2, 3, 4))
        @test hash(DoublyLinkedList{Int}(1, 2, 3)) != hash(DoublyLinkedList{Int}(1, 2, 9))
        # Differing element type is unequal under `==`/`isequal`.
        @test DoublyLinkedList{Int}(1) != DoublyLinkedList{Float64}(1.0)
        @test !isequal(DoublyLinkedList{Int}(1), DoublyLinkedList{Float64}(1.0))
    end

    @testset "per-node target data participates" begin
        a1 = PairedLinkedList{Int}(1, 2, 3); a2 = PairedLinkedList{Int}(10, 20, 30)
        addtarget!(a1, a2); addtarget!(head(a1), head(a2))

        b1 = PairedLinkedList{Int}(1, 2, 3); b2 = PairedLinkedList{Int}(10, 20, 30)
        addtarget!(b1, b2); addtarget!(head(b1), head(b2))

        # Same node data but a different linked-target's data.
        c1 = PairedLinkedList{Int}(1, 2, 3); c2 = PairedLinkedList{Int}(99, 20, 30)
        addtarget!(c1, c2); addtarget!(head(c1), head(c2))

        # Same node data, no node-level target at all.
        d1 = PairedLinkedList{Int}(1, 2, 3)

        @test isequal(a1, b1) && hash(a1) == hash(b1)
        @test !isequal(a1, c1) && hash(a1) != hash(c1)
        @test !isequal(a1, d1) && hash(a1) != hash(d1)
    end

    @testset "strict pair distinguishes signed zero" begin
        # `==` is loose (0.0 == -0.0); `isequal`/`hash` are strict, matching the
        # contract that `Dict`/`Set` rely on.
        z1 = DoublyLinkedList{Float64}(0.0)
        z2 = DoublyLinkedList{Float64}(-0.0)
        @test z1 == z2
        @test !isequal(z1, z2)
        @test hash(z1) != hash(z2)
    end

    @testset "usable as Set elements and Dict keys" begin
        dl = DoublyLinkedList{Int}(1:n...)
        pl = PairedLinkedList{Int}(1:n...)
        @test length(Set([dl, DoublyLinkedList{Int}(1:n...), pl])) == 1
        d = Dict(dl => :found)
        @test d[pl] == :found        # cross-type lookup resolves
    end
end
