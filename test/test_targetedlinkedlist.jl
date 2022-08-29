@testset "TargetedLinkedList" begin

    @testset "empty list" begin
        l1 = TargetedLinkedList{Int,DoublyLinkedList{Int}}()
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
            l = TargetedLinkedList{Int,DoublyLinkedList{Int}}(1:n...)

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
            l = TargetedLinkedList{Int,DoublyLinkedList{Int}}()
            dummy_list = TargetedLinkedList{Int,DoublyLinkedList{Int}}()
            @test_throws ArgumentError insertafter!(newnode(dummy_list, 0), l.head)

            @testset "push back" begin
                for i = 1:n
                    push!(l, i)
                    @test last(l) == i
                    if i > 4
                        @test getindex(l, i) == i
                        @test getindex(l, 1:floor(Int, i/2)) == TargetedLinkedList{Int,DoublyLinkedList{Int}}(1:floor(Int, i/2)...)
                        @test l[1:floor(Int, i/2)] == TargetedLinkedList{Int,DoublyLinkedList{Int}}(1:floor(Int, i/2)...)
                        setindex!(l, 0, i - 2)
                        @test l == TargetedLinkedList{Int,DoublyLinkedList{Int}}(1:i-3..., 0, i-1:i...)
                        setindex!(l, i - 2, i - 2)
                    end
                    @test lastindex(l) == i
                    @test length(l) == i
                    @test isempty(l) == false
                    @test keys(l) == collect(1:i)
                    for (j, k) in enumerate(l)
                        @test j == k
                    end
                    if i > 3 && VERSION > VersionNumber(1,7,0)
                        l1 = TargetedLinkedList{Int32,DoublyLinkedList{Int32}}(1:i...)
                        io = IOBuffer()
                        @test sprint(io -> show(io, iterate(l1))) == "(1, TargetedListNode{Int32, ListNode{Int32, DoublyLinkedList{Int32}}, TargetedLinkedList{Int32, DoublyLinkedList{Int32}, ListNode{Int32, DoublyLinkedList{Int32}}}}(2))"
                        @test sprint(io -> show(io, iterate(l1, l1.head.next.next))) == "(2, TargetedListNode{Int32, ListNode{Int32, DoublyLinkedList{Int32}}, TargetedLinkedList{Int32, DoublyLinkedList{Int32}, ListNode{Int32, DoublyLinkedList{Int32}}}}(3))"
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
            l = TargetedLinkedList{Int,DoublyLinkedList{Int}}()

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
                    @test l == TargetedLinkedList{Int,DoublyLinkedList{Int}}(1:2n...)
                    @test collect(l) == collect(TargetedLinkedList{Int,DoublyLinkedList{Int}}(1:2n...))
                    l3 = TargetedLinkedList{Int,DoublyLinkedList{Int}}(1:n...)
                    append!(l3, n+1:2n...)
                    @test l3 == TargetedLinkedList{Int,DoublyLinkedList{Int}}(1:2n...)
                    @test collect(l3) == collect(TargetedLinkedList{Int,DoublyLinkedList{Int}}(1:2n...))
                end

                @testset "delete" begin
                    delete!(l, n+1:2n)
                    @test l == TargetedLinkedList{Int,DoublyLinkedList{Int}}(1:n...)
                    for i = n:-1:1
                        delete!(l, i)
                    end
                    @test l == TargetedLinkedList{Int,DoublyLinkedList{Int}}()
                    l = TargetedLinkedList{Int,DoublyLinkedList{Int}}(1:n...)
                    @test_throws BoundsError delete!(l, n-1:2n)
                    @test_throws BoundsError delete!(l, 2n)
                end

                @testset "copy" begin
                    dl = DoublyLinkedList{Int}(1:n...)
                    l2 = TargetedLinkedList(dl)
                    for n in ListNodeIterator(dl)
                        push!(l2, n.data)
                        addtarget!(tail(l2), n)
                    end
                    l3 = TargetedLinkedList(l2)
                    for n in ListNodeIterator(l2)
                        push!(l3, n.data)
                        addtarget!(tail(l3), n)
                    end
                    l4 = copy(l2)
                    @test l4 == l2
                    @test [x.target for x in ListNodeIterator(l4)] == [x.target for x in ListNodeIterator(l2)]
                    l5 = typeof(l2)()
                    copy!(l5, l2)
                    @test l5 == l2
                    @test [x.target for x in ListNodeIterator(l5)] == [x.target for x in ListNodeIterator(l2)]
                    l6 = typeof(l3)()
                    push!(l6, 1:2*i...)
                    copy!(l6, l3)
                    @test l6 == l3
                    @test [x.target for x in ListNodeIterator(l6)] == [x.target for x in ListNodeIterator(l3)]
                end

                @testset "reverse" begin
                    l2 = TargetedLinkedList{Int,DoublyLinkedList{Int}}(n:-1:1...)
                    @test l == reverse(l2)
                end
            end
        end

        @testset "filter / show" begin
            for i = 1:n
                @testset "filter" begin
                    l = TargetedLinkedList{Int,DoublyLinkedList{Int}}(1:n...)
                    @test filter(x -> x % 2 == 0, l) == typeof(l)(2:2:n...)
                end

                @testset "show" begin
                    l = TargetedLinkedList{Int,DoublyLinkedList{Int}}(1:n...)
                    io = IOBuffer()
                    @test sprint(io -> show(io, head(l))) == "$(typeof(head(l)))($(head(l).data))"
                    io1 = IOBuffer()
                    write(io1, "TargetedLinkedList{Int64, DoublyLinkedList{Int64}, ListNode{Int64, DoublyLinkedList{Int64}}}(");
                    write(io1, join(l, ", "));
                    write(io1, ")")
                    seekstart(io1)
                    @test sprint(io -> show(io, l)) == read(io1, String)
                end
            end
        end

        @testset "insert / popat" begin
            @testset "insert" begin
                l = TargetedLinkedList{Int,DoublyLinkedList{Int}}(1:n...)
                @test_throws BoundsError insert!(l, 0, 0)
                @test_throws BoundsError insert!(l, n+2, 0)
                @test insert!(l, n+1, n+1) == TargetedLinkedList{Int,DoublyLinkedList{Int}}(1:n+1...)
                @test insert!(l, 1, 0) == TargetedLinkedList{Int,DoublyLinkedList{Int}}(0:n+1...)
                @test insert!(l, n+2, -1) == TargetedLinkedList{Int,DoublyLinkedList{Int}}(0:n..., -1, n+1)
                for i=n:-1:1
                    insert!(l, n+2, i)
                end
                @test l == TargetedLinkedList{Int,DoublyLinkedList{Int}}(0:n..., 1:n..., -1, n+1)
                @test l.len == 2n + 3
            end

            @testset "popat" begin
                l = TargetedLinkedList{Int,DoublyLinkedList{Int}}(1:n...)
                @test_throws BoundsError popat!(l, 0)
                @test_throws BoundsError popat!(l, n+1)
                @test popat!(l, 0, missing) === missing
                @test popat!(l, n+1, Inf) === Inf
                for i=2:n-1
                    @test popat!(l, 2) == i
                end
                @test l == TargetedLinkedList{Int,DoublyLinkedList{Int}}(1,n)
                @test l.len == 2

                l2 = TargetedLinkedList{Int,DoublyLinkedList{Int}}(1:n...)
                for i=n-1:-1:2
                    @test popat!(l2, l2.len-1, 0) == i
                end
                @test l2 == TargetedLinkedList{Int,DoublyLinkedList{Int}}(1,n)
                @test l2.len == 2
                @test popat!(l2, 1) == 1
                @test popat!(l2, 1) == n
                @test l2 == TargetedLinkedList{Int,DoublyLinkedList{Int}}()
                @test l2.len == 0
                @test_throws BoundsError popat!(l2, 1)
            end
        end

        @testset "splice" begin
            @testset "no replacement" begin
                l = TargetedLinkedList{Int,DoublyLinkedList{Int}}(1:2n...)
                @test splice!(l, n:1) == Int[]
                @test l == TargetedLinkedList{Int,DoublyLinkedList{Int}}(1:2n...)
                @test collect(n+1:2n) == splice!(l, n+1:2n)
                @test l == TargetedLinkedList{Int,DoublyLinkedList{Int}}(1:n...)
                for i = n:-1:1
                    @test i == splice!(l, i)
                end
                @test l == TargetedLinkedList{Int,DoublyLinkedList{Int}}()
                @test_throws BoundsError splice!(l, 1)
                
            end
            @testset "with replacement" begin
                l = TargetedLinkedList{Int,DoublyLinkedList{Int}}(1)  
                for i = 2:n
                    @test splice!(l, i-1:i-2, i) == Int[]
                    @test last(l) == i
                    @test l.len == i
                end
                @test l == TargetedLinkedList{Int,DoublyLinkedList{Int}}(1:n...,)
                for i = 1:n
                    @test splice!(l, 1:0, i) == Int[]
                    @test first(l) == 1
                    @test l[2] == i
                    @test l.len == i + n
                end
                @test l == TargetedLinkedList{Int,DoublyLinkedList{Int}}(1, n:-1:1..., 2:n...)
                previousdata = l[1:l.len]
                for i = 1:2n
                    @test splice!(l, i, i+2n) == previousdata[i]
                    @test l[i] == i+2n
                end
                @test l == TargetedLinkedList{Int,DoublyLinkedList{Int}}(2n+1:4n...)
                @test splice!(l, n+1:2n, [3n+1, 3n+2]) == [3n+1:4n...,]
                @test l == TargetedLinkedList{Int,DoublyLinkedList{Int}}(2n+1:3n+2...)
                @test l.len == n+2
                for i=1:n+2
                    @test splice!(l, i, -i) == i+2n
                end
                @test l == TargetedLinkedList{Int,DoublyLinkedList{Int}}(-1:-1:-n-2...)
                @test l.len == n+2
                @test splice!(l, 1:n+2, 0) == collect(-1:-1:-n-2)
                @test l == TargetedLinkedList{Int,DoublyLinkedList{Int}}(0)
                @test l.len == 1
            end
        end

        @testset "empty" begin
            l = TargetedLinkedList{Int,DoublyLinkedList{Int}}(1:n...)
            @test length(l) == n
            emptyl = empty(l)
            @test length(emptyl) == 0
            @test typeof(l) == typeof(emptyl)
            @test length(l) == n
            empty!(l)
            @test l == emptyl
        end

        @testset "targets" begin
            dl1 = DoublyLinkedList{Int}(1:n...)
            dl2 = DoublyLinkedList{Int}(1:n...)
            pl1 = PairedLinkedList{Int}(1:n...)
            pl2 = PairedLinkedList{Int}(1:n...)
            addtarget!(pl1, pl2)
            for (n1,n2) in zip(ListNodeIterator(pl1), ListNodeIterator(pl2))
                addtarget!(n1, n2)
            end
            l1 = TargetedLinkedList(dl1)  
            push!(l1, 1:n...)
            l2 = TargetedLinkedList(l1)
            push!(l2, 1:n...)
            l3 = TargetedLinkedList(pl1)
            push!(l3, 1:n...)

            @testset "add node targets" begin
                @test_throws MethodError addtarget!(newnode(l1, 1), newnode(l2, 1))
                @test_throws ArgumentError addtarget!(newnode(l1, 1), newnode(dl2, 1))
                @test_throws MethodError addtarget!(newnode(l2, 1), newnode(pl1, 1))
                @test_throws MethodError addtarget!(newnode(l2, 1), newnode(dl1, 1))
                @test_throws MethodError addtarget!(newnode(l2, 1), newnode(dl2, 1))
                @test_throws ArgumentError addtarget!(newnode(l3, 1), newnode(pl2, 1))
                for i=1:n
                    node1 = getnode(l1, i)
                    node2 = getnode(l2, 1)
                    prevtarget = node1.target
                    addtarget!(node2, node1)
                    @test node2.target === node1 && node1.target === node1
                    @test !hastarget(node1) && hastarget(node2)
                end

                for i=1:n
                    node0 = getnode(dl1, i)
                    node1 = getnode(l1, i)
                    node2 = getnode(l2, n-i+1)
                    addtarget!(node1, node0)
                    addtarget!(node2, node1)
                end
                targetsdata1 = Int[]
                targetsdata2 = Int[]
                for (n1, n2) in zip(ListNodeIterator(l1), ListNodeIterator(l2))
                    push!(targetsdata1, n1.target.data)
                    push!(targetsdata2, n2.target.data)
                end
                @test targetsdata1 == [1:n...]
                @test targetsdata2 == [n:-1:1...]
            end

            @testset "remove node targets" begin
                for i=1:n
                    node = getnode(l2, i)
                    target = node.target
                    removetarget!(node)
                    @test node.target === node
                    @test target.target === getnode(dl1, n-i+1)
                end
            end

            @testset "add list targets" begin
                @test_throws MethodError addtarget!(l1, l2)
                @test_throws MethodError addtarget!(l1, pl1)
                @test_throws MethodError addtarget!(l2, dl1)
                @test_throws MethodError addtarget!(l2, pl1)
                for (nt1, nt2, nd1) in zip(ListNodeIterator(l1), ListNodeIterator(l2), ListNodeIterator(dl1))
                    addtarget!(nt1,nd1)
                    addtarget!(nt2,nt1)
                end
                addtarget!(l1,dl2)
                @test l1.target == dl2
                for (n1, n2) in zip(head(l1), head(l2))
                    @test !hastarget(n1)
                    @test n2.target == n1
                end
                for (nt3, np1) in zip(ListNodeIterator(l3), ListNodeIterator(pl1))
                    addtarget!(nt3,np1)
                end
                addtarget!(l3, pl2)
                @test l3.target == pl2
                for (nt3, np1, np2) in zip(head(l3), head(pl1), head(pl2))
                    @test !hastarget(nt3)
                    @test np2.target == np1
                end
            end

            @testset "remove list targets" begin
                for (nt1,nd2) in zip(ListNodeIterator(l1), ListNodeIterator(dl2))
                    addtarget!(nt1,nd2)
                end
                removetarget!(l1)
                @test !hastarget(l1)
                @test l2.target === l1
                for n in ListNodeIterator(l1)
                    @test !hastarget(n)
                end
                removetarget!(l2)
                @test !hastarget(l2)
                for n in ListNodeIterator(l2)
                    @test !hastarget(n)
                end
                for (nt3, np2) in zip(ListNodeIterator(l3), ListNodeIterator(pl2))
                    addtarget!(nt3,np2)
                end
                removetarget!(l3)
                @test !hastarget(l3)
                @test pl2.target == pl1
                for (nt3,np2) in zip(ListNodeIterator(l3), ListNodeIterator(pl2))
                    @test !hastarget(nt3)
                    @test hastarget(np2)
                end
            end
        end
    end

    @testset "random operations" begin
        l1 = TargetedLinkedList{Int,DoublyLinkedList{Int}}()
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
                    addtarget!(getnode(l2, i), getnode(l1, j))
                    p[i] = l1[j]
                end
            end
            targetsdata = Int[]
            for n in ListNodeIterator(l2)
                hastarget(n) && push!(targetsdata, n.target.target.data)
            end
            @test targetsdata == [val for val in filter(x->x>0, p)]

            for i = 1:min(length(l1), length(l2), 20)
                if rand(Bool)
                    i = rand(1:length(l2))
                    removetarget!(getnode(l2, i))
                    p[i] = 0
                end
            end
            targetsdata = Int[]
            for n in ListNodeIterator(l2)
                hastarget(n) && push!(targetsdata, n.target.target.data)
            end
            @test targetsdata == [val for val in filter(x->x>0, p)]
        end
    end
end
