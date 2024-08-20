abstract type AbstractNode{T,L} end 

abstract type AbstractListNode{T,L} <: AbstractNode{T,L} end
abstract type AbstractPairedListNode{T,L} <: AbstractListNode{T,L} end
abstract type AbstractTargetedListNode{T,N,L} <: AbstractListNode{T,L} end

abstract type AbstractSkipNode{T,L} <: AbstractNode{T,L} end
abstract type AbstractPairedSkipNode{T,L} <: AbstractSkipNode{T,L} end

abstract type AbstractList{T} end

abstract type AbstractLinkedList{T} <: AbstractList{T} end
abstract type AbstractDoublyLinkedList{T} <: AbstractLinkedList{T} end
abstract type AbstractPairedLinkedList{T} <: AbstractLinkedList{T} end
abstract type AbstractTargetedLinkedList{T,N,L} <: AbstractPairedLinkedList{T} end

abstract type AbstractSkipLinkedList{T,F} <: AbstractList{T} end
abstract type AbstractSkipList{T,F} <: AbstractSkipLinkedList{T,F} end
abstract type AbstractPairedSkipList{T,F} <: AbstractSkipLinkedList{T,F} end

"""
    node = ListNode(list::DoublyLinkedList [, data])

Create a `ListNode` belonging to the specified `list`. The node contains a reference `list` to the parent list and 
contains the provided `data`, but it has no specific insertion point into `list` (see [`insertafter!`](@ref)).

`node.prev` and `node.next` represent the previous and next nodes, respectively, of a list.

See also [`DoublyLinkedList`](@ref), [`PairedListNode`](@ref), [`TargetedListNode`](@ref).
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
ListNode{T}(args...) where T = PairedListNode{T,PairedLinkedList{T}}(args...)

"""
    node = PairedListNode(list::PairedLinkedList, data)

Create a `PairedListNode` belonging to the specified `list`. The node contains a reference `list` to the parent list and 
contains the provided `data`, but it has no specific insertion point into `list` (see [`insertafter!`](@ref)).

`node.prev` and `node.next` represent the previous and next nodes, respectively, of a list.

A node's `target` should always either be a reference to itself (denoting unpaired node) or a node belonging to the `target`
of its parent `list`.

The `target` link is assumed to be reciprocated for a `PairedListNode`. For example, `node === node.target.target` should be `true`.
For one-way inter-list links, see [`TargetedListNode`](@ref).

See also [`PairedLinkedList`](@ref), [`ListNode`](@ref), [`TargetedListNode`](@ref).
"""
mutable struct PairedListNode{T,L<:AbstractPairedLinkedList{T}} <: AbstractPairedListNode{T,L}
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
end
PairedListNode{T}(args...) where T = PairedListNode{T,PairedLinkedList{T}}(args...)

"""
    node = TargetListNode(list::AbstractTargetLinkedList, data, [target::AbstractListNode])

Create a `TargetedListNode` belonging to the specified `list`. The node contains a reference `list` to the parent list and 
contains the provided `data`, but it has no specific insertion point into `list` (see [`insertafter!`](@ref)).

`node.prev` and `node.next` represent the previous and next nodes, respectively, of a list.

A node's `target` should always either be a reference to itself (denoting unpaired node) or a node belonging to the `target`
of its parent `list`.

The `target` link is *not* assumed to be reciprocated for a `PairedListNode`, as the targeted node may not even have a `target` field. 
For guranteed two-way inter-list links, see [`PairedListNode`](@ref).

See also [`TargetedLinkedList`](@ref), [`PairedListNode`](@ref), [`ListNode`](@ref).
"""
mutable struct TargetedListNode{T,N<:AbstractNode{T},L<:AbstractList{T}} <: AbstractTargetedListNode{T,N,L}
    list::L
    data::T
    prev::TargetedListNode{T,N,L}
    next::TargetedListNode{T,N,L}
    target::Union{N,TargetedListNode{T,N,L}}
    function TargetedListNode{T,N,L}(list::L) where {T,N,L}
        node = new{T,N,L}(list)
        node.next = node
        node.prev = node
        node.target = node
        return node
    end
    function TargetedListNode{T,N,L}(list::L, data) where {T,N,L}
        node = new{T,N,L}(list, data)
        node.next = node
        node.prev = node
        node.target = node
        return node
    end
end
TargetedListNode{T,N}(args...) where {T,R,N<:AbstractNode{T,R}} = TargetedListNode{T,N,TargetedLinkedList{T,R,N}}(args...)


"""
    l = DoublyLinkedList{::Type}()
    l = DoublyLinkedList(elts...)

Create a `DoublyLinkedList` made up of [`ListNode`](@ref)s with with nodes containing data of a specified type.

The list contains its length `len`, a "dummy" node `head` at the beginning of the list, and a "dummy" node
`tail` at the end of the list . 

The first "real" node of a list `l` can be accessed with `l.head.next` or `head(l)`. Similarly, the last "real" node can
be accessed with `l.tail.prev` or `tail(l)`.

See also [`ListNode`](@ref), [`SkipList`](@ref), [`PairedLinkedList`](@ref), [`TargetedLinkedList`](@ref)
"""
mutable struct DoublyLinkedList{T} <: AbstractDoublyLinkedList{T}
    len::Int
    head::ListNode{T,DoublyLinkedList{T}}  
    tail::ListNode{T,DoublyLinkedList{T}}
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

Create a `PairedLinkedList` made up of [`PairListNode`](@ref)s containing data of a specified type. Each node can have an inter-list link
to a node belonging to the list's `target`.

The list contains its length `len`, a "dummy" node `head` at the beginning of the list, and a "dummy" node
`tail` at the end of the list . 

The first "real" node of a list `l` can be accessed with `l.head.next` or `head(l)`. Similarly, the last "real" node can
be accessed with `l.tail.prev` or `tail(l)`.

See also [`PairedListNode`](@ref), [`PairedSkipList`](@ref), [`DoublyLinkedList`](@ref), [`TargetedLinkedList`](@ref)
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
    l = TargetLinkedList{T,R}()
    l = TargetLinkedList{T,R}(elts...)
    l = TargetLinkedList(list)

Create a `TargetLinkedList` made up of [`TargetedListNode`](@ref)s containing data of a specified type. Each node can have an inter-list link
to a node belonging to the list's `target`.

The list contains its length `len`, a "dummy" node `head` at the beginning of the list, and a "dummy" node
`tail` at the end of the list. The list also contains a reference to its "target" list.

The first "real" node of a list  `l` can be accessed with `l.head.next` or `head(l)`. 
Similarly, the last "real" node can be accessed with `l.tail.prev` or `tail(l)`.

See also [`TargetedListNode`](@ref), [`DoublyLinkedList`](@ref), [`PairedLinkedList`](@ref)
"""
mutable struct TargetedLinkedList{T,R<:AbstractList{T},N<:AbstractNode{T,R}} <: AbstractTargetedLinkedList{T,R,N}
    len::Int
    target::Union{R,TargetedLinkedList{T,R,N}}
    head::TargetedListNode{T,N,TargetedLinkedList{T,R,N}}
    tail::TargetedListNode{T,N,TargetedLinkedList{T,R,N}}
    function TargetedLinkedList{T,R,N}() where {T,R,N}
        l = new{T,R,N}(0)
        l.target = l
        l.head = TargetedListNode{T,N,TargetedLinkedList{T,R,N}}(l)
        l.tail = TargetedListNode{T,N,TargetedLinkedList{T,R,N}}(l)
        l.head.next = l.tail
        l.tail.prev = l.head
        return l
    end
    function TargetedLinkedList{T,R,N}(target::R) where {T,R,N}
        l = new{T,R,N}(0, target)
        l.head = TargetedListNode{T,N,TargetedLinkedList{T,R,N}}(l)
        l.tail = TargetedListNode{T,N,TargetedLinkedList{T,R,N}}(l)
        l.head.next = l.tail
        l.tail.prev = l.head
        return l
    end
end

TargetedLinkedList(target::R) where {T, R<:AbstractList{T}} = TargetedLinkedList{T,R,nodetype(R)}(target)
function TargetedLinkedList{T,R,N}(elts...) where {T,R,N}
    l = TargetedLinkedList{T,R,N}()
    for elt in elts
        push!(l, elt)
    end
    return l
end
TargetedLinkedList{T,R}(args...) where {T,R} = TargetedLinkedList{T,R,nodetype(R)}(args...)


# for debugging
struct SkipListCache{T}
    added_data::Vector{T}
    added_levels::Vector{Int}
    removed_data::Vector{T}
end

SkipListCache{T}() where T = SkipListCache{T}(T[],Int[],T[])


"""
    node = SkipNode(list::SkipList [, data])

Create a `SkipNode` belonging to the specified `list`. The node contains a reference `list` to the parent [skip list](https://en.wikipedia.org/wiki/Skip_list)
and contains the provided `data`, but it has no specific insertion point into `list` (see [`insertafter!`](@ref)).

`node.prev` and `node.next` represent the previous and next nodes, respectively, of a list. `node.up` and `node.bottom` represent the nodes in adjacent levels
within the skip list data structure.

See also [`SkipList`](@ref), [`PairedSkipNode`](@ref)
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
    node = PairedSkipNode(list::SkipList [, data])

Create a `PairedSkipNode` belonging to the specified `list`. The node contains a reference `list` to the parent [skip list](https://en.wikipedia.org/wiki/Skip_list)
and contains the provided `data`, but it has no specific insertion point into `list` (see [`insertafter!`](@ref)).

`node.prev` and `node.next` represent the previous and next nodes, respectively, of a list. `node.up` and `node.bottom` represent the nodes in adjacent levels
within the skip list data structure.

A node's `target` should always either be a reference to itself (denoting unpaired node) or a node belonging to the `target`
of its parent `list`.

The `target` link is assumed to be reciprocated for a `PairedSkipNode`. For example, `node === node.target.target` should be `true`.

See also [`PairedSkipList`](@ref), [`SkipNode`](@ref)
"""
mutable struct PairedSkipNode{T,L<:AbstractPairedSkipList{T}} <: AbstractPairedSkipNode{T,L}
    list::L
    data::T
    prev::PairedSkipNode{T,L}
    next::PairedSkipNode{T,L}
    up::PairedSkipNode{T,L}
    down::PairedSkipNode{T,L}
    target::PairedSkipNode{T,L}
    function PairedSkipNode{T,L}(list::L) where {T,L<:AbstractPairedSkipList{T}}
        node = new{T,L}(list)
        node.next = node
        node.prev = node
        node.target = node
        node.up = node
        node.down = node
        return node
    end
    function PairedSkipNode{T,L}(list::L, data) where {T,L<:AbstractPairedSkipList{T}}
        node = new{T,L}(list, data)
        node.next = node
        node.prev = node
        node.up = node
        node.down = node
        node.target = node
        return node
    end
end

"""
    l = SkipList{::Type}(; sortedby=identity, skipfactor=2)
    l = SkipList{::Type}(elts...; sortedby=identity, skipfactor=2)

Create a `SkipList` made of up [SkipNode](@ref)s containing data of a specified type.

The list contains a "dummy" node `head` at the beginning of the list and a "dummy" node `tail` at the end of the list.

The node at the head of the topmost level of the datastructure can be accessed by `l.top`.

The first "real" node of a list `l` can be accessed with `l.head.next` or `head(l)`. Similarly, the last "real" node can
be accessed with `l.tail.prev` or `tail(l)`.

The `skipfactor` of the list describes the average number of nodes "skipped" by the above level.

The ordering of the list can be specified by a function, `sortedby`.

See also [`PairedSkipList`](@ref), [`SkipNode`](@ref)
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
    cache::Union{Nothing,SkipListCache{T}}
    function SkipList{T,F}(skipfactor::Int=2, sortedby::F=identity) where {T,F<:Function}
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
        l.cache = nothing
        return l
    end
end

function SkipList{T}(elts...; sortedby::F=identity, skipfactor::Int=2) where {T,F}
    l = SkipList{T,F}(skipfactor, sortedby)
    for elt in elts
        push!(l, elt)
    end
    return l
end

"""
    l = PairedSkipList{::Type}(; sortedby=identity, skipfactor=2)
    l = PairedSkipList{::Type}(elts...; sortedby=identity, skipfactor=2)

Create a `PairedSkipList` with nodes containing data of a specified type. Each node can have an inter-list link
to a node belonging to the list's `target`.

The list contains its length `len`, a "dummy" node `head` at the beginning of the list, and a "dummy" node
`tail` at the end of the list. The list also contains a reference to its "target" list.

The first "real" node of a list  `l` can be accessed with `l.head.next`. Similarly, the last "real" node can
be accessed with `l.tail.prev`.

The `skipfactor` of the list describes the average number of nodes "skipped" by the above level.

The ordering of the list can be specified by a function, `sortedby`.

See also [`SkipList`](@ref), [`PairedSkipNode`](@ref)
"""
mutable struct PairedSkipList{T,F} <: AbstractPairedSkipList{T,F}
    len::Int
    nlevels::Int
    skipfactor::Int
    sortedby::F
    target::PairedSkipList{T, F}
    head::PairedSkipNode{T, PairedSkipList{T,F}}
    tail::PairedSkipNode{T, PairedSkipList{T,F}}
    top::PairedSkipNode{T, PairedSkipList{T,F}}
    toptail::PairedSkipNode{T, PairedSkipList{T,F}}
    cache::Union{Nothing,SkipListCache{T}}
    function PairedSkipList{T,F}(skipfactor::Int=2, sortedby::F=identity) where {T,F<:Function}
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
        l.cache = nothing
        return l
    end
    function PairedSkipList{T,F}(target::PairedSkipList{T}, skipfactor::Int=2, sortedby::F=identity) where {T,F<:Function}
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
        l.cache = nothing
        return l
    end
end

function PairedSkipList{T}(elts...; sortedby::F=identity, skipfactor::Int=2) where {T,F}
    l = PairedSkipList{T,F}(skipfactor, sortedby)
    for elt in elts
        push!(l, elt)
    end
    return l
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
