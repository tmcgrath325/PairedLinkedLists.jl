@testset "TargetKind" begin
    dl = DoublyLinkedList{Int}(1:5...)
    sl = SkipList{Int}(1:5...)
    pl = PairedLinkedList{Int}(1:5...)
    psl = PairedSkipList{Int}(1:5...)
    tl = TargetedLinkedList(dl)
    push!(tl, 1:5...)

    @testset "kind of each type" begin
        @test TargetKind(dl) === Untargeted()
        @test TargetKind(sl) === Untargeted()
        @test TargetKind(pl) === Reciprocal()
        @test TargetKind(psl) === Reciprocal()
        @test TargetKind(tl) === OneWay()

        @test TargetKind(head(dl)) === Untargeted()
        @test TargetKind(head(sl)) === Untargeted()
        @test TargetKind(head(pl)) === Reciprocal()
        @test TargetKind(head(psl)) === Reciprocal()
        @test TargetKind(head(tl)) === OneWay()

        # the trait is queryable from the type alone
        @test TargetKind(typeof(pl)) === Reciprocal()
        @test TargetKind(typeof(tl)) === OneWay()
        @test TargetKind(typeof(dl)) === Untargeted()
    end

    @testset "untargeted objects" begin
        # `hastarget` is always false and the mutators are no-ops
        @test !hastarget(dl)
        @test !hastarget(head(dl))
        @test removetarget!(dl) === dl
        @test removetarget!(head(dl)) === head(dl)
        @test removetarget!(sl) === sl
        @test removetarget!(head(sl)) === head(sl)
    end
end
