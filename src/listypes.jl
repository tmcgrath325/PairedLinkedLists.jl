abstract type AbstractNode{T,L} end 
abstract type AbstractListNode{T,L} <: AbstractNode{T,L} end
abstract type AbstractSkipNode{T,L} <: AbstractNode{T,L} end

abstract type AbstractList{T} end

abstract type AbstractLinkedList{T} <: AbstractList{T} end
abstract type AbstractDoublyLinkedList{T} <: AbstractLinkedList{T} end
abstract type AbstractPairedLinkedList{T} <: AbstractLinkedList{T} end
abstract type AbstractTargetedLinkedList{T,L,N} <: AbstractPairedLinkedList{T} end

abstract type AbstractSkipLinkedList{T,F} <: AbstractList{T} end
abstract type AbstractSkipList{T,F} <: AbstractSkipLinkedList{T,F} end
abstract type AbstractPairedSkipList{T,F} <: AbstractSkipLinkedList{T,F} end

"""
    node = ListNode(list::DoublyLinkedList, data)

Create a `ListNode` belonging to the specified `list`. The node contains a reference `list` to the parent list, 
the provided `data`, but it has no specific insertion point into `list` (see [`insertafter!`](@ref)).

`node.prev` and `node.next` represent the previous and next nodes, respectively, of a list.
"""
mutable struct ListNode{T,L<:AbstractDoublyLinkedList{T}} <: AbstractListNode{T,L}
    list::L
    data::T
    prev::ListNode{T,L}
    next::ListNode{T,L}
    function ListNode{T,L}(list::L) where {T,L<:AbstractDoublyLinkedList{T}}
        node = new{T,L}(list)
        node.next = node
        node.prev = node
        return node
    end
    function ListNode{T,L}(list::L, data) where {T,L<:AbstractDoublyLinkedList{T}}
        node = new{T,L}(list, data)
        node.next = node
        node.prev = node
        return node
    end
end

"""
    node = PairedListNode(list::PairedLinkedList, data)

Create a `PairedListNode` belonging to the specified `list`. The node contains a reference `list` to the parent list, 
the provided `data`, a link `prev` to the preceding node, a link `next` to the following node, and double-link `target` to another
`PairedListNode`.

A node's `target` should always either be a reference to itself (denoting unpaired node) or a node belonging to the `target`
of its parent `list`.

The `target` link is assumed to be reciprocated for a `PairedListNode`. For example, `node === node.target.target` should be `true`.
"""
mutable struct PairedListNode{T,L<:AbstractPairedLinkedList{T}} <: AbstractListNode{T,L}
    list::L
    data::T
    prev::PairedListNode{T,L}
    next::PairedListNode{T,L}
    target::PairedListNode{T,L}
    function PairedListNode{T,L}(list::L) where {T,L<:AbstractPairedLinkedList{T}}
        node = new{T,PairedLinkedList{T}}(list)
        node.next = node
        node.prev = node
        node.target = node
        return node
    end
    function PairedListNode{T,L}(list::L, data) where {T,L<:AbstractPairedLinkedList{T}}
        node = new{T,L}(list, data)
        node.next = node
        node.prev = node
        node.target = node
        return node
    end
    function PairedListNode{T,L}(list::L, data, target::PairedListNode{T,L}) where {T,L<:AbstractPairedLinkedList{T}}
        node = new{T,L}(list, data)
        node.next = node
        node.prev = node
        addtarget!(node, target)
        return node
    end
end

"""
    node = TargetListNode(list::AbstractTargetLinkedList, data, [target::AbstractListNode])

Create a `TargetListNode` belonging to the specified `list`. The node contains a reference `list` to the parent list, 
the provided `data`, a link `prev` to the preceding node, a link `next` to the following node, and link `target` to another
list node. 

A node's `target` should always either be a reference to itself (denoting unpaired node) or a node belonging to the `target`
of its parent `list`.

Unlike a `PairedListNode`, the `target` link for a `TargetListNode` is not assumed to be reciprocated.
"""
mutable struct TargetedListNode{T,L<:AbstractLinkedList{T},N<:AbstractListNode{T,L},P<:AbstractTargetedLinkedList{T,L,N}} <: AbstractListNode{T,P}
    list::P
    data::T
    prev::TargetedListNode{T,L,N,P}
    next::TargetedListNode{T,L,N,P}
    target::Union{N,TargetedListNode{T,L,N,P}}
    function TargetedListNode{T,L,N,P}(list::P) where {T,L,N,P<:AbstractTargetedLinkedList{T,L,N}}
        node = new{T,L,N,P}(list)
        node.next = node
        node.prev = node
        node.target = node
        return node
    end
    function TargetedListNode{T,L,N,P}(list::P, data) where {T,L,N,P<:AbstractTargetedLinkedList{T,L,N}}
        node = new{T,L,N,P}(list, data)
        node.next = node
        node.prev = node
        node.target = node
        return node
    end
    function TargetedListNode{T,L,N,P}(list::P, data, target::N) where {T,L,N,P<:AbstractTargetedLinkedList{T,L,N}}
        node = new{T,L,N,P}(list, data)
        node.next = node
        node.prev = node
        node.target = target
        return node
    end
end


"""
    l = DoublyLinkedList{::Type}()
    l = DoublyLinkedList(elts...)

Create a `DoublyLinkedList` with with nodes containing data of a specified type.

The list contains its length `len`, a "dummy" node `head` at the beginning of the list, and a "dummy" node
`tail` at the end of the list . 

The first "real" node of a list  `l` can be accessed with `l.head.next`. Similarly, the last "real" node can
be accessed with `l.tail.prev`.
"""
mutable struct DoublyLinkedList{T} <: AbstractDoublyLinkedList{T}
    len::Int   # is this something you need? You can believe it only if the official API is used, which is OK, but even better might be to not have it if it's not necessary
    head::ListNode{T,DoublyLinkedList{T}}  # of course deleting it makes `length(l)` an `O(N)` operation, but usually that's what you expect for a linked list
    tail::ListNode{T,DoublyLinkedList{T}}  # Julia has the [`IteratorSize` trait](https://docs.julialang.org/en/v1/manual/interfaces/#man-interface-iteration) if you need to mark it as absent or slow
    function DoublyLinkedList{T}() where T
        l = new{T}(0)
        l.head = ListNode{T,DoublyLinkedList{T}}(l)
        l.tail = ListNode{T,DoublyLinkedList{T}}(l)
        l.head.next = l.tail
        l.tail.prev = l.head
        return l
    end
end

DoublyLinkedList() = DoublyLinkedList{Any}()
# DoublyLinkedList{T}(l::AbstractLinkedList{S}) where {S,T} = DoublyLinkedList{T}(collect(l)...)
function DoublyLinkedList{T}(elts...) where T
    l = DoublyLinkedList{T}()
    for elt in elts
        push!(l, elt)
    end
    return l
end

"""
    l = PairedLinkedList{::Type}()
    l = PairedLinkedList{::Type}(elts...)

Create a `PairedLinkedList` with nodes containing data of a specified type. 

The list contains its length `len`, a "dummy" node `head` at the beginning of the list, and a "dummy" node
`tail` at the end of the list. The list also contains a reference to its "target" list.

The first "real" node of a list  `l` can be accessed with `l.head.next`. Similarly, the last "real" node can
be accessed with `l.tail.prev`.
"""
mutable struct PairedLinkedList{T} <: AbstractPairedLinkedList{T}
    len::Int
    target::PairedLinkedList{T}
    head::PairedListNode{T,PairedLinkedList{T}}
    tail::PairedListNode{T,PairedLinkedList{T}}
    function PairedLinkedList{T}() where T
        l = new{T}(0)
        l.target = l
        l.head = PairedListNode{T,PairedLinkedList{T}}(l)
        l.tail = PairedListNode{T,PairedLinkedList{T}}(l)
        l.head.next = l.tail
        l.tail.prev = l.head
        return l
    end
    function PairedLinkedList{T}(target::PairedLinkedList{T}) where T
        l = new{T}(0, target)
        l.head = PairedListNode{T,PairedLinkedList{T}}(l)
        l.tail = PairedListNode{T,PairedLinkedList{T}}(l)
        l.head.next = l.tail
        l.tail.prev = l.head
        return l
    end
end

PairedLinkedList() = PairedLinkedList{Any}()
function PairedLinkedList{T}(elts...) where T
    l = PairedLinkedList{T}()
    for elt in elts
        push!(l, elt)
    end
    return l
end

"""
    l = TargetLinkedList{T,L,N}()
    l = TargetLinkedList{T,L,N}(elts...)
    l = TargetLinkedList(list)

Create a `TargetLinkedList` with nodes containing data of a specified type. 

The list contains its length `len`, a "dummy" node `head` at the beginning of the list, and a "dummy" node
`tail` at the end of the list. The list also contains a reference to its "target" list.

The first "real" node of a list  `l` can be accessed with `l.head.next` or `head(l)`. 
Similarly, the last "real" node can be accessed with `l.tail.prev` or `tail(l)`.
"""
mutable struct TargetedLinkedList{T,L<:AbstractLinkedList{T},N<:AbstractListNode{T,L}} <: AbstractTargetedLinkedList{T,L,N}
    len::Int
    target::Union{L,TargetedLinkedList{T,L,N}}
    head::TargetedListNode{T,L,N,TargetedLinkedList{T,L,N}}
    tail::TargetedListNode{T,L,N,TargetedLinkedList{T,L,N}}
    function TargetedLinkedList{T,L,N}() where {T,L,N}
        l = new{T,L,N}(0)
        l.target = l
        l.head = TargetedListNode{T,L,N,TargetedLinkedList{T,L,N}}(l)
        l.tail = TargetedListNode{T,L,N,TargetedLinkedList{T,L,N}}(l)
        l.head.next = l.tail
        l.tail.prev = l.head
        return l
    end
    function TargetedLinkedList{T,L,N}(target::L) where {T,L,N}
        l = new{T,L,N}(0, target)
        l.head = TargetedListNode{T,L,N,TargetedLinkedList{T,L,N}}(l)
        l.tail = TargetedListNode{T,L,N,TargetedLinkedList{T,L,N}}(l)
        l.head.next = l.tail
        l.tail.prev = l.head
        return l
    end
end

TargetedLinkedList(l::L) where {T, L<:AbstractLinkedList{T}} = TargetedLinkedList{T,L,nodetype(L)}(l)
function TargetedLinkedList{T,L,N}(elts...) where {T,L,N}
    l = TargetedLinkedList{T,L,N}()
    for elt in elts
        push!(l, elt)
    end
    return l
end



"""
    node = SkipNode(data)

Create a `SkipNode` belonging to the specified `list`. The node contains a reference `list` to the parent list, 
the provided `data`, but it has no specific insertion point into `list` (see [`insertnode!`](@ref)).

`node.prev` and `node.next` represent the previous and next nodes, respectively, of a list.
"""
mutable struct SkipNode{T,L<:AbstractSkipList{T}} <: AbstractSkipNode{T,L}
    list::L
    data::T
    prev::SkipNode{T}
    next::SkipNode{T}
    up::SkipNode{T}
    down::SkipNode{T}
    function SkipNode{T,L}(list::L) where {T,L<:AbstractSkipList{T}}
        node = new{T,L}(list)
        node.next = node
        node.prev = node
        node.up = node
        node.down = node
        return node
    end
    function SkipNode{T,L}(list::L, data) where {T,L<:AbstractSkipList{T}}
        node = new{T,L}(list, data)
        node.next = node
        node.prev = node
        node.up = node
        node.down = node
        return node
    end
end

"""
    node = PairedSkipNode(data)

Create a `PairedSkipNode`. The node contains the provided `data`, a link `prev` to the preceding node, a link `next` to the following node, 
and double-link `target` to another`PairedSkipNode`.

A node's `target` is intended to always be either a reference to itself (denoting unpaired node) or a node belonging to the `target`
of its parent list.

The `target` link is intended to be reciprocated for a `PairedSkipNode`. For example, `node === node.target.target` should be `true`.
"""
mutable struct PairedSkipNode{T,L<:AbstractPairedSkipList{T}} <: AbstractSkipNode{T,L}
    list::L
    data::T
    prev::PairedSkipNode{T,L}
    next::PairedSkipNode{T,L}
    up::PairedSkipNode{T,L}
    down::PairedSkipNode{T,L}
    target::PairedSkipNode{T,L}
    function PairedSkipNode{T,L}(list::L) where {T,L<:AbstractSkipList{T}}
        node = new{T,L}(list)
        node.next = node
        node.prev = node
        node.target = node
        node.up = node
        node.down = node
        return node
    end
    function PairedSkipNode{T,L}(list::L, data) where {T,L<:AbstractSkipList{T}}
        node = new{T,L}(list, data)
        node.next = node
        node.prev = node
        node.up = node
        node.down = node
        node.target = node
        return node
    end
    function PairedSkipNode{T,L}(list::L, data, target::PairedSkipNode{T}) where {T,L<:AbstractSkipList{T}}
        node = new{T,L}(list, data)
        node.next = node
        node.prev = node
        node.up = node
        node.down = node
        addtarget!(node, target)
        return node
    end
end

"""
    l = SkipList{::Type}()
    l = SkipList(elts...)

Create a `SkipList` with with nodes containing data of a specified type.

The list contains a "dummy" node `head` at the beginning of the list and a "dummy" node `tail` at the end of the list . 

The first "real" node of a list  `l` can be accessed with `l.head.next`. Similarly, the last "real" node can
be accessed with `l.tail.prev`.
"""
mutable struct SkipList{T,F} <: AbstractSkipList{T,F}
    len::Int
    nlevels::Int
    skipfactor::Int
    sortedby::F
    head::SkipNode{T, SkipList{T,F}}
    tail::SkipNode{T, SkipList{T,F}}
    top::SkipNode{T, SkipList{T,F}}
    toptail::SkipNode{T, SkipList{T,F}}
    function SkipList{T}(;sortedby::F=identity, skipfactor::Int=2) where {T,F<:Function}
        l = new{T,F}(0,1,skipfactor,sortedby)
        l.head = SkipNode{T,SkipList{T,F}}(l)
        l.tail = SkipNode{T,SkipList{T,F}}(l)
        l.top = l.head
        l.toptail = l.tail
        l.sortedby = sortedby
        l.skipfactor = skipfactor
        l.nlevels = 1
        l.head.next = l.tail
        l.tail.prev = l.head
        l.top.next = l.toptail
        l.toptail.prev = l.top
        return l
    end
end

"""
    l = PairedSkipList{::Type}()
    l = PairedSkipList{::Type}(elts...)

Create a `PairedSkipList` with nodes containing data of a specified type. 

The list contains its length `len`, a "dummy" node `head` at the beginning of the list, and a "dummy" node
`tail` at the end of the list. The list also contains a reference to its "target" list.

The first "real" node of a list  `l` can be accessed with `l.head.next`. Similarly, the last "real" node can
be accessed with `l.tail.prev`.
"""
mutable struct PairedSkipList{T,F} <: AbstractPairedSkipList{T,F}
    len::Int
    nlevels::Int
    skipfactor::Int
    sortedby::F
    target::PairedSkipList{T, PairedSkipList{T,F}}
    head::PairedSkipNode{T, PairedSkipList{T,F}}
    tail::PairedSkipNode{T, PairedSkipList{T,F}}
    top::PairedSkipNode{T, PairedSkipList{T,F}}
    toptail::PairedSkipNode{T, PairedSkipList{T,F}}
    function PairedSkipList{T}(;sortedby::F=identity, skipfactor::Int=2) where {T,F<:Function}
        l = new{T,F}(0,1,skipfactor,sortedby)
        l.target = l
        l.head = PairedSkipNode{T,PairedSkipList{T,F}}(l)
        l.tail = PairedSkipNode{T,PairedSkipList{T,F}}(l)
        l.top = l.head
        l.toptail = l.tail
        l.sortedby = sortedby
        l.skipfactor = skipfactor
        l.nlevels = 1
        l.head.next = l.tail
        l.tail.prev = l.head
        l.top.next = l.toptail
        l.toptail.prev = l.top
        return l
    end
    function PairedSkipList{T}(target::PairedSkipList{T}; sortedby::F=identity, skipfactor::Int=2) where {T,F<:Function}
        l = new{T,F}(0,1,skipfactor,sortedby,target)
        l.head = PairedSkipNode{T,PairedSkipList{T,F}}(l)
        l.tail = PairedSkipNode{T,PairedSkipList{T,F}}(l)
        l.top = l.head
        l.toptail = l.tail
        l.sortedby = sortedby
        l.skipfactor = skipfactor
        l.nlevels = 1
        l.head.next = l.tail
        l.tail.prev = l.head
        l.top.next = l.toptail
        l.toptail.prev = l.top
        return l
    end
end

function Base.show(io::IO, node::AbstractNode)
    x = node.data
    print(io, "$(typeof(node))($x)")
end

function Base.show(io::IO, l::AbstractList)
    print(io, typeof(l), '(')
    join(io, l, ", ")
    print(io, ')')
end
