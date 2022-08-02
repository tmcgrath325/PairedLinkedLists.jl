abstract type AbstractListNode{T} end
abstract type AbstractLinkedList{T} end
abstract type AbstractDoublyLinkedList{T} <: AbstractLinkedList{T} end
abstract type AbstractPairedLinkedList{T} <: AbstractLinkedList{T} end

"""
    node = ListNode(list::DoublyLinkedList, data)

Create a `ListNode` belonging to the specified `list`. The node contains a reference `list` to the parent list, 
the provided `data`, a link `prev` to the preceding node, and a link `next` to the following node.
"""
mutable struct ListNode{T} <: AbstractListNode{T}
    list::AbstractDoublyLinkedList{T}
    data::T
    prev::ListNode{T}
    next::ListNode{T}
    function ListNode(list::AbstractDoublyLinkedList{T}) where T
        node = new{T}(list)
        node.next = node
        node.prev = node
        return node
    end
    function ListNode(list::AbstractDoublyLinkedList{T}, data) where T
        node = new{T}(list, data)
        node.next = node
        node.prev = node
        return node
    end
end

"""
    node = PairedListNode(list::PairedLinkedList, data)

Create a `PairedListNode` belonging to the specified `list`. The node contains a reference `list` to the parent list, 
the provided `data`, a link `prev` to the preceding node, a link `next` to the following node, and link `partner` to another
`PairedListNode`.

A node's `partner` should always either be a reference to itself (denoting unpaired node) or a node belonging to the `partner`
of its parent list.
"""
mutable struct PairedListNode{T} <: AbstractListNode{T}
    list::AbstractPairedLinkedList{T}
    data::T
    prev::PairedListNode{T}
    next::PairedListNode{T}
    partner::PairedListNode{T}
    function PairedListNode(list::AbstractPairedLinkedList{T}) where T
        node = new{T}(list)
        node.next = node
        node.prev = node
        node.partner = node
        return node
    end
    function PairedListNode(list::AbstractPairedLinkedList{T}, data) where T
        node = new{T}(list, data)
        node.next = node
        node.prev = node
        node.partner = node
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
    len::Int
    head::ListNode{T}
    tail::ListNode{T}
    function DoublyLinkedList{T}() where T
        l = new{T}(0)
        l.head = ListNode(l)
        l.tail = ListNode(l)
        l.head.next = l.tail
        l.tail.prev = l.head
        return l
    end
end

DoublyLinkedList() = DoublyLinkedList{Any}()
DoublyLinkedList{T}(l::AbstractLinkedList{S}) where {S,T} = DoublyLinkedList{T}(collect(l)...)
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
`tail` at the end of the list. The list also contains a reference to its "partner" list.

The first "real" node of a list  `l` can be accessed with `l.head.next`. Similarly, the last "real" node can
be accessed with `l.tail.prev`.
"""
mutable struct PairedLinkedList{T} <: AbstractPairedLinkedList{T}
    len::Int
    partner::PairedLinkedList{T}
    head::PairedListNode{T}
    tail::PairedListNode{T}
    function PairedLinkedList{T}() where T
        l = new{T}(0)
        l.partner = l
        l.head = PairedListNode(l)
        l.tail = PairedListNode(l)
        l.head.next = l.tail
        l.tail.prev = l.head
        return l
    end
    function PairedLinkedList{T}(partner::PairedLinkedList{T}) where T
        l = new{T}(0, partner)
        l.head = PairedListNode(l)
        l.tail = PairedListNode(l)
        l.head.next = l.tail
        l.tail.prev = l.head
        return l
    end
end

PairedLinkedList() = PairedLinkedList{Any}()
PairedLinkedList{T}(l::AbstractLinkedList{S}) where {S,T} = PairedLinkedList{T}(collect(l)...)
function PairedLinkedList{T}(elts...) where T
    l = PairedLinkedList{T}()
    for elt in elts
        push!(l, elt)
    end
    return l
end

"""
    node = newnode(list, data)

Create an list node containing `data` of the appropriate type for the provided `list`.
(e.g. a `ListNode` is created for a `DoublyLinkedList`).
"""
newnode(l::DoublyLinkedList{T}, data) where T = ListNode(l, data)
newnode(l::PairedLinkedList{T}, data) where T = PairedListNode(l, data)


at_head(node::AbstractListNode) = node === node.prev
at_tail(node::AbstractListNode) = node === node.next

# Iterating with a node returns the nodes themselves, and terminates at a list's tail
Base.iterate(node::AbstractListNode) = iterate(node, node)
Base.iterate(::AbstractListNode, node::AbstractListNode) = at_tail(node) ? nothing : (node, node.next)
struct IteratingListNodes{T}
    start::AbstractListNode{T}
    rev::Bool
    function IteratingListNodes(start::AbstractListNode{T}; rev::Bool = false) where T
        return new{T}(start, rev)
    end
end
IteratingListNodes(l::AbstractLinkedList; rev::Bool = false) = IteratingListNodes(rev ? l.tail.prev : l.head.next; rev = rev)
Base.iterate(node::AbstractListNode) = iterate(node, node)
Base.iterate(iter::IteratingListNodes) = iterate(iter, iter.start)
Base.iterate(iter::IteratingListNodes{T}, node::AbstractListNode{T}) where T = iter.rev ? (at_head(node) ? nothing : (node, node.prev)) : (at_tail(node) ? nothing : (node, node.next))

# iterating over a list returns the data contained in each node
Base.iterate(l::AbstractLinkedList) = iterate(l, l.head.next)
Base.iterate(::AbstractLinkedList, node::AbstractListNode) = at_tail(node) ? nothing : (node.data, node.next)
struct IteratingListData{T}
    start::AbstractListNode{T}
    rev::Bool
    function IteratingListData(start::AbstractListNode{T}; rev::Bool = false) where T
        return new{T}(start, rev)
    end
end
IteratingListData(l::AbstractLinkedList{T}; rev::Bool = false) where T = IteratingListData(rev ? l.tail.prev : l.head.next; rev = rev)
Base.iterate(iter::IteratingListData) = iterate(iter, iter.start)
Base.iterate(iter::IteratingListData{T}, node::AbstractListNode{T}) where T =  iter.rev ? (at_head(node) ? nothing : (node.data, node.prev)) : (at_tail(node) ? nothing : (node.data, node.next))


Base.isempty(l::AbstractLinkedList) = l.len == 0
Base.length(l::AbstractLinkedList) = l.len
Base.collect(l::AbstractLinkedList{T}) where T = T[x for x in l]
Base.eltype(::Type{<:AbstractLinkedList{T}}) where T = T
Base.lastindex(l::AbstractLinkedList) = l.len

function Base.first(l::AbstractLinkedList)
    isempty(l) && throw(ArgumentError("List is empty"))
    return l.head.next.data
end

function Base.last(l::AbstractLinkedList)
    isempty(l) && throw(ArgumentError("List is empty"))
    return l.tail.prev.data
end

Base.:(==)(n1::AbstractListNode, n2::AbstractListNode) = n1.data == n2.data

Base.:(==)(l1::AbstractLinkedList{T}, l2::AbstractLinkedList{S}) where {T,S} = false

function Base.:(==)(l1::AbstractLinkedList{T}, l2::AbstractLinkedList{T}) where T
    length(l1) == length(l2) || return false
    for (i, j) in zip(l1, l2)
        i == j|| return false
    end
    return true
end

function Base.map(f::Base.Callable, l::DoublyLinkedList{T}) where T
    if isempty(l) && f isa Function
        S = Core.Compiler.return_type(f, Tuple{T})
        return DoublyLinkedList{S}()
    elseif isempty(l) && f isa Type
        return DoublyLinkedList{f}()
    else
        S = typeof(f(first(l)))
        l2 = DoublyLinkedList{S}()
        for h in l
            el = f(h)
            if el isa S
                push!(l2, el)
            else
                R = typejoin(S, typeof(el))
                l2 = DoublyLinkedList{R}(collect(l2)...)
                push!(l2, el)
            end
        end
        return l2
    end
end

function Base.filter(f::Function, l::L) where L <: AbstractLinkedList
    l2 = L()
    for h in l
        if f(h)
            push!(l2, h)
        end
    end
    return l2
end

function Base.reverse(l::L) where L <: AbstractLinkedList
    l2 = L()
    for h in l
        pushfirst!(l2, h)
    end
    return l2
end

function Base.copy(l::L) where L <: AbstractLinkedList
    l2 = L()
    for h in l
        push!(l2, h)
    end
    return l2
end

"""
    node = getnode(l::AbstractLinkedList, index)

Return the node at the specified index of the list.
"""
function getnode(l::AbstractLinkedList, idx::Int)
    node = l.head
    for i in 1:idx
        node = node.next
    end
    return node
end

# getindex returns the data at the node at that index
function Base.getindex(l::AbstractLinkedList, idx::Int)
    node = getnode(l, idx)
    return node.data
end

function Base.getindex(l::L, r::UnitRange) where L <: AbstractLinkedList
    @boundscheck 0 < first(r) < last(r) <= l.len || throw(BoundsError(l, r))
    l2 = L()
    @inbounds node = getnode(l, first(r))
    node2 = l2.head
    len = length(r)
    for j in 1:len
        n = newnode(l2, node.data)
        insertnode!(n, node2)
        node = node.next
        node2 = node2.next
    end
    l2.len = len
    return l2
end

function Base.setindex!(l::AbstractLinkedList{T}, data, idx::Int) where T
    node = getnode(l, idx)
    node.data = convert(T, data)
    return l
end

function Base.append!(l1::L, l2::L) where L <: AbstractLinkedList
    if haspartner(l2)
        l1.partner === l2.partner || throw(ArgumentError("The lists must have the same partner to be combined."))
    end
    for node in IteratingListNodes(l2)
        node.list = l1
    end
    l1.tail.prev.next = l2.head.next 
    l2.tail.prev.next = l1.tail
    l1.len += length(l2)
    return l1
end

function Base.append!(l::AbstractLinkedList, elts...)
    for elt in elts
        push!(l, elt)
    end
    return l
end

"""
    deletenode!(node::ListNode)

Remove `node` from the list to which it belongs, update the list's length, and return the node.
"""
function deletenode!(node::AbstractListNode)
    prev = node.prev
    next = node.next
    prev.next = next
    next.prev = prev
    haspartner(node) && removepartner!(node)
    node.list.len -= 1
    return node
end

"""
    insertnode!(node, prev)`

Insert `node` into a list after the preceding node `prev`, update the list's length, and return the node.

`node` and `prev` must belong to the same list.
"""
function insertnode!(node::AbstractListNode{T}, prev::AbstractListNode{T}) where T
    node.list === prev.list || throw(ArgumentError("The nodes must have the same parent list."))
    if haspartner(node)
        node.partner.list === prev.list.partner || throw(ArgumentError("The node cannot be added to a list that is partnered to a different list than the node."))
    end
    next = prev.next
    node.prev = prev
    node.next = next
    prev.next = node
    next.prev = node
    node.list.len += 1
    return node
end

function Base.delete!(l::AbstractLinkedList, idx::Int)
    @boundscheck 0 < idx <= l.len || throw(BoundsError(l, idx))
    node = getnode(l, idx)
    deletenode!(node)
    return l
end

function Base.delete!(l::AbstractLinkedList, r::UnitRange)
    @boundscheck 0 < first(r) < last(r) <= l.len || throw(BoundsError(l, r))
    @inbounds node = getnode(l, first(r))
    prev = node.prev
    len = length(r)
    for j in 1:len
        haspartner(node) && removepartner!(node)
        node = node.next
    end
    next = node
    prev.next = next
    next.prev = prev
    l.len -= len
    return l
end

function Base.push!(l::AbstractLinkedList, data)
    node = newnode(l, data)
    insertnode!(node, l.tail.prev)
    return l
end

function Base.pushfirst!(l::AbstractLinkedList, data)
    node = newnode(l, data)
    insertnode!(node, l.head)
    return l
end

function Base.pop!(l::AbstractLinkedList)
    isempty(l) && throw(ArgumentError("List must be non-empty"))
    node = l.tail.prev
    data = node.data
    deletenode!(node)
    return data
end

function Base.popfirst!(l::AbstractLinkedList)
    isempty(l) && throw(ArgumentError("List must be non-empty"))
    node = l.head.next
    data = node.data
    deletenode!(node)
    return data
end

if isdefined(Base, :popat!)  # We will overload if it is defined, else we define on our own
    import Base: popat!
end

function popat!(l::AbstractLinkedList, idx::Int)
    @boundscheck 0 < idx <= l.len || throw(BoundsError(l, idx))
    node = getnode(l, idx)
    data = node.data
    deletenode!(node)
    return data
end

function popat!(l::AbstractLinkedList, idx::Int, default)
    if !(0 < idx <= l.len) 
        return default;
    end
    return popat!(l, idx)
end

function Base.insert!(l::AbstractLinkedList, idx::Int, data)
    @boundscheck 0 < idx <= l.len+1 || throw(BoundsError(l, idx))
    node = newnode(l, data)
    prev = getnode(l, idx-1)
    insertnode!(node, prev)
    return l
end

const _default_splice = []

function Base.splice!(l::L, idx::Int, ins=_default_splice) where L <: AbstractLinkedList
    @boundscheck 0 < idx <= l.len || throw(BoundsError(l, idx))
    node = getnode(l, idx)
    data = node.data
    prev = node.prev
    next = node.next
    haspartner(node) && removepartner!(node)

    if length(ins) == 0
        prev.next = next
        next.prev = prev
        l.len -= 1
        return data
    end
    for insdata in ins
        node = newnode(l, insdata)
        node.prev = prev
        node.prev.next = node
        prev = node
    end
    node.next = next
    next.prev = node
    l.len += length(ins) - 1
    return data
end

function Base.splice!(l::L, r::AbstractUnitRange{<:Integer}, ins=_default_splice) where {T, L <: AbstractLinkedList{T}}
    @boundscheck (0 < first(r) <= l.len && last(r) <= l.len ) || throw(BoundsError(l, r))
    len = length(r)
    data = Vector{T}()
    @inbounds node = getnode(l, first(r))
    prev = len > 0 ? node.prev : node
    for i in 1:len
        push!(data, node.data)
        node = node.next
        haspartner(node) && removepartner!(node)
    end
    next = len > 0 ? node : node.next
    if length(ins) == 0
        prev.next = next
        next.prev = prev
        l.len -= len
        return data
    end
    for insdata in ins
        node = newnode(l, insdata)
        node.prev = prev
        node.prev.next = node
        prev = node
    end
    node.next = next
    next.prev = node
    l.len += length(ins) - len
    return data
end


"""
    haspartner(node::PairedListNode) -> Bool
    haspartner(list::PairedListNode) -> Bool

Return `true` if the provided node or list has a partner, and false otherwise. 
"""
haspartner(node::PairedListNode) = (node.partner !== node)
haspartner(list::PairedLinkedList) = (list.partner !== list)
haspartner(::ListNode) = false
haspartner(::DoublyLinkedList) = false

"""
    addpartner!(node, partner_node)
    addpartner!(list, partner_list)

Add a link between a the provided node or list and another object of the same type to be assigned its `partner`. 
If either object previously had a partner, the prior link is removed.
"""
function addpartner!(list::PairedLinkedList{T}, partner::PairedLinkedList{T}) where T
    # ensure there are no orphaned partners and remove existing partners from the nodes
    if haspartner(list)
        removepartner!(list)
    end
    if haspartner(partner)
        removepartner!(partner)
    end

    list.partner = partner
    partner.partner = list
    return list
end

function addpartner!(node::PairedListNode{T}, partner::PairedListNode{T}) where T
    node.list.partner === partner.list || throw(ArgumentError("The provided nodes must belong to paired lists."))
    # ensure there are no orphaned partners
    if haspartner(node)
        removepartner!(node)
    end
    if haspartner(partner)
        removepartner!(partner)
    end

    node.partner = partner
    partner.partner = node
    return node
end

"""
    removepartner!(node)

Remove the link between the node or list and its partner (if the object is already paired) and return `node`.
"""
function removepartner!(node::PairedListNode)
    if haspartner(node)
        partner = node.partner
        node.partner = node
        partner.partner = partner
    end
    return node
end
function removepartner!(list::PairedLinkedList)
    if haspartner(list)
        partner = list.partner
        list.partner = list
        partner.partner = partner
        for list in IteratingListNodes(list)
            removepartner!(list)
        end
    end
    return list
end
removepartner!(node::ListNode) = node;
function removepartner!(l::PairedLinkedList, idx::Int)
    node = getnode(l, idx)
    return removepartner!(node)
end


function Base.show(io::IO, node::AbstractListNode)
    x = node.data
    print(io, "$(typeof(node))($x)")
end

function Base.show(io::IO, l::AbstractLinkedList)
    print(io, typeof(l), '(')
    join(io, l, ", ")
    print(io, ')')
end
