```@meta
CurrentModule = PairedLinkedLists
DocTestSetup = quote
    using PairedLinkedLists
end
```

# PairedLinkedLists

This package provides doubly-linked list and sorted skip-list implementations in Julia, with support for reciprocal inter-list node links.

List types:

- [`DoublyLinkedList`](@ref) — a standard doubly-linked list.
- [`PairedLinkedList`](@ref) — a doubly-linked list whose nodes each carry a reciprocal link to a node in a second `PairedLinkedList`. Adding a link from node A to node B automatically sets the reverse link from B to A.
- [`TargetedLinkedList`](@ref) — a doubly-linked list whose nodes carry a one-way link to a node in any other list type.
- [`SkipList`](@ref) — a sorted [skip list](https://en.wikipedia.org/wiki/Skip_list) with O(log n) insertion and deletion.
- [`PairedSkipList`](@ref) — a sorted skip list whose nodes carry reciprocal inter-list links.

## Installation

```julia
using Pkg
Pkg.add("PairedLinkedLists")
```

## Inter-list linking

The distinctive feature of this package is the ability to link nodes across two lists. A **paired** link is reciprocal: `addtarget!(node_a, node_b)` sets `node_a.target = node_b` *and* `node_b.target = node_a` in a single call, and `removetarget!` clears both ends. A **targeted** link is one-way: only the source node's `target` field is set, leaving the destination unchanged.

Linking works at both the list level (pairing two lists together so their nodes can be linked) and the node level (pairing individual nodes within already-paired lists).

## Usage

### Basic list operations

```jldoctest
julia> l = DoublyLinkedList{Int}(1, 2, 3, 4, 5);

julia> push!(l, 6)
DoublyLinkedList{Int64}(1, 2, 3, 4, 5, 6)

julia> pop!(l)
6

julia> popat!(l, 2)
2

julia> insert!(l, 2, 10)
DoublyLinkedList{Int64}(1, 10, 3, 4, 5)

julia> collect(l)
5-element Vector{Int64}:
  1
 10
  3
  4
  5
```

### Node access and iteration

`getnode` returns the node at a given index. Nodes hold `data` and `prev`/`next` references. `ListNodeIterator` iterates over nodes rather than data values:

```jldoctest
julia> l = DoublyLinkedList{Int}(10, 20, 30);

julia> node = getnode(l, 2)
ListNode{Int64, DoublyLinkedList{Int64}}(20)

julia> node.prev.data
10

julia> node.next.data
30

julia> [n.data for n in ListNodeIterator(l)]
3-element Vector{Int64}:
 10
 20
 30

julia> [n.data for n in ListNodeIterator(l; rev=true)]
3-element Vector{Int64}:
 30
 20
 10
```

### Inter-list linking with PairedLinkedList

```jldoctest
julia> l1 = PairedLinkedList{Int}(1, 2, 3);

julia> l2 = PairedLinkedList{Int}(10, 20, 30);

julia> addtarget!(l1, l2);

julia> l1.target === l2
true

julia> addtarget!(getnode(l1, 1), getnode(l2, 2));

julia> getnode(l1, 1).target.data
20

julia> getnode(l2, 2).target.data
1

julia> removetarget!(getnode(l1, 1));

julia> hastarget(getnode(l1, 1))
false

julia> hastarget(getnode(l2, 2))
false
```

### Sorted skip lists

`SkipList` keeps elements in sorted order and supports O(log n) insertion and deletion. A custom sort key can be supplied via the `sortedby` keyword:

```jldoctest
julia> sl = SkipList{Int}(5, 3, 1, 4, 2);

julia> collect(sl)
5-element Vector{Int64}:
 1
 2
 3
 4
 5

julia> push!(sl, 0); collect(sl)
6-element Vector{Int64}:
 0
 1
 2
 3
 4
 5

julia> negate(x) = -x;

julia> sl2 = SkipList{Int}(5, 3, 1, 4, 2; sortedby=negate);

julia> collect(sl2)
5-element Vector{Int64}:
 5
 4
 3
 2
 1
```

## API Reference

```@index
```

```@autodocs
Modules = [PairedLinkedLists]
```
