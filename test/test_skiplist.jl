@testset "SkipList" begin

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
        l = SkipList{Int}()
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
        end
    end
end
