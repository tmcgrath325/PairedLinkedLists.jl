@testset "index bounds" begin
    @testset "getnode rejects out-of-range indices" begin
        # getnode walks `.next` from the head sentinel; without a bounds check
        # an out-of-range index silently returns a sentinel node (garbage data)
        # or loops at the tail sentinel. An invalid index is a structural error.
        for l in (DoublyLinkedList{Int}(1:5...),
                  PairedLinkedList{Int}(1:5...),
                  SkipList{Int}(1:5...))
            @test_throws BoundsError getnode(l, 0)
            @test_throws BoundsError getnode(l, length(l) + 1)
            @test_throws BoundsError getnode(l, length(l) + 7)
            @test getnode(l, 1).data == 1
            @test getnode(l, length(l)).data == 5
        end
    end

    @testset "setindex! rejects out-of-range indices" begin
        # Without its own check, setindex! would write through getnode into a
        # sentinel node, silently corrupting list structure.
        for l in (DoublyLinkedList{Int}(1:5...), PairedLinkedList{Int}(1:5...))
            @test_throws BoundsError l[0] = 42
            @test_throws BoundsError l[length(l) + 1] = 42
            l[3] = 30
            @test l[3] == 30
        end
    end

    @testset "insert! covers the full valid range" begin
        # idx == length+1 appends at the end (successor is the tail sentinel).
        l = DoublyLinkedList{Int}(1:5...)
        insert!(l, length(l) + 1, 99)
        @test collect(l) == [1, 2, 3, 4, 5, 99]
        insert!(l, 1, 0)
        @test collect(l) == [0, 1, 2, 3, 4, 5, 99]
        insert!(l, 4, 100)
        @test collect(l) == [0, 1, 2, 100, 3, 4, 5, 99]
        @test_throws BoundsError insert!(l, 0, 1)
        @test_throws BoundsError insert!(l, length(l) + 2, 1)
    end

    @testset "removetarget!(list, idx) rejects out-of-range indices" begin
        pl = PairedLinkedList{Int}(1:5...)
        pl2 = PairedLinkedList{Int}(1:5...)
        addtarget!(pl, pl2)
        @test_throws BoundsError removetarget!(pl, 0)
        @test_throws BoundsError removetarget!(pl, length(pl) + 1)
    end
end
