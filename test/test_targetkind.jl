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

    @testset "target() accessor" begin
        pl2 = PairedLinkedList{Int}(1:5...)
        psl2 = PairedSkipList{Int}(1:5...)

        # unlinked: target() returns nothing, hiding the self-reference encoding
        @test target(pl) === nothing
        @test target(psl) === nothing
        @test target(head(pl)) === nothing
        @test target(head(psl)) === nothing
        # tl was constructed with dl as its target, so it is already linked
        @test target(tl) === dl
        # nodes of a TargetedLinkedList start unlinked
        @test target(head(tl)) === nothing

        # untargeted types always return nothing
        @test target(dl) === nothing
        @test target(head(dl)) === nothing
        @test target(sl) === nothing
        @test target(head(sl)) === nothing

        # linked lists
        addtarget!(pl, pl2)
        @test target(pl) === pl2
        @test target(pl2) === pl
        removetarget!(pl)
        @test target(pl) === nothing
        @test target(pl2) === nothing

        addtarget!(psl, psl2)
        @test target(psl) === psl2
        @test target(psl2) === psl
        removetarget!(psl)

        addtarget!(tl, dl)
        @test target(tl) === dl
        removetarget!(tl)
        @test target(tl) === nothing

        # linked nodes (PairedLinkedList)
        addtarget!(pl, pl2)
        n1 = head(pl)
        n2 = head(pl2)
        addtarget!(n1, n2)
        @test target(n1) === n2
        @test target(n2) === n1
        removetarget!(n1)
        @test target(n1) === nothing
        @test target(n2) === nothing

        # linked nodes (TargetedLinkedList)
        dn = head(dl)
        tn = head(tl)
        addtarget!(tn, dn)
        @test target(tn) === dn
        removetarget!(tn)
        @test target(tn) === nothing
    end
end
