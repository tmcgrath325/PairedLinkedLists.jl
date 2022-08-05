abstract type AbstractListNode{T,L} end
abstract type AbstractLinkedList{T} end
abstract type AbstractDoublyLinkedList{T} <: AbstractLinkedList{T} end
abstract type AbstractPairedLinkedList{T} <: AbstractLinkedList{T} end
abstract type AbstractTargetedLinkedList{T,L,N} <: AbstractPairedLinkedList{T} end

"""
    node = ListNode(list::DoublyLinkedList, data)

Create a `ListNode` belonging to the specified `list`. The node contains a reference `list` to the parent list, 
the provided `data`, a link `prev` to the preceding node, and a link `next` to the following node.
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
the provided `data`, a link `prev` to the preceding node, a link `next` to the following node, and double-link `partner` to another
`PairedListNode`.

A node's `partner` should always either be a reference to itself (denoting unpaired node) or a node belonging to the `partner`
of its parent `list`.
"""
mutable struct PairedListNode{T,L<:AbstractPairedLinkedList{T}} <: AbstractListNode{T,L}
    list::L
    data::T
    prev::PairedListNode{T,L}
    next::PairedListNode{T,L}
    partner::PairedListNode{T,L}
    function PairedListNode{T,L}(list::L) where {T,L<:AbstractPairedLinkedList{T}}
        node = new{T,PairedLinkedList{T}}(list)
        node.next = node
        node.prev = node
        node.partner = node
        return node
    end
    function PairedListNode{T,L}(list::L, data) where {T,L<:AbstractPairedLinkedList{T}}
        node = new{T,L}(list, data)
        node.next = node
        node.prev = node
        node.partner = node
        return node
    end
    function PairedListNode{T,L}(list::L, data, partner::PairedListNode{T,L}) where {T,L<:AbstractPairedLinkedList{T}}
        node = new{T,L}(list, data)
        node.next = node
        node.prev = node
        addpartner!(node, partner)
        return node
    end
end

"""
    node = TargetListNode(list::AbstractTargetLinkedList, data, [target::AbstractListNode])

Create a `TargetListNode` belonging to the specified `list`. The node contains a reference `list` to the parent list, 
the provided `data`, a link `prev` to the preceding node, a link `next` to the following node, and link `partner` to another
list node.

A node's `partner` may be undefined or a node belonging to the `partner` of its parent `list`.
"""
mutable struct TargetedListNode{T,L<:AbstractLinkedList{T},N<:AbstractListNode{T,L},P<:AbstractTargetedLinkedList{T,L,N}} <: AbstractListNode{T,P}
    list::P
    data::T
    prev::TargetedListNode{T,L,N,P}
    next::TargetedListNode{T,L,N,P}
    partner::Union{N,TargetedListNode{T,L,N,P}}
    function TargetedListNode{T,L,N,P}(list::P) where {T,L,N,P<:AbstractTargetedLinkedList{T,L,N}}
        node = new{T,L,N,P}(list)
        node.next = node
        node.prev = node
        node.partner = node
        return node
    end
    function TargetedListNode{T,L,N,P}(list::P, data) where {T,L,N,P<:AbstractTargetedLinkedList{T,L,N}}
        node = new{T,L,N,P}(list, data)
        node.next = node
        node.prev = node
        node.partner = node
        return node
    end
    function TargetedListNode{T,L,N,P}(list::P, data, partner::N) where {T,L,N,P<:AbstractTargetedLinkedList{T,L,N}}
        node = new{T,L,N,P}(list, data)
        node.next = node
        node.prev = node
        node.partner = partner
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
`tail` at the end of the list. The list also contains a reference to its "partner" list.

The first "real" node of a list  `l` can be accessed with `l.head.next`. Similarly, the last "real" node can
be accessed with `l.tail.prev`.
"""
mutable struct PairedLinkedList{T} <: AbstractPairedLinkedList{T}
    len::Int
    partner::PairedLinkedList{T}
    head::PairedListNode{T,PairedLinkedList{T}}
    tail::PairedListNode{T,PairedLinkedList{T}}
    function PairedLinkedList{T}() where T
        l = new{T}(0)
        l.partner = l
        l.head = PairedListNode{T,PairedLinkedList{T}}(l)
        l.tail = PairedListNode{T,PairedLinkedList{T}}(l)
        l.head.next = l.tail
        l.tail.prev = l.head
        return l
    end
    function PairedLinkedList{T}(partner::PairedLinkedList{T}) where T
        l = new{T}(0, partner)
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
"""
mutable struct TargetedLinkedList{T,L<:AbstractLinkedList{T},N<:AbstractListNode{T,L}} <: AbstractTargetedLinkedList{T,L,N}
    len::Int
    partner::Union{L,TargetedLinkedList{T,L,N}}
    head::TargetedListNode{T,L,N,TargetedLinkedList{T,L,N}}
    tail::TargetedListNode{T,L,N,TargetedLinkedList{T,L,N}}
    function TargetedLinkedList{T,L,N}() where {T,L,N}
        l = new{T,L,N}(0)
        l.partner = l
        l.head = TargetedListNode{T,L,N,TargetedLinkedList{T,L,N}}(l)
        l.tail = TargetedListNode{T,L,N,TargetedLinkedList{T,L,N}}(l)
        l.head.next = l.tail
        l.tail.prev = l.head
        return l
    end
    function TargetedLinkedList{T,L,N}(partner::L) where {T,L,N}
        l = new{T,L,N}(0, partner)
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
    t = nodetype(::AbstractLinkedList)
    t = nodetype(::Type{<:AbstractLinkedList})

Return the type of the nodes contained in the list.
"""
nodetype(::Type{<:AbstractDoublyLinkedList{T}}) where T = ListNode{T,DoublyLinkedList{T}}
nodetype(::Type{<:AbstractPairedLinkedList{T}}) where T = PairedListNode{T,PairedLinkedList{T}}
nodetype(::Type{<:AbstractTargetedLinkedList{T,L,N}}) where {T,L,N} = TargetedListNode{T,L,N,TargetedLinkedList{T,L,N}}
nodetype(l::AbstractLinkedList) = nodetype(typeof(l))


"""
    node = newnode(list, data)

Create an list node containing `data` of the appropriate type for the provided `list`.
(e.g. a `ListNode` is created for a `DoublyLinkedList`).
"""
newnode(l::AbstractLinkedList, data) = nodetype(l)(l, data)

# checks to see if the node is the first or last one
at_head(node::AbstractListNode) = node === node.prev
at_tail(node::AbstractListNode) = node === node.next

# Iterating with a node returns the nodes themselves, and terminates at a list's tail
Base.iterate(node::AbstractListNode) = iterate(node, node)
Base.iterate(::AbstractListNode, node::AbstractListNode) = at_tail(node) ? nothing : (node, node.next)
struct IteratingListNodes{T,L}
    start::AbstractListNode{T,L}
    rev::Bool
    function IteratingListNodes(start::AbstractListNode{T,L}; rev::Bool = false) where {T,L}
        return new{T,L}(start, rev)
    end
end
IteratingListNodes(l::AbstractLinkedList; rev::Bool = false) = IteratingListNodes(rev ? l.tail.prev : l.head.next; rev = rev)
Base.iterate(node::AbstractListNode) = iterate(node, node)
Base.iterate(iter::IteratingListNodes) = iterate(iter, iter.start)
Base.iterate(iter::IteratingListNodes{T}, node::AbstractListNode{T,L}) where {T,L} = iter.rev ? (at_head(node) ? nothing : (node, node.prev)) : (at_tail(node) ? nothing : (node, node.next))

# iterating over a list returns the data contained in each node
Base.iterate(l::AbstractLinkedList) = iterate(l, l.head.next)
Base.iterate(::AbstractLinkedList, node::AbstractListNode) = at_tail(node) ? nothing : (node.data, node.next)
struct IteratingListData{T,L}
    start::AbstractListNode{T,L}
    rev::Bool
    function IteratingListData(start::AbstractListNode{T,L}; rev::Bool = false) where {T,L}
        return new{T,L}(start, rev)
    end
end
IteratingListData(l::AbstractLinkedList{T}; rev::Bool = false) where T = IteratingListData(rev ? l.tail.prev : l.head.next; rev = rev)
Base.iterate(iter::IteratingListData) = iterate(iter, iter.start)
Base.iterate(iter::IteratingListData{T}, node::AbstractListNode{T,L}) where {L,T} =  iter.rev ? (at_head(node) ? nothing : (node.data, node.prev)) : (at_tail(node) ? nothing : (node.data, node.next))


Base.isempty(l::AbstractLinkedList) = l.len == 0
Base.length(l::AbstractLinkedList) = l.len
Base.collect(l::AbstractLinkedList{T}) where T = T[x for x in l]
Base.eltype(::Type{<:AbstractLinkedList{T}}) where T = T
Base.lastindex(l::AbstractLinkedList) = l.len
Base.keys(l::AbstractLinkedList) = LinearIndices(1:l.len)

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

function Base.empty!(l::AbstractLinkedList)
    removepair!(l)
    l.head.next = l.tail
    l.tail.prev = l.head
    return l
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
function deletenode!(node::Union{ListNode, TargetedListNode})
    prev = node.prev
    next = node.next
    prev.next = next
    next.prev = prev
    node.list.len -= 1
    return node
end
function deletenode!(node::PairedListNode)
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
function insertnode!(node::AbstractListNode{T,L}, prev::AbstractListNode{T,L}) where {T,L}
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
haspartner(obj::Union{PairedListNode, TargetedListNode, PairedLinkedList, TargetedLinkedList}) = (obj.partner !== obj)
haspartner(::Union{ListNode, DoublyLinkedList}) = false

"""
    addpartner!(node, partner_node)
    addpartner!(list, partner_list)

Add a link between a the provided node or list and another object of the same type to be assigned its `partner`. 

If the first object is a `PairedListNode' or a 'PairedLinkedList' and either object previously had a partner, the prior link is removed.

If the first object is a `TargetedListNode` or a `TargetedLinkedList`, the second object remains unchanged.
"""
function addpartner!(list::PairedLinkedList{T}, partner::PairedLinkedList{T}) where T
    # remove existing partners
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

function addpartner!(node::PairedListNode{T,L}, partner::PairedListNode{T,L}) where {T,L}
    node.list.partner === partner.list || throw(ArgumentError("The provided nodes must belong to paired lists."))
    # remove existing partners
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

function addpartner!(list::TargetedLinkedList{T,L}, partner::L) where {T,L}
    list.partner = partner
    return list
end

function addpartner!(node::TargetedListNode{T,L,N}, partner::N) where {T,L,N}
    node.list.partner === partner.list || throw(ArgumentError("The provided nodes must belong to paired lists."))
    node.partner = partner
    return node
end

"""
    removepartner!(node)

Remove the link between the node or list and its partner (if the object is already paired) and return `node`.

If the object is a `PairedListNode` or `PairedLinkedList`, the link will be deleted from both the object and its partner.

If the object is a `TargetedListNode` or `PairedLinkedList`, the link will be deleted from only the object.
"""
function removepartner!(node::PairedListNode)
    if haspartner(node)
        partner = node.partner
        node.partner = node
        partner.partner = partner
    end
    return node
end
function removepartner!(node::TargetedListNode)
    if haspartner(node)
        node.partner = node
    end
    return node
end
removepartner!(node::ListNode) = node;

function removepartner!(list::PairedLinkedList)
    if haspartner(list)
        partner = list.partner
        list.partner = list
        partner.partner = partner
        for node in IteratingListNodes(list)
            removepartner!(node)
        end
    end
    return list
end
function removepartner!(list::TargetedLinkedList)
    if haspartner(list)
        list.partner = list
        for node in IteratingListNodes(list)
            removepartner!(node)
        end
    end
    return list
end

function removepartner!(l::Union{PairedLinkedList,TargetedLinkedList}, idx::Int)
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
