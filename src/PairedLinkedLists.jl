
"""
PairedLinkedLists.jl provides doubly-linked lists as well as "paired lists" that also contain links between nodes in two separate lists.

Array-like functionality is supported for `DoublyLinkedList` and `PairedLinkedList`:
```julia
    julia> using PairedLinkedLists

    julia> l = DoublyLinkedList{Int}(0)
    DoublyLinkedList{Int64}(0)

    julia> push!(l, 1:10...)
    DoublyLinkedList{Int64}(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

    julia> l[5] = 3;

    julia> popfirst!(l)
    0

    julia> l
    DoublyLinkedList{Int64}(1, 2, 3, 4, 3, 6, 7, 8, 9)
```

Supported methods include `push!`, `pushfirst!`, `pop!`, `popfirst!`, `popat!`, `insert!`, and `splice!`.
"""
module PairedLinkedLists

export popat!

export AbstractListNode, ListNode, PairedListNode, TargetedListNode, SkipNode, PairedSkipNode
export AbstractLinkedList, DoublyLinkedList, PairedLinkedList, TargetedLinkedList, SkipList, PairedSkipList
export head, tail, athead, attail, ListNodeIterator, ListDataIterator
export nodetype, getnode, newnode, deletenode!, insertbefore!, insertafter!
export hastarget, addtarget!, removetarget!
export getfirst

include("listypes.jl")
include("lists.jl")
include("skip.jl")
include("utils.jl")

end
