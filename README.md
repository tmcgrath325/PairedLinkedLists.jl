# PairedLinkedLists

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://tmcgrath325.github.io/PairedLinkedLists.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://tmcgrath325.github.io/PairedLinkedLists.jl/dev/)
[![Build Status](https://github.com/tmcgrath325/PairedLinkedLists.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/tmcgrath325/PairedLinkedLists.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/tmcgrath325/PairedLinkedLists.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/tmcgrath325/PairedLinkedLists.jl)

This package provides a few implementations of doubly-linked lists in Julia:
- `DoublyLinkedList`, a doubly-linked list with mutable nodes.
- `PairedLinkedList`, a doubly-linked list with mutable nodes which also contain a third link to a node in another `PairedLinkedList`.
- `TargetedLinkedList`, a doubly-linked list with mutable nodes which also contain a third link to a node in another list, which can be a `DoublyLinkedList`,`PairedLinkedList`, or a `TargetedLinkedList`.

The lists support many of the base methods for arrays:
```julia
 julia> using PairedLinkedLists

julia> l = DoublyLinkedList{Int}();

julia> push!(l, 1:10...)
DoublyLinkedList{Int64}(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

julia> pushfirst!(l, 0)
DoublyLinkedList{Int64}(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

julia> pop!(l); l
DoublyLinkedList{Int64}(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)

julia> popfirst!(l); l
DoublyLinkedList{Int64}(1, 2, 3, 4, 5, 6, 7, 8, 9)

julia> popat!(l, 5); l
DoublyLinkedList{Int64}(1, 2, 3, 4, 6, 7, 8, 9)

julia> insert!(l, 5, -1)
DoublyLinkedList{Int64}(1, 2, 3, 4, -1, 6, 7, 8, 9)
```

List nodes, rather than the data they contain, can be accessed via `getnode()`. Each node contains `data` as well as references to the previous and next nodes:
```julia
julia> using PairedLinkedLists;

julia> l = DoublyLinkedList{Int}(1:5...)
DoublyLinkedList{Int64}(1, 2, 3, 4, 5)

julia> node = getnode(l,3)
ListNode{Int64, DoublyLinkedList{Int64}}(3)

julia> node.next
ListNode{Int64, DoublyLinkedList{Int64}}(4)

julia> node.prev.data == 2
true
```

Iterating a list returns the data it contains, but nodes can be accessed during iteration by using `IteratingListNodes`:
```julia
julia> for data in l println(data) end
1
2
3
4
5

julia> for node in IteratingListNodes(l) println(node) end
ListNode{Int64, DoublyLinkedList{Int64}}(1)
ListNode{Int64, DoublyLinkedList{Int64}}(2)
ListNode{Int64, DoublyLinkedList{Int64}}(3)
ListNode{Int64, DoublyLinkedList{Int64}}(4)
ListNode{Int64, DoublyLinkedList{Int64}}(5)
```

[Skip lists](https://en.wikipedia.org/wiki/Skip_list) insert new data as appropriate to keep the list sorted, with O(log(n)) insertion and deletion times:
```julia
julia> using PairedLinkedLists

julia> sortedby = x -> (-x[2], x[1])
#5 (generic function with 1 method)

julia> data = [(x,y) for x in 1:2 for y in 1:2];

julia> sl = SkipList{eltype(data)}(data...) # using default sorting
SkipList{Tuple{Int64, Int64}, typeof(identity)}((1, 1), (1, 2), (2, 1), (2, 2))

julia> sl2 = SkipList{eltype(data)}(data...; sortedby=sortedby) 
SkipList{Tuple{Int64, Int64}, var"#5#6"}((1, 2), (2, 2), (1, 1), (2, 1))

julia> push!(sl, (0,0))
SkipList{Tuple{Int64, Int64}, typeof(identity)}((0, 0), (1, 1), (1, 2), (2, 1), (2, 2))

julia> push!(sl2, (0,0))
SkipList{Tuple{Int64, Int64}, var"#5#6"}((1, 2), (2, 2), (1, 1), (2, 1), (0, 0))
```
