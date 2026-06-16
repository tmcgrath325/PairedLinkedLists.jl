# PairedLinkedLists

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://tmcgrath325.github.io/PairedLinkedLists.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://tmcgrath325.github.io/PairedLinkedLists.jl/dev/)
[![Build Status](https://github.com/tmcgrath325/PairedLinkedLists.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/tmcgrath325/PairedLinkedLists.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/tmcgrath325/PairedLinkedLists.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/tmcgrath325/PairedLinkedLists.jl)
[![Aqua QA](https://juliatesting.github.io/Aqua.jl/dev/assets/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)
[![Version](https://img.shields.io/github/v/release/tmcgrath325/PairedLinkedLists.jl)](https://github.com/tmcgrath325/PairedLinkedLists.jl/releases)

This package provides doubly-linked list and sorted skip-list implementations in Julia, with support for reciprocal inter-list node links:

- `DoublyLinkedList` — a standard doubly-linked list.
- `PairedLinkedList` — a doubly-linked list whose nodes each carry a reciprocal link to a node in a second `PairedLinkedList`. Adding a link from node A to node B automatically sets the reverse link from B to A.
- `TargetedLinkedList` — a doubly-linked list whose nodes carry a one-way link to a node in any other list type (`DoublyLinkedList`, `PairedLinkedList`, or another `TargetedLinkedList`).
- `SkipList` — a sorted [skip list](https://en.wikipedia.org/wiki/Skip_list) with O(log n) insertion and deletion.
- `PairedSkipList` — a sorted skip list whose nodes carry reciprocal inter-list links.

## Installation

```julia
using Pkg
Pkg.add("PairedLinkedLists")
```

## Usage

### Basic list operations

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

### Node access

List nodes — rather than the data they contain — can be accessed via `getnode`. Each node holds `data` and references to adjacent nodes:

```julia
julia> l = DoublyLinkedList{Int}(1, 2, 3, 4, 5)
DoublyLinkedList{Int64}(1, 2, 3, 4, 5)

julia> node = getnode(l, 3)
ListNode{Int64, DoublyLinkedList{Int64}}(3)

julia> node.next
ListNode{Int64, DoublyLinkedList{Int64}}(4)

julia> node.prev.data == 2
true
```

Iterating a list yields data values; use `ListNodeIterator` to iterate over the nodes themselves:

```julia
julia> for data in l; println(data); end
1
2
3
4
5

julia> for node in ListNodeIterator(l); println(node); end
ListNode{Int64, DoublyLinkedList{Int64}}(1)
ListNode{Int64, DoublyLinkedList{Int64}}(2)
ListNode{Int64, DoublyLinkedList{Int64}}(3)
ListNode{Int64, DoublyLinkedList{Int64}}(4)
ListNode{Int64, DoublyLinkedList{Int64}}(5)
```

### Inter-list linking

`PairedLinkedList` nodes carry a reciprocal link to a node in a paired list. Use `addtarget!` to establish a link; it sets both directions automatically:

```julia
julia> l1 = PairedLinkedList{Int}(1, 2, 3);

julia> l2 = PairedLinkedList{Int}(10, 20, 30);

julia> addtarget!(l1, l2);           # pair the lists

julia> addtarget!(getnode(l1, 1), getnode(l2, 2));  # pair node 1 of l1 with node 2 of l2

julia> getnode(l1, 1).target.data    # forward link
20

julia> getnode(l2, 2).target.data    # reverse link set automatically
1
```

### Sorted skip lists

`SkipList` inserts elements in sorted order and supports O(log n) operations. A custom sort key can be provided via `sortedby`:

```julia
julia> sl = SkipList{Int}(5, 3, 1, 4, 2)
SkipList{Int64, typeof(identity)}(1, 2, 3, 4, 5)

julia> push!(sl, 0)
SkipList{Int64, typeof(identity)}(0, 1, 2, 3, 4, 5)
```
