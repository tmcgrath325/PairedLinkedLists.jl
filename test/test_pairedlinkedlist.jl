@testset "PairedLinkedList" begin

    @testset "empty list" begin
        l1 = PairedLinkedList{Int}()
        @test PairedLinkedList() == PairedLinkedList{Any}()
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

        @testset "equality" begin
            l1 = PairedLinkedList{Int}(1:n...)
            l2 = PairedLinkedList{Int}(1:n...)
            l3 = DoublyLinkedList{Int}(1:n...)    
            @test l1 == l2 !== l3
        end

        @testset "iterate" begin
            l = PairedLinkedList{Int}(1:n...)

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
                for (i,data) in enumerate(ListDataIterator(head(l).next))
                    @test data == i+1
                end
                for (i,data) in enumerate(ListDataIterator(tail(l).prev; rev=true))
                    @test data == n-i
                end
            end

            @testset "nodes" begin
                for (i,node) in enumerate(head(l))
                    @test node == newnode(l,i)
                end
                for (i,node) in enumerate(ListNodeIterator(l))
                    @test node == newnode(l,i)
                end
                for (i,node) in enumerate(ListNodeIterator(l; rev=true))
                    @test node == newnode(l,n-i+1)
                end
                for (i,node) in enumerate(ListNodeIterator(head(l).next))
                    @test node == newnode(l,i+1)
                end
                for (i,node) in enumerate(ListNodeIterator(tail(l).prev; rev=true))
                    @test node == newnode(l,n-i)
                end
            end
        end

        @testset "push back / pop back" begin
            l = PairedLinkedList{Int}()
            dummy_list = PairedLinkedList{Int}()
            @test_throws ArgumentError insertafter!(newnode(dummy_list, 0), l.head)

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
                    @test keys(l) == collect(1:i)
                    for (j, k) in enumerate(l)
                        @test j == k
                    end
                    if i > 3 && VERSION > VersionNumber(1,7,0)
                        l1 = PairedLinkedList{Int32}(1:i...)
                        io = IOBuffer()
                        @test sprint(io -> show(io, iterate(l1))) == "(1, PairedListNode{Int32, PairedLinkedList{Int32}}(2))"
                        @test sprint(io -> show(io, iterate(l1, l1.head.next.next))) == "(2, PairedListNode{Int32, PairedLinkedList{Int32}}(3))"
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
                dummy_list = PairedLinkedList{Int}()

                @testset "append" begin
                    l2 = PairedLinkedList{Int}(n+1:2n...)
                    addtarget!(l2, dummy_list)
                    addtarget!(l2.head.next, dummy_list.head)
                    @test_throws ArgumentError append!(l, l2)
                    removetarget!(l2)
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
                    l2 = PairedLinkedList{Int}(1:n...)
                    l3 = PairedLinkedList{Int}(1:n...)
                    addtarget!(l2,l3)
                    for (n2,n3) in zip(ListNodeIterator(l2), ListNodeIterator(l3; rev=true))
                        addtarget!(n2, n3)
                    end
                    l4 = copy(l2)
                    @test l4 == l2
                    @test [x.target for x in ListNodeIterator(l4)] == [x.target for x in ListNodeIterator(l2)]
                    l5 = PairedLinkedList{Int}()
                    copy!(l5, l2)
                    @test l5 == l2
                    @test l5.target == l3
                    @test [x.target for x in ListNodeIterator(l5)] == [x.target for x in ListNodeIterator(l2)]
                    l6 = PairedLinkedList{Int}(1:2*i...)
                    l7 = PairedLinkedList{Int}(1:2*i...)
                    addtarget!(l6, l7)
                    for (n6,n7) in zip(ListNodeIterator(l6), ListNodeIterator(l7; rev=true))
                        addtarget!(n6, n7)
                    end
                    copy!(l6, l2)
                    @test l6 == l2
                    @test l7 == l3
                    @test [x.target for x in ListNodeIterator(l6)] == [x.target for x in ListNodeIterator(l2)]
                end

                @testset "reverse" begin
                    l2 = PairedLinkedList{Int}(n:-1:1...)
                    @test l == reverse(l2)
                end
            end
        end

        @testset "filter / show" begin
            for i = 1:n
                @testset "filter" begin
                    l = PairedLinkedList{Int}(1:n...)
                    @test filter(x -> x % 2 == 0, l) == PairedLinkedList{Int}(2:2:n...)
                end

                @testset "show" begin
                    l = PairedLinkedList{Int32}(1:n...)
                    io = IOBuffer()
                    @test sprint(io -> show(io, head(l))) == "$(typeof(head(l)))($(head(l).data))"
                    io1 = IOBuffer()
                    write(io1, "PairedLinkedList{Int32}(");
                    write(io1, join(l, ", "));
                    write(io1, ")")
                    seekstart(io1)
                    @test sprint(io -> show(io, l)) == read(io1, String)
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

        @testset "empty" begin
            l = PairedLinkedList{Int}(1:n...)
            @test length(l) == n
            emptyl = empty(l)
            @test length(emptyl) == 0
            @test typeof(l) == typeof(emptyl)
            @test length(l) == n
            empty!(l)
            @test l == emptyl
        end

        @testset "targets" begin
            l1 = PairedLinkedList{Int}(1:n...)  
            l2 = PairedLinkedList{Int}(1:n...)
            l3 = PairedLinkedList{Int}(1:n...)
            l4 = PairedLinkedList{Int}(l3)
            dl = DoublyLinkedList{Int}(1:n...)
            @test_throws ArgumentError addtarget!(newnode(l1, 1), newnode(l2, 1))
            addtarget!(l1, l2)
            push!(l4, 1:10...)
            @test !hastarget(l3)
            @test l4.target === l3
            addtarget!(l3, l4)

            @testset "add node targets" begin
                for i=1:n
                    node1 = getnode(l1, 1)
                    node2 = getnode(l2, i)
                    prevtarget = node1.target
                    addtarget!(node1, node2)
                    @test node1.target === node2 && node2.target === node1
                    @test hastarget(node1) && hastarget(node2)
                    if i != 1
                        @test prevtarget.target === prevtarget
                        @test !hastarget(prevtarget)
                    end
                end

                for i=1:n
                    node1 = getnode(l1, i)
                    node2 = getnode(l2, n-i+1)
                    addtarget!(node1, node2)
                end
                targetsdata1 = Int[]
                targetsdata2 = Int[]
                for (n1, n2) in zip(ListNodeIterator(l1), ListNodeIterator(l2))
                    push!(targetsdata1, n1.target.data)
                    push!(targetsdata2, n2.target.data)
                end
                @test targetsdata1 == targetsdata2 == [n:-1:1...]

                for shift = 1:floor(n/2)
                    for i=1:n
                        node1 = getnode(l1, i)
                        node2 = getnode(l2, Int(mod(i + shift - 1, n) + 1))
                        addtarget!(node1, node2)
                    end
                    targetsdata1 = Int[]
                    targetsdata2 = Int[]
                    for (n1, n2) in zip(ListNodeIterator(l1), ListNodeIterator(l2))
                        push!(targetsdata1, n1.target.data)
                        push!(targetsdata2, n2.target.data)
                    end
                    @test circshift(targetsdata1, shift) == circshift(targetsdata2, -shift) == [1:n...]
                end

                @test_throws MethodError addtarget!(head(l1), head(dl))
            end

            @testset "remove node targets" begin
                mid = Int(floor(n/2))
                for i=1:mid
                    node = getnode(l1, i)
                    target = node.target
                    removetarget!(node)
                    @test node.target === node
                    @test target.target === target
                    removetarget!(getnode(dl, i))
                end
                for i=mid:n
                    node = getnode(l1, i)
                    target = node.target
                    removetarget!(l1, i)
                    @test node.target === node
                    @test target.target === target
                    removetarget!(getnode(dl, i))
                end
            end

            @testset "add list targets" begin
                @test_throws MethodError addtarget!(l1, dl)
                for (n3, n4) in zip(ListNodeIterator(l3), ListNodeIterator(l4))
                    addtarget!(n3,n4)
                end
                addtarget!(l1,l3)
                @test l1.target === l3 && l3.target === l1
                @test !hastarget(l2) && !hastarget(l4)
                for (n2, n4) in zip(ListNodeIterator(l2), ListNodeIterator(l4))
                    @test !hastarget(n2) && !hastarget(n4)
                end
            end

            @testset "remove list targets" begin
                for (n1, n3) in zip(ListNodeIterator(l1), ListNodeIterator(l3))
                    addtarget!(n1,n3)
                end
                removetarget!(l1)
                @test !hastarget(l1) && !hastarget(l3)
                for (n1, n3) in zip(ListNodeIterator(l2), ListNodeIterator(l4))
                    @test !hastarget(n1) && !hastarget(n3)
                end
            end
        end
    end

    @testset "random operations" begin
        l1 = PairedLinkedList{Int}()
        l2 = PairedLinkedList{Int}()
        addtarget!(l1, l2)
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
                    addtarget!(getnode(l1, i), getnode(l2, j))
                end
                if rand(Bool)
                    i = rand(1:length(l1))
                    j = rand(1:length(l2))
                    addtarget!(getnode(l2, j), getnode(l1, i))
                end
            end
            targetsdata1 = Int[]
            targetsdata2 = Int[]
            for n in ListNodeIterator(l1)
                hastarget(n) && push!(targetsdata1, n.target.data)
            end
            for n in ListNodeIterator(l2)
                hastarget(n) && push!(targetsdata2, n.target.target.data)
            end
            match = length(targetsdata1) == length(targetsdata2)
            for d1 in targetsdata1
                !match && break
                match = d1 ∈ targetsdata2
            end
            @test match

            for i = 1:min(length(l1), length(l2), 20)
                if rand(Bool)
                    i = rand(1:length(l1))
                    removetarget!(getnode(l1, i))
                end
                if rand(Bool)
                    j = rand(1:length(l2))
                    removetarget!(getnode(l2, j))
                end
            end
            targetsdata1 = Int[]
            targetsdata2 = Int[]
            for n in ListNodeIterator(l1)
                hastarget(n) && push!(targetsdata1, n.target.data)
            end
            for n in ListNodeIterator(l2)
                hastarget(n) && push!(targetsdata2, n.target.target.data)
            end
            match = length(targetsdata1) == length(targetsdata2)
            for d1 in targetsdata1
                !match && break
                match = d1 ∈ targetsdata2
            end
            @test match
        end
    end
end
