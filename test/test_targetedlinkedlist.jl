@testset "TargetedLinkedList" begin

    @testset "empty list" begin
        l1 = TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}()
        @test iterate(l1) === nothing
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
            l = TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}(1:n...)

            @testset "data" begin
                for (i,data) in enumerate(l)
                    @test data == i
                end
                for (i,data) in enumerate(IteratingListData(l))
                    @test data == i
                end
                for (i,data) in enumerate(IteratingListData(l; rev=true))
                    @test data == n-i+1
                end
                for (i,data) in enumerate(IteratingListData(l.head.next.next))
                    @test data == i+1
                end
                for (i,data) in enumerate(IteratingListData(l.tail.prev.prev; rev=true))
                    @test data == n-i
                end
            end

            @testset "nodes" begin
                for (i,node) in enumerate(l.head.next)
                    @test node == newnode(l,i)
                end
                for (i,node) in enumerate(IteratingListNodes(l))
                    @test node == newnode(l,i)
                end
                for (i,node) in enumerate(IteratingListNodes(l; rev=true))
                    @test node == newnode(l,n-i+1)
                end
                for (i,node) in enumerate(IteratingListNodes(l.head.next.next))
                    @test node == newnode(l,i+1)
                end
                for (i,node) in enumerate(IteratingListNodes(l.tail.prev.prev; rev=true))
                    @test node == newnode(l,n-i)
                end
            end
        end

        @testset "push back / pop back" begin
            l = TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}()
            dummy_list = TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}()
            @test_throws ArgumentError insertnode!(newnode(dummy_list, 0), l.head)

            @testset "push back" begin
                for i = 1:n
                    push!(l, i)
                    @test last(l) == i
                    if i > 4
                        @test getindex(l, i) == i
                        @test getindex(l, 1:floor(Int, i/2)) == TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}(1:floor(Int, i/2)...)
                        @test l[1:floor(Int, i/2)] == TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}(1:floor(Int, i/2)...)
                        setindex!(l, 0, i - 2)
                        @test l == TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}(1:i-3..., 0, i-1:i...)
                        setindex!(l, i - 2, i - 2)
                    end
                    @test lastindex(l) == i
                    @test length(l) == i
                    @test isempty(l) == false
                    for (j, k) in enumerate(l)
                        @test j == k
                    end
                    if i > 3
                        l1 = TargetedLinkedList{Int32,DoublyLinkedList{Int32},ListNode{Int32,DoublyLinkedList{Int32}}}(1:i...)
                        io = IOBuffer()
                        if VERSION > VersionNumber(1,7,0)   # type parameters are spaced differently in older versions
                            @test sprint(io -> show(io, iterate(l1))) == "(1, TargetedListNode{Int32, DoublyLinkedList{Int32}, ListNode{Int32, DoublyLinkedList{Int32}}, TargetedLinkedList{Int32, DoublyLinkedList{Int32}, ListNode{Int32, DoublyLinkedList{Int32}}}}(2))"
                            @test sprint(io -> show(io, iterate(l1, l1.head.next.next))) == "(2, TargetedListNode{Int32, DoublyLinkedList{Int32}, ListNode{Int32, DoublyLinkedList{Int32}}, TargetedLinkedList{Int32, DoublyLinkedList{Int32}, ListNode{Int32, DoublyLinkedList{Int32}}}}(3))"
                        end
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
            l = TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}()

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
                l0 = DoublyLinkedList{Int}(1:n...)
                l = TargetedLinkedList(l0)
                push!(l, 1:n...)

                @testset "append" begin
                    l2 = TargetedLinkedList(l0)
                    push!(l2, n+1:2n...)
                    @test_throws MethodError append!(l, l0)
                    append!(l, l2)
                    @test l == TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}(1:2n...)
                    @test collect(l) == collect(TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}(1:2n...))
                    l3 = TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}(1:n...)
                    append!(l3, n+1:2n...)
                    @test l3 == TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}(1:2n...)
                    @test collect(l3) == collect(TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}(1:2n...))
                end

                @testset "delete" begin
                    delete!(l, n+1:2n)
                    @test l == TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}(1:n...)
                    for i = n:-1:1
                        delete!(l, i)
                    end
                    @test l == TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}()
                    l = TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}(1:n...)
                    @test_throws BoundsError delete!(l, n-1:2n)
                    @test_throws BoundsError delete!(l, 2n)
                end

                @testset "copy" begin
                    l2 = copy(l)
                    @test l == l2
                end

                @testset "reverse" begin
                    l2 = TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}(n:-1:1...)
                    @test l == reverse(l2)
                end
            end
        end

        @testset "insert / popat" begin
            @testset "insert" begin
                l = TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}(1:n...)
                @test_throws BoundsError insert!(l, 0, 0)
                @test_throws BoundsError insert!(l, n+2, 0)
                @test insert!(l, n+1, n+1) == TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}(1:n+1...)
                @test insert!(l, 1, 0) == TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}(0:n+1...)
                @test insert!(l, n+2, -1) == TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}(0:n..., -1, n+1)
                for i=n:-1:1
                    insert!(l, n+2, i)
                end
                @test l == TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}(0:n..., 1:n..., -1, n+1)
                @test l.len == 2n + 3
            end

            @testset "popat" begin
                l = TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}(1:n...)
                @test_throws BoundsError popat!(l, 0)
                @test_throws BoundsError popat!(l, n+1)
                @test popat!(l, 0, missing) === missing
                @test popat!(l, n+1, Inf) === Inf
                for i=2:n-1
                    @test popat!(l, 2) == i
                end
                @test l == TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}(1,n)
                @test l.len == 2

                l2 = TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}(1:n...)
                for i=n-1:-1:2
                    @test popat!(l2, l2.len-1, 0) == i
                end
                @test l2 == TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}(1,n)
                @test l2.len == 2
                @test popat!(l2, 1) == 1
                @test popat!(l2, 1) == n
                @test l2 == TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}()
                @test l2.len == 0
                @test_throws BoundsError popat!(l2, 1)
            end
        end

        @testset "splice" begin
            @testset "no replacement" begin
                l = TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}(1:2n...)
                @test splice!(l, n:1) == Int[]
                @test l == TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}(1:2n...)
                @test collect(n+1:2n) == splice!(l, n+1:2n)
                @test l == TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}(1:n...)
                for i = n:-1:1
                    @test i == splice!(l, i)
                end
                @test l == TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}()
                @test_throws BoundsError splice!(l, 1)
                
            end
            @testset "with replacement" begin
                l = TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}(1)  
                for i = 2:n
                    @test splice!(l, i-1:i-2, i) == Int[]
                    @test last(l) == i
                    @test l.len == i
                end
                @test l == TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}(1:n...,)
                for i = 1:n
                    @test splice!(l, 1:0, i) == Int[]
                    @test first(l) == 1
                    @test l[2] == i
                    @test l.len == i + n
                end
                @test l == TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}(1, n:-1:1..., 2:n...)
                previousdata = l[1:l.len]
                for i = 1:2n
                    @test splice!(l, i, i+2n) == previousdata[i]
                    @test l[i] == i+2n
                end
                @test l == TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}(2n+1:4n...)
                @test splice!(l, n+1:2n, [3n+1, 3n+2]) == [3n+1:4n...,]
                @test l == TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}(2n+1:3n+2...)
                @test l.len == n+2
                for i=1:n+2
                    @test splice!(l, i, -i) == i+2n
                end
                @test l == TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}(-1:-1:-n-2...)
                @test l.len == n+2
                @test splice!(l, 1:n+2, 0) == collect(-1:-1:-n-2)
                @test l == TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}(0)
                @test l.len == 1
            end
        end

        @testset "partners" begin
            l0 = DoublyLinkedList{Int}(1:n...)
            l1 = TargetedLinkedList(l0)  
            push!(l1, 1:n...)
            l2 = TargetedLinkedList(l1)
            push!(l2, 1:n...)
            @test_throws MethodError addpartner!(newnode(l1, 1), newnode(l2, 1))
            @test_throws MethodError addpartner!(newnode(l2, 1), newnode(l0, 1))

            @testset "add" begin
                for i=1:n
                    node1 = getnode(l1, i)
                    node2 = getnode(l2, 1)
                    prevpartner = node1.partner
                    addpartner!(node2, node1)
                    @test node2.partner === node1 && node1.partner === node1
                    @test !haspartner(node1) && haspartner(node2)
                end

                for i=1:n
                    node0 = getnode(l0, i)
                    node1 = getnode(l1, i)
                    node2 = getnode(l2, n-i+1)
                    addpartner!(node1, node0)
                    addpartner!(node2, node1)
                end
                partnersdata1 = Int[]
                partnersdata2 = Int[]
                for (n1, n2) in zip(IteratingListNodes(l1), IteratingListNodes(l2))
                    push!(partnersdata1, n1.partner.data)
                    push!(partnersdata2, n2.partner.data)
                end
                @test partnersdata1 == [1:n...]
                @test partnersdata2 == [n:-1:1...]
            end

            @testset "remove" begin
                for i=1:n
                    node = getnode(l2, i)
                    partner = node.partner
                    removepartner!(node)
                    @test node.partner === node
                    @test partner.partner === getnode(l0, n-i+1)
                end
            end
        end
    end

    @testset "random operations" begin
        l1 = TargetedLinkedList{Int,DoublyLinkedList{Int},ListNode{Int,DoublyLinkedList{Int}}}()
        l2 = TargetedLinkedList(l1)
        r1 = Int[]
        r2 = Int[]
        p = Int[]
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
                    !modfirst && push!(p, 0)
                elseif rand(Bool)
                    pushfirst!(modr, x[i])
                    pushfirst!(modl, x[i])
                    !modfirst && pushfirst!(p, 0)
                else
                    idx = idx = rand(1:length(modr)+1)
                    insert!(modr, idx, x[i])
                    insert!(modl, idx, x[i])
                    !modfirst && insert!(p, idx, 0)
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
                    node = getnode(modl, 1)
                    pop!(modl)
                    !modfirst && pop!(p)
                elseif rand(Bool)
                    popfirst!(modr)
                    node = getnode(modl, length(modl))
                    popfirst!(modl)
                    !modfirst && popfirst!(p)
                else
                    idx = rand([1:length(modr)]...)
                    popat!(modr, idx)
                    node = getnode(modl, idx)
                    PairedLinkedLists.popat!(modl, idx)
                    !modfirst && popat!(p, idx)
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
                    !modfirst && splice!(p, idx)
                else
                    splice!(modr, idx, x[i])
                    splice!(modl, idx, x[i])
                    !modfirst && splice!(p, idx, 0)
                end
            end

            @test length(l1) == length(r1)
            @test collect(l1) == r1
            @test length(l2) == length(r2)
            @test collect(l2) == r2

            for i = 1:min(length(l1), length(l2), 20)
                if rand(Bool)
                    i = rand(1:length(l2))
                    j = rand(1:length(l1))
                    addpartner!(getnode(l2, i), getnode(l1, j))
                    p[i] = l1[j]
                end
            end
            partnersdata = Int[]
            for n in IteratingListNodes(l2)
                haspartner(n) && push!(partnersdata, n.partner.partner.data)
            end
            @test partnersdata == [val for val in filter(x->x>0, p)]

            for i = 1:min(length(l1), length(l2), 20)
                if rand(Bool)
                    i = rand(1:length(l2))
                    removepartner!(getnode(l2, i))
                    p[i] = 0
                end
            end
            partnersdata = Int[]
            for n in IteratingListNodes(l2)
                haspartner(n) && push!(partnersdata, n.partner.partner.data)
            end
            @test partnersdata == [val for val in filter(x->x>0, p)]
        end
    end
end
