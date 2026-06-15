
"""
PairedLinkedLists.jl provides implementations for [doubly-linked lists](https://en.wikipedia.org/wiki/Linked_list#Doubly_linked_list) 
and [skip lists](https://en.wikipedia.org/wiki/Skip_list), as well as "paired lists" that also contain inter-list links between nodes in two separate lists.

See also [DoublyLinkedList](@ref), [PairedLinkedList](@ref), [SkipList](@ref), [PairedSkipList](@ref)
"""
module PairedLinkedLists

export popat!

export AbstractNode, AbstractListNode, AbstractPairedListNode, AbstractTargetedListNode, AbstractSkipNode, AbstractPairedSkipNode
export ListNode, PairedListNode, TargetedListNode, SkipNode, PairedSkipNode
export AbstractList, AbstractLinkedList, AbstractDoublyLinkedList, AbstractPairedLinkedList, AbstractTargetedLinkedList
export AbstractSkipLinkedList, AbstractSkipList, AbstractPairedSkipList
export DoublyLinkedList, PairedLinkedList, TargetedLinkedList, SkipList, PairedSkipList
export head, tail, athead, attail, ListNodeIterator, ListDataIterator
export nodetype, getnode, newnode, deletenode!, insertbefore!, insertafter!
export hastarget, addtarget!, removetarget!

include("listypes.jl")
include("lists.jl")
include("skip.jl")
include("utils.jl")

end
