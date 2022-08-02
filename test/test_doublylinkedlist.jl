@testset "DoublyLinkedList" begin

    @testset "empty list" begin
        l1 = DoublyLinkedList{Int}()
        @test DoublyLinkedList() == DoublyLinkedList{Any}()
        @test iterate(l1) === nothing
        @test iteratenodes(l1) === nothing
        @test isempty(l1)
        @test length(l1) == 0
        @test lastindex(l1) == 0
        @test collect(l1) == Int[]
        @test eltype(l1) == Int
        @test eltype(typeof(l1)) == Int
        @test_throws ArgumentError pop!(l1)
        @test_throws ArgumentError popfirst!(l1)
    end

    @testset "core functionality" begin
        n = 10

        @testset "iterate" begin
            l = DoublyLinkedList{Int}(1:n...)

            @testset "data" begin
                for (i,data) in enumerate(l)
                    @test data == i
                end
                for (i,data) in enumerate(IteratingListData(l))
                    @test data == i
                end
                for (i,data) in enumerate(IteratingListData(l.head.next.next))
                    @test data == i+1
                end
            end

            @testset "nodes" begin
                for (i,node) in enumerate(l.head.next)
                    @test node == newnode(l,i)
                end
                for (i,node) in enumerate(IteratingListNodes(l))
                    @test node == newnode(l,i)
                end
                for (i,node) in enumerate(IteratingListNodes(l.head.next.next))
                    @test node == newnode(l,i+1)
                end
            end
        end

        @testset "push back / pop back" begin
            l = DoublyLinkedList{Int}()
            dummy_list = DoublyLinkedList{Int}()
            @test_throws ArgumentError insertnode!(newnode(dummy_list, 0), l.head)

            @testset "push back" begin
                for i = 1:n
                    push!(l, i)
                    @test last(l) == i
                    if i > 4
                        @test getindex(l, i) == i
                        @test getindex(l, 1:floor(Int, i/2)) == DoublyLinkedList{Int}(1:floor(Int, i/2)...)
                        @test l[1:floor(Int, i/2)] == DoublyLinkedList{Int}(1:floor(Int, i/2)...)
                        setindex!(l, 0, i - 2)
                        @test l == DoublyLinkedList{Int}(1:i-3..., 0, i-1:i...)
                        setindex!(l, i - 2, i - 2)
                    end
                    @test lastindex(l) == i
                    @test length(l) == i
                    @test isempty(l) == false
                    for (j, k) in enumerate(l)
                        @test j == k
                    end
                    if i > 3
                        l1 = DoublyLinkedList{Int32}(1:i...)
                        io = IOBuffer()
                        @test sprint(io -> show(io, iterate(l1))) == "(1, ListNode{Int32}(2))"
                        @test sprint(io -> show(io, iterate(l1, l1.head.next.next))) == "(2, ListNode{Int32}(3))"
                    end
                    cl = collect(l)
                    @test isa(cl, Vector{Int})
                    @test cl == collect(1:i)
                end
            end

            @testset "pop back" begin
                for i = 1:n
                    x = pop!(l)
                    @test length(l) == n - i
                    @test isempty(l) == (i == n)
                    @test x == n - i + 1
                    cl = collect(l)
                    @test cl == collect(1:n-i)
                end
            end
        end

        @testset "push front / pop front" begin
            l = DoublyLinkedList{Int}()

            @testset "push front" begin
                for i = 1:n
                    pushfirst!(l, i)
                    @test first(l) == i
                    @test length(l) == i
                    @test isempty(l) == false
                    cl = collect(l)
                    @test isa(cl, Vector{Int})
                    @test cl == collect(i:-1:1)
                end
            end

            @testset "pop front" begin
                for i = 1:n
                    x = popfirst!(l)
                    @test length(l) == n - i
                    @test isempty(l) == (i == n)
                    @test x == n - i + 1
                    cl = collect(l)
                    @test cl == collect(n-i:-1:1)
                end
            end

        end

        @testset "append / delete / copy / reverse" begin
            for i = 1:n
                l = DoublyLinkedList{Int}(1:n...)

                @testset "append" begin
                    l2 = DoublyLinkedList{Int}(n+1:2n...)
                    append!(l, l2)
                    @test l == DoublyLinkedList{Int}(1:2n...)
                    @test collect(l) == collect(DoublyLinkedList{Int}(1:2n...))
                    l3 = DoublyLinkedList{Int}(1:n...)
                    append!(l3, n+1:2n...)
                    @test l3 == DoublyLinkedList{Int}(1:2n...)
                    @test collect(l3) == collect(DoublyLinkedList{Int}(1:2n...))
                end

                @testset "delete" begin
                    delete!(l, n+1:2n)
                    @test l == DoublyLinkedList{Int}(1:n...)
                    for i = n:-1:1
                        delete!(l, i)
                    end
                    @test l == DoublyLinkedList{Int}()
                    l = DoublyLinkedList{Int}(1:n...)
                    @test_throws BoundsError delete!(l, n-1:2n)
                    @test_throws BoundsError delete!(l, 2n)
                end

                @testset "copy" begin
                    l2 = copy(l)
                    @test l == l2
                end

                @testset "reverse" begin
                    l2 = DoublyLinkedList{Int}(n:-1:1...)
                    @test l == reverse(l2)
                end
            end
        end

        @testset "map / filter" begin
            for i = 1:n
                @testset "map" begin
                    l = DoublyLinkedList{Int}(1:n...)
                    @test map(x -> 2x, l) == DoublyLinkedList{Int}(2:2:2n...)
                    l2 = DoublyLinkedList{Float64}()
                    @test map(x -> x*im, l2) == DoublyLinkedList{Complex{Float64}}()
                    @test map(Int32, l2) == DoublyLinkedList{Int32}()
                    f(x) = x % 2 == 0 ? convert(Int8, x) : convert(Float16, x)
                    @test typeof(map(f, l)) == DoublyLinkedList{Real}
                end

                @testset "filter" begin
                    l = DoublyLinkedList{Int}(1:n...)
                    @test filter(x -> x % 2 == 0, l) == DoublyLinkedList{Int}(2:2:n...)
                end

                @testset "show" begin
                    l = DoublyLinkedList{Int32}(1:n...)
                    io = IOBuffer()
                    @test sprint(io -> show(io, l.head.next)) == "$(typeof(l.head.next))($(l.head.next.data))"
                    io1 = IOBuffer()
                    write(io1, "DoublyLinkedList{Int32}(");
                    write(io1, join(l, ", "));
                    write(io1, ")")
                    seekstart(io1)
                    @test sprint(io -> show(io, l)) == read(io1, String)
                end
            end
        end

        @testset "insert / popat" begin
            @testset "insert" begin
                l = DoublyLinkedList{Int}(1:n...)
                @test_throws BoundsError insert!(l, 0, 0)
                @test_throws BoundsError insert!(l, n+2, 0)
                @test insert!(l, n+1, n+1) == DoublyLinkedList{Int}(1:n+1...)
                @test insert!(l, 1, 0) == DoublyLinkedList{Int}(0:n+1...)
                @test insert!(l, n+2, -1) == DoublyLinkedList{Int}(0:n..., -1, n+1)
                for i=n:-1:1
                    insert!(l, n+2, i)
                end
                @test l == DoublyLinkedList{Int}(0:n..., 1:n..., -1, n+1)
                @test l.len == 2n + 3
            end

            @testset "popat" begin
                l = DoublyLinkedList{Int}(1:n...)
                @test_throws BoundsError popat!(l, 0)
                @test_throws BoundsError popat!(l, n+1)
                @test popat!(l, 0, missing) === missing
                @test popat!(l, n+1, Inf) === Inf
                for i=2:n-1
                    @test popat!(l, 2) == i
                end
                @test l == DoublyLinkedList{Int}(1,n)
                @test l.len == 2

                l2 = DoublyLinkedList{Int}(1:n...)
                for i=n-1:-1:2
                    @test popat!(l2, l2.len-1, 0) == i
                end
                @test l2 == DoublyLinkedList{Int}(1,n)
                @test l2.len == 2
                @test popat!(l2, 1) == 1
                @test popat!(l2, 1) == n
                @test l2 == DoublyLinkedList{Int}()
                @test l2.len == 0
                @test_throws BoundsError popat!(l2, 1)
            end
        end

        @testset "splice" begin
            @testset "no replacement" begin
                l = DoublyLinkedList{Int}(1:2n...)
                @test splice!(l, n:1) == Int[]
                @test l == DoublyLinkedList{Int}(1:2n...)
                @test collect(n+1:2n) == splice!(l, n+1:2n)
                @test l == DoublyLinkedList{Int}(1:n...)
                for i = n:-1:1
                    @test i == splice!(l, i)
                end
                @test l == DoublyLinkedList{Int}()
                @test_throws BoundsError splice!(l, 1)
                
            end
            @testset "with replacement" begin
                l = DoublyLinkedList{Int}(1)  
                for i = 2:n
                    @test splice!(l, i-1:i-2, i) == Int[]
                    @test last(l) == i
                    @test l.len == i
                end
                @test l == DoublyLinkedList{Int}(1:n...,)
                for i = 1:n
                    @test splice!(l, 1:0, i) == Int[]
                    @test first(l) == 1
                    @test l[2] == i
                    @test l.len == i + n
                end
                @test l == DoublyLinkedList{Int}(1, n:-1:1..., 2:n...)
                previousdata = l[1:l.len]
                for i = 1:2n
                    @test splice!(l, i, i+2n) == previousdata[i]
                    @test l[i] == i+2n
                end
                @test l == DoublyLinkedList{Int}(2n+1:4n...)
                @test splice!(l, n+1:2n, [3n+1, 3n+2]) == [3n+1:4n...,]
                @test l == DoublyLinkedList{Int}(2n+1:3n+2...)
                @test l.len == n+2
                for i=1:n+2
                    @test splice!(l, i, -i) == i+2n
                end
                @test l == DoublyLinkedList{Int}(-1:-1:-n-2...)
                @test l.len == n+2
                @test splice!(l, 1:n+2, 0) == collect(-1:-1:-n-2)
                @test l == DoublyLinkedList{Int}(0)
                @test l.len == 1
            end
        end
    end

    @testset "random operations" begin
        l = DoublyLinkedList{Int}()
        r = Int[]
        m = 100

        # here for Julia 1.0 compatibility
        function popat!(a::Vector, i::Int64)
            val = a[i]
            deleteat!(a, i)
            return val
        end

        for k = 1 : m
            la = rand(2:20)
            x = rand(1:1000, la)

            for i = 1 : la
                if 3*rand() < 1
                    push!(r, x[i])
                    push!(l, x[i])
                elseif rand(Bool)
                    pushfirst!(r, x[i])
                    pushfirst!(l, x[i])
                else
                    idx = idx = rand(1:length(r)+1)
                    insert!(r, idx, x[i])
                    insert!(l, idx, x[i])
                end
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
                    idx = rand([1:length(r)]...)
                    popat!(r, idx)
                    PairedLinkedLists.popat!(l, idx)
                end
            end

            @test length(l) == length(r)
            @test collect(l) == r

            ls = rand(0:length(r))
            x = rand(1:1000, 2*ls)
            for i = 1 : ls
                idx = rand(1:length(r))
                if rand(Bool)
                    splice!(r, idx)
                    splice!(l, idx)
                else
                    splice!(r, idx, x[i])
                    splice!(l, idx, x[i])
                end
            end

            @test length(l) == length(r)
            @test collect(l) == r
        end
    end
end
