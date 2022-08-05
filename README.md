# PairedLinkedLists

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://tmcgrath325.github.io/PairedLinkedLists.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://tmcgrath325.github.io/PairedLinkedLists.jl/dev/)
[![Build Status](https://github.com/tmcgrath325/PairedLinkedLists.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/tmcgrath325/PairedLinkedLists.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/tmcgrath325/PairedLinkedLists.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/tmcgrath325/PairedLinkedLists.jl)

This package provides a few implementations of doubly-linked lists in Julia:
- `DoublyLinkedList`, a doubly-linked list with mutable nodes.
- `PairedLinkedList`, a doubly-linked list with mutable nodes which also contain a third link to a node in another `PairedLinkedList`.
- `TargetedLinkedList`, a doubly-linked list with mutable nodes which also contain a third link to a node in another list, which can be a `DoublyLinkedList`,`PairedLinkedList`, or a `TargetedLinkedList`.

The lists support many of the base method for arrays:
```julia
l = DoublyLinkedList{T}()         # initialize an empty list of type T
l = DoublyLinkedList{T}(elts...)  # initialize a list with elements of type T
isempty(l)                        # test whether a list is empty
length(l)                         # get the number of elements in a list
keys(l)                           # return the indices of the list
collect(l)                        # return a vector consisting of list elements
eltype(l)                         # return type of list
first(l)                          # return value of first element of a list
last(l)                           # return value of last element of a list
l1 == l2                          # test lists for equality
map(f, l)                         # return list with f applied to elements
filter(f, l)                      # return list of elements where f(el) == true
reverse(l)                        # return reversed a list
copy(l)                           # return a copy of a list
empty!(l)                         # remove all elements from list
getindex(l, idx)   || l[idx]      # get value at index
getindex(l, range) || l[range]    # get values within range a:b
setindex!(l, data, idx)           # set value at index to data
append!(l1, l2)                   # attach l2 at the end of l1
append!(l, elts...)               # attach elements at end of a list
delete!(l, idx)                   # delete element at index
delete!(l, range)                 # delete elements within range a:b
push!(l, data)                    # add element to end of a list
pushfirst!(l, data)               # add element to beginning of a list
insert!(l, idx, data)             # add element at the specified position in a list
pop!(l)                           # remove and return element from end of a list
popfirst!(l)                      # remove and return element from beginning of a list
popat!(l, idx)                    # remove and return element from the specified index
splice!(l, idx, [insertions])     # remove the element at the index and splice in the inserted elements
splice!(l, range, [insertions])   # remove the elements within the range and splice in the inserted elements
```

List nodes, rather than the data they contain, can be accessed via `getnode()`. Each node contains `data` as well as references to the previous and next nodes:
```julia
julia> using PairedLinkedLists;

julia> l = DoublyLinkedList{Int}(1:6...)
DoublyLinkedList{Int64}(1, 2, 3, 4, 5)

julia> node = getnode(l,5)
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
