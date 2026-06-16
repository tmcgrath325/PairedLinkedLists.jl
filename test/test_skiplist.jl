using PairedLinkedLists: searchinsert!, addlevel!, pushskip!, attop, atbottom, height, search, insertskipafter!, skiplistsidentical, SkipListCache, copyfromcache, emptycache!

@testset "SkipList" begin

    @testset "concrete pointer field types" begin
        # The prev/next/up/down links must carry the full SkipNode{T,L} type so
        # the compiler can infer concrete types across pointer chains.
        N = SkipNode{Int,SkipList{Int,typeof(identity)}}
        for f in (:prev, :next, :up, :down)
            @test isconcretetype(fieldtype(N, f))
        end
    end

    @testset "empty list" begin
        l1 = SkipList{Int}()
        @test iterate(l1) === nothing
        @test isempty(l1)
        @test length(l1) == 0
        @test lastindex(l1) == 0
        @test keys(l1) == []
        @test collect(l1) == Int[]
        @test eltype(l1) == Int
        @test eltype(typeof(l1)) == Int
        @test_throws ArgumentError pop!(l1)
        @test_throws ArgumentError popfirst!(l1)
        @test_throws ArgumentError head(l1)
        @test_throws ArgumentError tail(l1)
    end

    @testset "core functionality" begin
        n = 10

        @testset "iterate" begin
            l = SkipList{Int}(1:n...)

            @testset "data" begin
                for (i,data) in enumerate(l)
                    @test data == i
                end
                for (i,data) in enumerate(ListDataIterator(l))
                    @test data == i
                end
                for (i,data) in enumerate(ListDataIterator(l; rev=true))
                    @test data == n-i+1
                end
                for (i,data) in enumerate(ListDataIterator(l.head.next.next))
                    @test data == i+1
                end
                for (i,data) in enumerate(ListDataIterator(l.tail.prev.prev; rev=true))
                    @test data == n-i
                end
            end

            @testset "nodes" begin
                for (i,node) in enumerate(l.head.next)
                    @test node == newnode(l,i)
                end
                for (i,node) in enumerate(ListNodeIterator(l))
                    @test node == newnode(l,i)
                end
                for (i,node) in enumerate(ListNodeIterator(l; rev=true))
                    @test node == newnode(l,n-i+1)
                end
                for (i,node) in enumerate(ListNodeIterator(l.head.next.next))
                    @test node == newnode(l,i+1)
                end
                for (i,node) in enumerate(ListNodeIterator(l.tail.prev.prev; rev=true))
                    @test node == newnode(l,n-i)
                end
            end
        end

        @testset "push back / pop back" begin
            l = SkipList{Int}()
            dummy_list = SkipList{Int}()
            @test_throws ArgumentError insertafter!(newnode(dummy_list, 0), l.head)

            @testset "push back" begin
                for i = 1:n
                    push!(l, i)
                    @test last(l) == i
                    @test getindex(l, i) == i
                    @test lastindex(l) == i
                    @test length(l) == i
                    @test isempty(l) == false
                    @test keys(l) == collect(1:i)
                    for (j, k) in enumerate(l)
                        @test j == k
                    end
                    if i > 3
                        l1 = SkipList{Int32}(1:i...)
                        io = IOBuffer()
                        @test sprint(io -> show(io, iterate(l1))) == "(1, SkipNode{Int32, SkipList{Int32, typeof(identity)}}(2))"
                        @test sprint(io -> show(io, iterate(l1, l1.head.next.next))) == "(2, SkipNode{Int32, SkipList{Int32, typeof(identity)}}(3))"
                    end
                    cl = collect(l)
                    @test isa(cl, Vector{Int})
                    @test cl == collect(1:i)
                end
            end
        end

        @testset "pop front" begin
            l = SkipList{Int}()

            @testset "push front" begin
                for i = n:-1:1
                    push!(l, i)
                    @test first(l) == i
                    @test length(l) == n-i+1
                    @test isempty(l) == false
                    cl = collect(l)
                    @test isa(cl, Vector{Int})
                    @test cl == collect(i:n)
                end
            end

            @testset "pop front" begin
                for i = 1:n
                    x = popfirst!(l)
                    @test length(l) == n - i
                    @test isempty(l) == (i == n)
                    @test x == i
                    cl = collect(l)
                    @test cl == collect(i+1:n)
                end
            end

        end

        @testset "delete / copy" begin
            for i = 1:n
                l = SkipList{Int}(1:2n...)

                @testset "delete" begin
                    delete!(l, n+1:2n)
                    @test l == SkipList{Int}(1:n...)
                    for i = n:-1:1
                        delete!(l, i)
                    end
                    @test l == SkipList{Int}()
                    l = SkipList{Int}(1:n...)
                    @test_throws BoundsError delete!(l, n-1:2n)
                    @test_throws BoundsError delete!(l, 2n)
                end

                @testset "copy" begin
                    l2 = copy(l)
                    @test l == l2
                end
            end
        end

        @testset "show" begin
            for i = 1:n
                l = SkipList{Int32}(1:n...)
                io = IOBuffer()
                @test sprint(io -> show(io, l.head.next)) == "$(typeof(l.head.next))($(l.head.next.data))"
                io1 = IOBuffer()
                write(io1, "SkipList{Int32, typeof(identity)}(");
                write(io1, join(l, ", "));
                write(io1, ")")
                seekstart(io1)
                @test sprint(io -> show(io, l)) == read(io1, String)
            end
        end

        @testset "popat" begin
            for i=1:n
                l = SkipList{Int}(1:n...)
                @test_throws BoundsError popat!(l, 0)
                @test_throws BoundsError popat!(l, n+1)
                @test popat!(l, 0, missing) === missing
                @test popat!(l, n+1, Inf) === Inf
                for i=2:n-1
                    @test popat!(l, 2) == i
                end
                @test l == SkipList{Int}(1,n)
                @test l.len == 2

                l2 = SkipList{Int}(1:n...)
                for i=n-1:-1:2
                    @test popat!(l2, l2.len-1, 0) == i
                end
                @test l2 == SkipList{Int}(1,n)
                @test l2.len == 2
                @test popat!(l2, 1) == 1
                @test popat!(l2, 1) == n
                @test l2 == SkipList{Int}()
                @test l2.len == 0
                @test_throws BoundsError popat!(l2, 1)
            end
        end

        @testset "empty" begin
            l = SkipList{Int}(1:n...)
            @test length(l) == n
            emptyl = empty(l)
            @test length(emptyl) == 0
            @test typeof(l) == typeof(emptyl)
            @test length(l) == n
            empty!(l)
            @test l == emptyl
        end
    end

    @testset "random operations" begin
        l1 = SkipList{Int}()
        l2 = SkipList{Int}() # for testing the cache
        l2.cache = SkipListCache{Int}()
        for l in (l1, l2)
        r = Int[]
        m = 100

        for k = 1 : m
            la = rand(2:20)
            x = rand(1:1000, la)

            for i = 1 : la
                push!(r, x[i])
                sort!(r)
                push!(l, x[i])
            end

            @test length(l) == length(r)
            @test collect(l) == r

            if !isnothing(l.cache)
                @test skiplistsidentical(l, copyfromcache(l))
            end

            lr = rand(0:length(r)-1)
            for i = 1 : lr
                if 3*rand() < 1
                    pop!(r)
                    pop!(l)
                elseif rand(Bool)
                    popfirst!(r)
                    popfirst!(l)
                else
                    idx = rand(2:length(r))
                    popat!(r, idx)
                    popat!(l, idx)
                end
            end

            @test length(l) == length(r)
            @test collect(l) == r

            @test length(l) == length(r)
            @test collect(l) == r

            if !isnothing(l.cache)
                @test skiplistsidentical(l, copyfromcache(l))
            end

            levelcounter = 1
            node = head(l)
            while !attop(node)
                levelcounter += 1
                node = node.up
            end
            @test levelcounter == l.nlevels
        end
    end
    end

    @testset "specific cases" begin
        @testset "insertion smoke test" begin
            dataqueue = Tuple{Float64, Float64}[
                (-2.6092728614000015e7, -1.0316284534898774),
                (-2.6092728614000015e7, -1.0316284534898774),
                (-604710.7185966148, 45133.992819159685),
                (-604710.7185966148, 45133.992819159685),
                (-525914.8725571438, 6469.71162159019),
                (-477956.08599763474, 266677.0974162381),
                (-525914.8725571438, 6469.71162159019),
                (-31320.654367793515, 211351.46378495908),
                (-13903.850341542946, 966.1257724254116),
                (-13903.850341542946, 966.1257724254116),
                (-6059.0280425375695, 3.490058488568876),
                (-4541.834666790945, 9414.84753200319),
                (-477956.08599763474, 266677.0974162381),
                (-4541.834666790945, 9414.84753200319),
                (-505.8034703400152, 9600.043182210395),
                (-31320.654367793515, 211351.46378495908),
                (-23493.83881903814, 210364.07628974097),
                (-21910.63313047902, 219824.9373258181),
                (-6059.0280425375695, 3.490058488568876),
                (-2056.0030024928897, 176.3098180551471),
                (-813.454554028805, 1.1770328014204987),
                (-23493.83881903814, 210364.07628974097),
                (-2056.0030024928897, 176.3098180551471),
                (-21910.63313047902, 219824.9373258181),
                (-505.8034703400152, 9600.043182210395),
                (-505.8034703400152, 3728.1079602364875),
                (-505.8034703400152, 3728.1079602364875),
                (-813.454554028805, 1.1770328014204987),
                (-276.5432526131781, 1.8398591663880404),
                (-237.6225507774923, 130.83952395865234),
                (-237.6225507774923, 130.83952395865234),
                (-144.08830408044508, 129.51606841941154),
                (-10.983151648974813, 131.3295793241059),
            ]
            levelqueue = Int[ # negative values indicate removal of the corresponding element
                1,
                -1,
                1,
                -1,
                1,
                1,
                -1,
                1,
                1,
                -1,
                1,
                1,
                -2,
                -1,
                1,
                -2,
                2,
                1,
                -1,
                1,
                2,
                -3,
                -1,
                -3,
                -1,
                1,
                -1,
                -3,
                1,
                1,
                -1,
                1,
                2,
            ]

            l = SkipList{Tuple{Float64, Float64}}(; sortedby = x -> (x[1], -x[2]))
            l = copyfromcache(typeof(l), SkipListCache{Tuple{Float64,Float64}}(dataqueue, levelqueue); sortedby = l.sortedby)

            @test l.cache.data == dataqueue
            @test l.cache.levels == levelqueue

            @test skiplistsidentical(l, copyfromcache(l))
        end
    end

    @testset "non-Function callable sortedby" begin
        # sortedby accepts any callable, not just subtypes of Function
        struct NegKey end
        (::NegKey)(x) = -x
        key = NegKey()
        @test !(key isa Function)
        l = SkipList{Int,NegKey}(2, key)
        push!(l, 3); push!(l, 1); push!(l, 2)
        @test collect(l) == [3, 2, 1]
    end

    @testset "eltype inference" begin
        l = SkipList(3, 1, 2)
        @test eltype(l) == Int
        @test collect(l) == [1, 2, 3]
        l2 = SkipList(3, 1.0, 2)
        @test eltype(l2) == Float64
        @test collect(l2) == [1.0, 2.0, 3.0]
        # keyword args are forwarded
        l3 = SkipList(3, 1, 2; sortedby=-)
        @test collect(l3) == [3, 2, 1]
    end

    @testset "copy/empty/getindex with non-identity sortedby" begin
        l = SkipList{Int}(3, 1, 2, 4; sortedby = -)
        @test collect(l) == [4, 3, 2, 1]

        l2 = copy(l)
        @test collect(l2) == [4, 3, 2, 1]
        @test l2.sortedby === l.sortedby
        push!(l2, 5)
        @test collect(l) == [4, 3, 2, 1]   # copy is independent

        e = empty(l)
        @test length(e) == 0
        @test typeof(e) == typeof(l)
        @test e.sortedby === l.sortedby
        @test e.skipfactor == l.skipfactor

        @test collect(l[2:3]) == [3, 2]
        @test collect(l[2:1]) == Int[]
        @test typeof(l[2:3]) == typeof(l)
    end

    @testset "search" begin
        l = SkipList{Int}()
        # force a 3-level structure so descent through levels is exercised
        pushskip!(l, newnode(l, 5), 3)
        pushskip!(l, newnode(l, 2), 2)
        pushskip!(l, newnode(l, 8), 2)
        push!(l, 1); push!(l, 3); push!(l, 7)
        @test collect(l) == [1, 2, 3, 5, 7, 8]

        # value present in list
        @test search(l, 5).data == 5
        # between two values
        @test search(l, 4).data == 3
        # below all values — returns head sentinel
        @test search(l, 0) === l.head
        # above all values — returns last node
        @test search(l, 9).data == 8
        # single-level list
        ls = SkipList{Int}(3, 1, 2)
        @test search(ls, 2).data == 2
        @test search(ls, 0) === ls.head
    end

    @testset "push! with pre-created node" begin
        l = SkipList{Int}()
        node = newnode(l, 42)
        push!(l, node)
        @test collect(l) == [42]
        @test length(l) == 1
        # node from a different list is rejected
        l2 = SkipList{Int}()
        alien = newnode(l2, 99)
        @test_throws "does not belong to the list" push!(l, alien)
    end

    @testset "insertskipafter! cross-list error" begin
        l1 = SkipList{Int}()
        l2 = SkipList{Int}()
        n1 = newnode(l1, 1)
        n2 = newnode(l2, 2)
        @test_throws "must have the same parent list" insertskipafter!(n1, n2)
    end

    @testset "height on multi-level node" begin
        l = SkipList{Int}()
        pushskip!(l, newnode(l, 3), 1)
        pushskip!(l, newnode(l, 7), 1)
        # force a 3-level node so the inner height() loop runs at least twice
        pushskip!(l, newnode(l, 5), 3)
        @test l.nlevels == 3
        # find the bottom-level node for 5
        bottom = l.head.next
        while bottom.data != 5
            bottom = bottom.next
        end
        while !atbottom(bottom)
            bottom = bottom.down
        end
        # climb to the top
        top = bottom
        while !attop(top)
            top = top.up
        end
        @test top !== bottom
        @test height(top) == 3
        @test height(bottom) == 3
    end

    @testset "searchinsert! with level above nlevels" begin
        l = SkipList{Int}()
        pushskip!(l, newnode(l, 1), 1)
        pushskip!(l, newnode(l, 2), 1)
        @test l.nlevels == 1
        # pushing at level 3 on a non-empty list forces two addlevel! calls
        pushskip!(l, newnode(l, 5), 3)
        @test l.nlevels == 3
        @test collect(l) == [1, 2, 5]
    end

    @testset "emptycache! on non-nothing cache" begin
        l = SkipList{Int}()
        l.cache = SkipListCache{Int}()
        push!(l, 1); push!(l, 2); push!(l, 3)
        @test !isempty(l.cache.data)
        empty!(l)
        @test isempty(l.cache.data)
        @test isempty(l.cache.levels)
    end

    @testset "skiplistsidentical edge cases" begin
        l1 = SkipList{Int}(1, 2, 3)
        l2 = SkipList{Int}(1, 2, 3, 4)
        # different lengths → false
        @test !skiplistsidentical(l1, l2)
        # same length, different data → false
        l3 = SkipList{Int}()
        l4 = SkipList{Int}()
        pushskip!(l3, newnode(l3, 1), 1)
        pushskip!(l4, newnode(l4, 2), 1)
        @test !skiplistsidentical(l3, l4)
    end
end
