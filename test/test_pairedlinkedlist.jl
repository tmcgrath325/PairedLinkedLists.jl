@testset "PairedLinkedList" begin

    @testset "empty list" begin
        l1 = PairedLinkedList{Int}()
        @test PairedLinkedList() == PairedLinkedList{Any}()
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
            l = PairedLinkedList{Int}(1:n...)

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
            l = PairedLinkedList{Int}()

            @testset "push back" begin
                for i = 1:n
                    push!(l, i)
                    @test last(l) == i
                    if i > 4
                        @test getindex(l, i) == i
                        @test getindex(l, 1:floor(Int, i/2)) == PairedLinkedList{Int}(1:floor(Int, i/2)...)
                        @test l[1:floor(Int, i/2)] == PairedLinkedList{Int}(1:floor(Int, i/2)...)
                        setindex!(l, 0, i - 2)
                        @test l == PairedLinkedList{Int}(1:i-3..., 0, i-1:i...)
                        setindex!(l, i - 2, i - 2)
                    end
                    @test lastindex(l) == i
                    @test length(l) == i
                    @test isempty(l) == false
                    for (j, k) in enumerate(l)
                        @test j == k
                    end
                    if i > 3
                        l1 = PairedLinkedList{Int32}(1:i...)
                        io = IOBuffer()
                        @test sprint(io -> show(io, iterate(l1))) == "(1, PairedListNode{Int32}(2))"
                        @test sprint(io -> show(io, iterate(l1, l1.head.next.next))) == "(2, PairedListNode{Int32}(3))"
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
            l = PairedLinkedList{Int}()

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
                l = PairedLinkedList{Int}(1:n...)

                @testset "append" begin
                    l2 = PairedLinkedList{Int}(n+1:2n...)
                    append!(l, l2)
                    @test l == PairedLinkedList{Int}(1:2n...)
                    @test collect(l) == collect(PairedLinkedList{Int}(1:2n...))
                    l3 = PairedLinkedList{Int}(1:n...)
                    append!(l3, n+1:2n...)
                    @test l3 == PairedLinkedList{Int}(1:2n...)
                    @test collect(l3) == collect(PairedLinkedList{Int}(1:2n...))
                end

                @testset "delete" begin
                    delete!(l, n+1:2n)
                    @test l == PairedLinkedList{Int}(1:n...)
                    for i = n:-1:1
                        delete!(l, i)
                    end
                    @test l == PairedLinkedList{Int}()
                    l = PairedLinkedList{Int}(1:n...)
                    @test_throws BoundsError delete!(l, n-1:2n)
                    @test_throws BoundsError delete!(l, 2n)
                end

                @testset "copy" begin
                    l2 = copy(l)
                    @test l == l2
                end

                @testset "reverse" begin
                    l2 = PairedLinkedList{Int}(n:-1:1...)
                    @test l == reverse(l2)
                end
            end
        end

        @testset "insert / popat" begin
            @testset "insert" begin
                l = PairedLinkedList{Int}(1:n...)
                @test_throws BoundsError insert!(l, 0, 0)
                @test_throws BoundsError insert!(l, n+2, 0)
                @test insert!(l, n+1, n+1) == PairedLinkedList{Int}(1:n+1...)
                @test insert!(l, 1, 0) == PairedLinkedList{Int}(0:n+1...)
                @test insert!(l, n+2, -1) == PairedLinkedList{Int}(0:n..., -1, n+1)
                for i=n:-1:1
                    insert!(l, n+2, i)
                end
                @test l == PairedLinkedList{Int}(0:n..., 1:n..., -1, n+1)
                @test l.len == 2n + 3
            end

            @testset "popat" begin
                l = PairedLinkedList{Int}(1:n...)
                @test_throws BoundsError popat!(l, 0)
                @test_throws BoundsError popat!(l, n+1)
                @test popat!(l, 0, missing) === missing
                @test popat!(l, n+1, Inf) === Inf
                for i=2:n-1
                    @test popat!(l, 2) == i
                end
                @test l == PairedLinkedList{Int}(1,n)
                @test l.len == 2

                l2 = PairedLinkedList{Int}(1:n...)
                for i=n-1:-1:2
                    @test popat!(l2, l2.len-1, 0) == i
                end
                @test l2 == PairedLinkedList{Int}(1,n)
                @test l2.len == 2
                @test popat!(l2, 1) == 1
                @test popat!(l2, 1) == n
                @test l2 == PairedLinkedList{Int}()
                @test l2.len == 0
                @test_throws BoundsError popat!(l2, 1)
            end
        end

        @testset "splice" begin
            @testset "no replacement" begin
                l = PairedLinkedList{Int}(1:2n...)
                @test splice!(l, n:1) == Int[]
                @test l == PairedLinkedList{Int}(1:2n...)
                @test collect(n+1:2n) == splice!(l, n+1:2n)
                @test l == PairedLinkedList{Int}(1:n...)
                for i = n:-1:1
                    @test i == splice!(l, i)
                end
                @test l == PairedLinkedList{Int}()
                @test_throws BoundsError splice!(l, 1)
                
            end
            @testset "with replacement" begin
                l = PairedLinkedList{Int}(1)  
                for i = 2:n
                    @test splice!(l, i-1:i-2, i) == Int[]
                    @test last(l) == i
                    @test l.len == i
                end
                @test l == PairedLinkedList{Int}(1:n...,)
                for i = 1:n
                    @test splice!(l, 1:0, i) == Int[]
                    @test first(l) == 1
                    @test l[2] == i
                    @test l.len == i + n
                end
                @test l == PairedLinkedList{Int}(1, n:-1:1..., 2:n...)
                previousdata = l[1:l.len]
                for i = 1:2n
                    @test splice!(l, i, i+2n) == previousdata[i]
                    @test l[i] == i+2n
                end
                @test l == PairedLinkedList{Int}(2n+1:4n...)
                @test splice!(l, n+1:2n, [3n+1, 3n+2]) == [3n+1:4n...,]
                @test l == PairedLinkedList{Int}(2n+1:3n+2...)
                @test l.len == n+2
                for i=1:n+2
                    @test splice!(l, i, -i) == i+2n
                end
                @test l == PairedLinkedList{Int}(-1:-1:-n-2...)
                @test l.len == n+2
                @test splice!(l, 1:n+2, 0) == collect(-1:-1:-n-2)
                @test l == PairedLinkedList{Int}(0)
                @test l.len == 1
            end
        end

        @testset "partners" begin
            l1 = PairedLinkedList{Int}(1:n...)  
            l2 = PairedLinkedList{Int}(1:n...)
            @test_throws ArgumentError addpartner!(newnode(l1, 1), newnode(l2, 1))
            addpartner!(l1, l2)

            @testset "add" begin
                for i=1:n
                    node1 = getnode(l1, 1)
                    node2 = getnode(l2, i)
                    prevpartner = node1.partner
                    addpartner!(node1, node2)
                    @test node1.partner === node2 && node2.partner === node1
                    @test haspartner(node1) && haspartner(node2)
                    if i != 1
                        @test prevpartner.partner === prevpartner
                        @test !haspartner(prevpartner)
                    end
                end

                for i=1:n
                    node1 = getnode(l1, i)
                    node2 = getnode(l2, n-i+1)
                    addpartner!(node1, node2)
                end
                partnersdata1 = Int[]
                partnersdata2 = Int[]
                for (n1, n2) in zip(IteratingListNodes(l1), IteratingListNodes(l2))
                    push!(partnersdata1, n1.partner.data)
                    push!(partnersdata2, n2.partner.data)
                end
                @test partnersdata1 == partnersdata2 == [n:-1:1...]

                for shift = 1:floor(n/2)
                    for i=1:n
                        node1 = getnode(l1, i)
                        node2 = getnode(l2, Int(mod(i + shift - 1, n) + 1))
                        addpartner!(node1, node2)
                    end
                    partnersdata1 = Int[]
                    partnersdata2 = Int[]
                    for (n1, n2) in zip(IteratingListNodes(l1), IteratingListNodes(l2))
                        push!(partnersdata1, n1.partner.data)
                        push!(partnersdata2, n2.partner.data)
                    end
                    @test circshift(partnersdata1, shift) == circshift(partnersdata2, -shift) == [1:n...]
                end
            end

            @testset "remove" begin
                for i=1:n
                    node = getnode(l1, i)
                    partner = node.partner
                    removepartner!(node)
                    @test node.partner === node
                    @test partner.partner === partner
                end
            end
        end
    end

    @testset "random operations" begin
        l1 = PairedLinkedList{Int}()
        l2 = PairedLinkedList{Int}()
        addpartner!(l1, l2)
        r1 = Int[]
        r2 = Int[]
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
                modfirst = rand(Bool)
                modr = modfirst ? r1 : r2
                modl = modfirst ? l1 : l2
                if 3*rand() < 1
                    push!(modr, x[i])
                    push!(modl, x[i])
                elseif rand(Bool)
                    pushfirst!(modr, x[i])
                    pushfirst!(modl, x[i])
                else
                    idx = idx = rand(1:length(modr)+1)
                    insert!(modr, idx, x[i])
                    insert!(modl, idx, x[i])
                end
            end

            @test length(l1) == length(r1)
            @test collect(l1) == r1
            @test length(l2) == length(r2)
            @test collect(l2) == r2

            
            lr = try rand(0:min(length(r1), length(r2))-1)
            catch
                0
            end
            for i = 1 : lr
                modfirst = rand(Bool)
                modr = modfirst ? r1 : r2
                modl = modfirst ? l1 : l2
                if 3*rand() < 1
                    pop!(modr)
                    pop!(modl)
                elseif rand(Bool)
                    popfirst!(modr)
                    popfirst!(modl)
                else
                    idx = rand([1:length(modr)]...)
                    popat!(modr, idx)
                    PairedLinkedLists.popat!(modl, idx)
                end
            end

            @test length(l1) == length(r1)
            @test collect(l1) == r1
            @test length(l2) == length(r2)
            @test collect(l2) == r2

            ls = try rand(0:min(length(r1), length(r2)))
            catch 
                0
            end
            x = rand(1:1000, 2*ls)
            for i = 1 : ls
                modfirst = rand(Bool)
                modr = modfirst ? r1 : r2
                modl = modfirst ? l1 : l2
                idx = rand(1:length(modr))
                if rand(Bool)
                    splice!(modr, idx)
                    splice!(modl, idx)
                else
                    splice!(modr, idx, x[i])
                    splice!(modl, idx, x[i])
                end
            end

            @test length(l1) == length(r1)
            @test collect(l1) == r1
            @test length(l2) == length(r2)
            @test collect(l2) == r2

            for i = 1:min(length(l1), length(l2), 20)
                if rand(Bool)
                    i = rand(1:length(l1))
                    j = rand(1:length(l2))
                    addpartner!(getnode(l1, i), getnode(l2, j))
                end
                if rand(Bool)
                    i = rand(1:length(l1))
                    j = rand(1:length(l2))
                    addpartner!(getnode(l2, j), getnode(l1, i))
                end
            end
            partnersdata1 = Int[]
            partnersdata2 = Int[]
            for n in IteratingListNodes(l1)
                haspartner(n) && push!(partnersdata1, n.partner.data)
            end
            for n in IteratingListNodes(l2)
                haspartner(n) && push!(partnersdata2, n.partner.partner.data)
            end
            match = length(partnersdata1) == length(partnersdata2)
            for d1 in partnersdata1
                !match && break
                match = d1 ∈ partnersdata2
            end
            @test match

            for i = 1:min(length(l1), length(l2), 20)
                if rand(Bool)
                    i = rand(1:length(l1))
                    removepartner!(getnode(l1, i))
                end
                if rand(Bool)
                    j = rand(1:length(l2))
                    removepartner!(getnode(l2, j))
                end
            end
            partnersdata1 = Int[]
            partnersdata2 = Int[]
            for n in IteratingListNodes(l1)
                haspartner(n) && push!(partnersdata1, n.partner.data)
            end
            for n in IteratingListNodes(l2)
                haspartner(n) && push!(partnersdata2, n.partner.partner.data)
            end
            match = length(partnersdata1) == length(partnersdata2)
            for d1 in partnersdata1
                !match && break
                match = d1 ∈ partnersdata2
            end
            @test match
        end
    end
end
