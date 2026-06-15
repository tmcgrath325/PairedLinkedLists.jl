function Base.first(l::AbstractList)
    isempty(l) && throw(ArgumentError("List is empty"))
    return l.head.next.data
end

function Base.last(l::AbstractList)
    isempty(l) && throw(ArgumentError("List is empty"))
    return l.tail.prev.data
end

"""
    node = head(list)

Returns the first "real" node in the list. Note that this is *not* the same as `list.head`, which is a "dummy" node.
"""
head(l::AbstractList) = l.len < 1 ? throw(ArgumentError("List must be non-empty")) : l.head.next
"""
    node = head(list)

Returns the last "real" node in the list. Note that this is *not* the same as `list.tail`, which is a "dummy" node.
"""
tail(l::AbstractList) = l.len < 1 ? throw(ArgumentError("List must be non-empty")) : l.tail.prev

"""
    t = nodetype(::AbstractList)
    t = nodetype(::Type{<:AbstractList})

Return the type of the nodes contained in the list.
"""
nodetype(::Type{<:DoublyLinkedList{T}}) where T = ListNode{T,DoublyLinkedList{T}}
nodetype(::Type{<:PairedLinkedList{T}}) where T = PairedListNode{T,PairedLinkedList{T}}
nodetype(::Type{<:TargetedLinkedList{T,R,N}}) where {T,R,N} = TargetedListNode{T,N,TargetedLinkedList{T,R,N}}
nodetype(l::AbstractList) = nodetype(typeof(l))

"""
    t = listtype(::AbstractNode)
    t = listtype(::Type{<:AbstractNode})

Return the type of list that can contain the provided type of node.
"""
listtype(::Type{<:AbstractNode{T,L}}) where {T,L} = L
listtype(n::AbstractNode) = listtype(typeof(n))


"""
    node = newnode(list, data)

Create an list node containing `data` of the appropriate type for the provided `list`.
(e.g. a `ListNode` is created for a `DoublyLinkedList`). 

The `node` is disconnected from the `list` (see [`insertafter!`](@ref)).
"""
newnode(l::AbstractList, data) = nodetype(l)(l, data)

"""
    athead(node) -> Bool

Return true if the node is the "dummy" node at the beginning of the list, and false otherwise.
"""
athead(node::AbstractNode) = node === node.prev

"""
    attail(node) -> Bool

Return true if the node is the "dummy" node at the end of the list, and false otherwise.
"""
attail(node::AbstractNode) = node === node.next

"""
    isdisconnected(node) -> Bool

Return true if the node is not connected to any other node, and false otherwise.
"""
isdisconnected(node::AbstractNode) = (node.prev === node && node.next === node) || (node.prev.next !== node && node.next.prev !== node)

# Iterating with a node returns the nodes themselves, and terminates at a list's tail
Base.iterate(node::AbstractNode) = iterate(node, node)
Base.iterate(::AbstractNode, node::AbstractNode) = attail(node) ? nothing : (node, node.next)
Base.IteratorSize(::AbstractNode) = Base.SizeUnknown()
"""
    ListNodeIterator(start; rev=false)

Returns an iterator over the nodes of a linked list, starting at the specified node `start`.

If `rev` is `true`, the iterator will advance toward the head of the list.
Otherwise, it will advance toward the tail of the list.
"""
struct ListNodeIterator{S<:AbstractNode}
    start::S
    stop::S
    rev::Bool
    function ListNodeIterator(start::S, stop::Union{Nothing,S}=nothing; rev::Bool = false) where S
        stopnode::S = !isnothing(stop) ? stop : 
            (rev ? start.list.head : start.list.tail) 
        start.list === stopnode.list || throw(ArgumentError("The starting and stopping nodes must belong to the same list."))
        return new{S}(start, stopnode, rev)
    end
end
"""
    ListNodeIterator(list; rev=false)

Returns an iterator over the nodes of a linked list.

If `rev` is `true`, the iterator will start at the tail of the list and advance toward the head.
Otherwise, it will start at the head of the list and advance toward the tail.
"""
function ListNodeIterator(l::AbstractList; rev::Bool = false)
    start = rev ? l.tail.prev : l.head.next
    stop = l.len == 0 ? start : 
        (rev ? l.head : l.tail)
    return ListNodeIterator(start, stop; rev = rev)
end
Base.iterate(iter::ListNodeIterator) = iterate(iter, iter.start)
Base.iterate(iter::ListNodeIterator{S}, node::S) where S = (node === iter.stop || (iter.rev ? athead(node) : attail(node))) ? nothing : (node, iter.rev ? node.prev : node.next)
Base.IteratorSize(::ListNodeIterator) = Base.SizeUnknown()

# iterating over a list returns the data contained in each node
Base.iterate(l::AbstractList) = iterate(l, l.head.next)
Base.iterate(::AbstractList, node::AbstractNode) = attail(node) ? nothing : (node.data, node.next)
"""
    ListDataIterator(start; rev=false)

Returns an iterator over the data contained in a linked list, starting at the specified node `start`.

If `rev` is `true`, the iterator will advance toward the head of the list.
Otherwise, it will advance toward the tail of the list.
"""
struct ListDataIterator{S<:AbstractNode}
    start::S
    stop::S
    rev::Bool
    function ListDataIterator(start::S, stop::Union{Nothing,S}=nothing; rev::Bool = false) where S
        stopnode::S = !isnothing(stop) ? stop : 
            (rev ? start.list.head : start.list.tail) 
        start.list === stopnode.list || throw(ArgumentError("The starting and stopping nodes must belong to the same list."))
        return new{S}(start, stopnode, rev)
    end
end
"""
    ListDataIterator(list; rev=false)

Returns an iterator over the data contained in a linked list.

If `rev` is `true`, the iterator will start at the tail of the list and advance toward the head.
Otherwise, it will start at the head of the list and advance toward the tail.
"""
function ListDataIterator(l::AbstractList{T}; rev::Bool = false) where T
    start = rev ? l.tail.prev : l.head.next
    stop = l.len == 0 ? start : 
        (rev ? l.head : l.tail)
    return ListDataIterator(start, stop; rev = rev)
end
Base.iterate(iter::ListDataIterator) = iterate(iter, iter.start)
Base.iterate(iter::ListDataIterator{S}, node::S) where S =  (node === iter.stop || (iter.rev ? athead(node) : attail(node))) ? nothing : (node.data, iter.rev ? node.prev : node.next)
Base.IteratorSize(::ListDataIterator) = Base.SizeUnknown()

Base.isempty(l::AbstractList) = l.len == 0
Base.length(l::AbstractList) = l.len
Base.eltype(::Type{<:AbstractList{T}}) where T = T
Base.lastindex(l::AbstractList) = l.len
Base.keys(l::AbstractList) = LinearIndices(1:l.len)

Base.:(==)(n1::AbstractNode, n2::AbstractNode) = (hastarget(n1) || hastarget(n2) ? hastarget(n1) && hastarget(n2) && n1.target.data == n2.target.data : true) && n1.data == n2.data 
Base.:(==)(l1::AbstractList{T}, l2::AbstractList{S}) where {T,S} = false

function Base.:(==)(l1::AbstractList{T}, l2::AbstractList{T}) where T
    length(l1) == length(l2) || return false
    for (i, j) in zip(ListNodeIterator(l1), ListNodeIterator(l2))
        i == j || return false
    end
    return true
end

# `isequal`/`hash` are the strict pair Dict/Set relies on; `==` above is loose.
# Concrete list type is excluded: `==` spans concrete types, so hash must too.
Base.isequal(l1::AbstractList{T}, l2::AbstractList{S}) where {T,S} = false

function Base.isequal(l1::AbstractList{T}, l2::AbstractList{T}) where T
    length(l1) == length(l2) || return false
    for (n1, n2) in zip(ListNodeIterator(l1), ListNodeIterator(l2))
        hastarget(n1) == hastarget(n2) || return false
        hastarget(n1) && !isequal(n1.target.data, n2.target.data) && return false
        isequal(n1.data, n2.data) || return false
    end
    return true
end

function Base.hash(l::AbstractList, h::UInt)
    h = hash(eltype(l), h)
    for node in ListNodeIterator(l)
        h = hash(node.data, h)
        h = hash(hastarget(node), h)
        hastarget(node) && (h = hash(node.target.data, h))
    end
    return h
end

"""
    map(f, l::DoublyLinkedList)

Apply `f` to each element of `l`, returning a new `DoublyLinkedList`.

`map` is defined only for `DoublyLinkedList`. It is intentionally not provided for
the other list types: an arbitrary `f` need not preserve a `SkipList`'s `sortedby`
ordering, and mapping a [`PairedLinkedList`](@ref) or [`TargetedLinkedList`](@ref)
would leave the new list's nodes without the cross-list `target` links that define
those types. Build such a list explicitly instead.
"""
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

function Base.filter!(f::Function, l::L) where L <: AbstractLinkedList
    for n in ListNodeIterator(l)
        if !f(n.data)
            deletenode!(n)
        end
    end
    return l
end
Base.filter(f::Function, l::AbstractLinkedList) = return filter!(f, copy(l))

function Base.reverse!(l::L) where L <: AbstractLinkedList
    prevprevnode = l.tail
    prevnode = l.tail
    oldtail = tail(l)
    for (i,n) in enumerate(ListNodeIterator(l))
        prevnode.prev = n
        if i>1
            prevnode.next = prevprevnode
        end
        prevprevnode = prevnode
        prevnode = n
    end
    prevnode.prev = oldtail
    prevnode.next = prevprevnode
    oldtail.prev = l.head
    l.head.next = oldtail
    return l
end
Base.reverse(l::AbstractLinkedList) = return reverse!(copy(l))

function Base.copy!(l2::L, l::L) where L <: Union{DoublyLinkedList, TargetedLinkedList}
    hastarget(l) && addtarget!(l2, l.target)
    len = l2.len
    existingnode = l2.head
    for (i,n) in enumerate(ListNodeIterator(l))
        if i<=len
            existingnode = existingnode.next
            existingnode.data = n.data
            hastarget(n) && addtarget!(existingnode, n.target)
        else
            push!(l2, n.data)
            hastarget(n) && addtarget!(tail(l2), n.target)
        end
    end
    if l.len < len 
        existingnode.next = l2.tail
        l2.tail.prev = existingnode
        l2.len = l.len
    end
    return l2
end
function Base.copy(l::L) where L <: Union{DoublyLinkedList, SkipList, TargetedLinkedList}
    l2 = empty(l)
    hastarget(l) && addtarget!(l2, l.target)
    for n in ListNodeIterator(l)
        push!(l2, n.data)
        hastarget(n) && addtarget!(tail(l2), n.target)
    end
    return l2
end

function Base.copy!(l2::L, l::L) where L <: PairedLinkedList
    !hastarget(l2) && addtarget!(l2, L())
    target2 = l2.target
    len = l2.len
    plen = target2.len
    targetmap = Tuple{Int,nodetype(L)}[]

    existingnode = l2.head
    for (i,n) in enumerate(ListNodeIterator(l))
        if i<=len
            existingnode = existingnode.next
            existingnode.data = n.data
        else
            push!(l2, n.data)
        end
        hastarget(n) && push!(targetmap, (i,n.target))
    end
    if l.len < len 
        existingnode.next = l2.tail
        l2.tail.prev = existingnode
        l2.len = l.len
    end
    if hastarget(l2)
        existingnode = target2.head
        for (i,n) in enumerate(ListNodeIterator(l.target))
            if i<=plen
                existingnode = existingnode.next
                existingnode.data = n.data
            else
                push!(target2, n.data)
            end
            if hastarget(n)
                targetidx = getfirst(x->n===x[2], targetmap)[1]
                addtarget!(getnode(l2, targetidx), i<=plen ? existingnode : tail(target2))
            end
        end
        if l.target.len < plen 
            existingnode.next = target2.tail
            target2.tail.prev = existingnode
            target2.len = l.target.len
        end
    end
    return l2
end
function Base.copy(l::L) where L <: Union{PairedLinkedList, PairedSkipList}
    l2 = empty(l)
    target2 = empty(l.target)
    addtarget!(l2, target2)
    targetmap = Tuple{Int,nodetype(L)}[]

    for (i,n) in enumerate(ListNodeIterator(l))
        push!(l2, n.data)
        hastarget(n) && push!(targetmap, (i,n.target))
    end
    for n in ListNodeIterator(l.target)
        push!(target2, n.data)
        if hastarget(n)
            targetidx = getfirst(x->n===x[2], targetmap)[1]
            addtarget!(getnode(l2, targetidx), tail(target2))
        end
    end
    return l2
end

function Base.empty!(l::AbstractLinkedList)
    if hastarget(l)
        # remove all of the inter-list links
        target = l.target
        removetarget!(l)
        addtarget!(l, target)
    end
    l.head.next = l.tail
    l.tail.prev = l.head
    l.len = 0
    return l
end
Base.empty(l::AbstractList) = (typeof(l))()
# Skip lists carry an ordering key and skip factor that the inner constructor cannot
# default for a non-`identity` `sortedby`; thread them through so the empty copy sorts identically.
Base.empty(l::AbstractSkipLinkedList) = (typeof(l))(l.skipfactor, l.sortedby)

"""
    node = getnode(l::AbstractList, index)

Return the node at the specified index of the list.
"""
function getnode(l::AbstractList, idx::Int)
    @boundscheck 0 < idx <= l.len || throw(BoundsError(l, idx))
    node = l.head
    for i in 1:idx
        node = node.next
    end
    return node
end

# getindex returns the data at the node at that index
function Base.getindex(l::AbstractList, idx::Int)
    @boundscheck 0 < idx <= l.len || throw(BoundsError(l, idx))
    node = getnode(l, idx)
    return node.data
end

function Base.getindex(l::L, r::UnitRange) where L <: AbstractList
    isempty(r) && return empty(l)
    @boundscheck 0 < first(r) && last(r) <= l.len || throw(BoundsError(l, r))
    l2 = empty(l)
    @inbounds node = getnode(l, first(r))
    node2 = l2.head
    len = length(r)
    for j in 1:len
        n = newnode(l2, node.data)
        insertafter!(n, node2)
        node = node.next
        node2 = node2.next
    end
    l2.len = len
    return l2
end

function Base.setindex!(l::AbstractLinkedList{T}, data, idx::Int) where T
    @boundscheck 0 < idx <= l.len || throw(BoundsError(l, idx))
    node = getnode(l, idx)
    node.data = convert(T, data)
    return l
end

function Base.append!(l1::L, l2::L) where L <: AbstractLinkedList
    if hastarget(l2)
        l1.target === l2.target || throw(ArgumentError("The lists must have the same target to be combined."))
    end
    isempty(l2) && return l1
    for node in ListNodeIterator(l2)
        node.list = l1
    end
    # Splice l2's real nodes between l1's last real node and l1's tail sentinel,
    # linking both directions. Reading through the sentinels (rather than head/tail,
    # which throw on an empty list) makes an empty l1 fall out as a plain prepend.
    firstl2 = l2.head.next
    lastl2 = l2.tail.prev
    lastl1 = l1.tail.prev
    lastl1.next = firstl2
    firstl2.prev = lastl1
    lastl2.next = l1.tail
    l1.tail.prev = lastl2
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
function deletenode!(node::Union{ListNode, AbstractTargetedListNode})
    prev = node.prev
    next = node.next
    prev.next = next
    next.prev = prev
    node.list.len -= 1
    return node
end
function deletenode!(node::AbstractPairedListNode)
    prev = node.prev
    next = node.next
    prev.next = next
    next.prev = prev
    hastarget(node) && removetarget!(node)
    node.list.len -= 1
    return node
end

"""
    insertafter!(node, prev)`

Insert `node` into a list after the preceding node `prev`, update the list's length, and return the node.

`node` and `prev` must belong to the same list.
"""
function insertafter!(node::N, prev::N) where N <: AbstractNode
    node.list === prev.list || throw(ArgumentError("The nodes must have the same parent list."))
    if hastarget(node)
        node.target.list === prev.list.target || throw(ArgumentError("The node cannot be added to a list that is targeted to a different list than the node."))
    end
    next = prev.next
    node.prev = prev
    node.next = next
    prev.next = node
    next.prev = node
    node.list.len += 1
    return node
end

"""
    insertbefore!(node, next)`

Insert `node` into a list before the subsequent node `next`, update the list's length, and return the node.

`node` and `next` must belong to the same list.
"""
function insertbefore!(node::N, next::N) where N <: AbstractNode
    node.list === next.list || throw(ArgumentError("The nodes must have the same parent list."))
    if hastarget(node)
        node.target.list === next.list.target || throw(ArgumentError("The node cannot be added to a list that is targeted to a different list than the node."))
    end
    prev = next.prev
    node.next = next
    node.prev = prev
    prev.next = node
    next.prev = node
    node.list.len += 1
    return node
end

function Base.delete!(l::AbstractList, idx::Int)
    @boundscheck 0 < idx <= l.len || throw(BoundsError(l, idx))
    node = getnode(l, idx)
    deletenode!(node)
    return l
end

function Base.delete!(l::AbstractList, r::UnitRange)
    isempty(r) && return l
    @boundscheck 0 < first(r) && last(r) <= l.len || throw(BoundsError(l, r))
    @inbounds node = getnode(l, first(r))
    prev = node.prev
    len = length(r)
    for j in 1:len
        hastarget(node) && removetarget!(node)
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
    insertbefore!(node, l.tail)
    return l
end

function Base.pushfirst!(l::AbstractLinkedList, data)
    node = newnode(l, data)
    insertafter!(node, l.head)
    return l
end

function Base.pop!(l::AbstractList)
    isempty(l) && throw(ArgumentError("List must be non-empty"))
    node = deletenode!(tail(l))
    return node.data
end

function Base.popfirst!(l::AbstractList)
    isempty(l) && throw(ArgumentError("List must be non-empty"))
    node = deletenode!(head(l))
    return node.data
end

if isdefined(Base, :popat!)  # We will overload if it is defined, else we define on our own
    import Base: popat!
end

function popat!(l::AbstractList, idx::Int)
    @boundscheck 0 < idx <= l.len || throw(BoundsError(l, idx))
    node = deletenode!(getnode(l, idx))
    return node.data
end

function popat!(l::AbstractList, idx::Int, default)
    if !(0 < idx <= l.len) 
        return default;
    end
    return popat!(l, idx)
end

function Base.insert!(l::AbstractLinkedList, idx::Int, data)
    @boundscheck 0 < idx <= l.len+1 || throw(BoundsError(l, idx))
    node = newnode(l, data)
    # idx == l.len+1 inserts at the end: the successor is the tail sentinel,
    # which getnode does not address.
    next = idx == l.len+1 ? l.tail : getnode(l, idx)
    insertbefore!(node, next)
    return l
end

const _default_splice = []

function Base.splice!(l::L, idx::Int, ins=_default_splice) where L <: AbstractLinkedList
    @boundscheck 0 < idx <= l.len || throw(BoundsError(l, idx))
    node = getnode(l, idx)
    data = node.data
    prev = node.prev
    next = node.next
    hastarget(node) && removetarget!(node)

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
        hastarget(node) && removetarget!(node)
        node = node.next
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
    TargetKind

Trait describing how a node or list participates in cross-list `target` links —
the defining feature of this package. The kinds are [`Reciprocal`](@ref)
(two-way links), [`OneWay`](@ref) (one-way links), and [`Untargeted`](@ref) (no
links). `TargetKind(x)` reports the kind for a node or list `x`, and
[`hastarget`](@ref), [`addtarget!`](@ref), and [`removetarget!`](@ref) dispatch
on it.

A type opts into targeting by defining `TargetKind(::Type{MyType})` to return
`Reciprocal()` or `OneWay()` and providing a `target` field initialized to the
object itself; pointing `target` at the object encodes the unlinked state.

See also [`target`](@ref), [`hastarget`](@ref), [`addtarget!`](@ref),
[`removetarget!`](@ref).
"""
abstract type TargetKind end

"""
    Reciprocal <: TargetKind

Two-way target links: [`addtarget!`](@ref) and [`removetarget!`](@ref) update
both an object and its target, maintaining `x === x.target.target`.
"""
struct Reciprocal <: TargetKind end

"""
    OneWay <: TargetKind

One-way target links: [`addtarget!`](@ref) and [`removetarget!`](@ref) update
only the originating object, leaving its target unchanged.
"""
struct OneWay <: TargetKind end

"""
    Untargeted <: TargetKind

No target links: [`hastarget`](@ref) is always `false` and the targeting
mutators leave the object unchanged.
"""
struct Untargeted <: TargetKind end

TargetKind(x) = TargetKind(typeof(x))
TargetKind(::Type) = Untargeted()
TargetKind(::Type{<:Union{AbstractPairedListNode, AbstractPairedSkipNode, AbstractPairedLinkedList, AbstractPairedSkipList}}) = Reciprocal()
TargetKind(::Type{<:Union{AbstractTargetedListNode, AbstractTargetedLinkedList}}) = OneWay()

"""
    hastarget(node) -> Bool
    hastarget(list) -> Bool

Return `true` if the provided node or list currently links to a target, and
`false` otherwise.

See also [`TargetKind`](@ref), [`addtarget!`](@ref), [`removetarget!`](@ref).
"""
hastarget(x) = _hastarget(TargetKind(x), x)
_hastarget(::Untargeted, x) = false
_hastarget(::TargetKind, x) = x.target !== x

"""
    target(node) -> node_or_nothing
    target(list) -> list_or_nothing

Return the target of `node` or `list`, or `nothing` if no target is currently
linked. For [`Reciprocal`](@ref) objects (`PairedListNode`, `PairedSkipNode`,
`PairedLinkedList`, `PairedSkipList`) the link is bidirectional; for
[`OneWay`](@ref) objects (`TargetedListNode`, `TargetedLinkedList`) it is
one-directional. [`Untargeted`](@ref) objects always return `nothing`.

This is the public accessor for the cross-list link; callers should use it
rather than reading the `.target` field directly, as the unlinked state is
encoded by a self-reference which `target` hides.

See also [`TargetKind`](@ref), [`hastarget`](@ref), [`addtarget!`](@ref),
[`removetarget!`](@ref).
"""
target(x) = _target(TargetKind(x), x)
_target(::Untargeted, x) = nothing
_target(::TargetKind, x) = hastarget(x) ? x.target : nothing

# Establish (`_link!`) or clear (`_unlink!`) an object's own `target` field
# according to its `TargetKind`. A `Reciprocal` object also updates the other
# end; the unlinked state is encoded by pointing `target` at the object itself.
_link!(::Reciprocal, obj, target) = (obj.target = target; target.target = obj; obj)
_link!(::OneWay, obj, target) = (obj.target = target; obj)

_unlink!(::Untargeted, obj) = obj
_unlink!(::OneWay, obj) = (hastarget(obj) && (obj.target = obj); obj)
function _unlink!(::Reciprocal, obj)
    if hastarget(obj)
        target = obj.target
        obj.target = obj
        target.target = target
    end
    return obj
end

"""
    addtarget!(node, target_node)
    addtarget!(list, target_list)

Link the provided node or list to `target`, assigning it as the object's
`target`, and return the object.

For a [`Reciprocal`](@ref) object (such as a `PairedListNode` or
`PairedLinkedList`) the reverse link is established as well, and any prior target
of either object is removed first. For a [`OneWay`](@ref) object (such as a
`TargetedListNode` or `TargetedLinkedList`) only the object's own link is set and
`target` is left unchanged.

See also [`TargetKind`](@ref), [`hastarget`](@ref), [`removetarget!`](@ref).
"""
function addtarget!(list::L, target::L) where L <: Union{AbstractPairedLinkedList, AbstractPairedSkipList}
    hastarget(list) && removetarget!(list)
    hastarget(target) && removetarget!(target)
    return _link!(TargetKind(list), list, target)
end

function addtarget!(node::N, target::N) where N <: Union{AbstractPairedListNode, AbstractPairedSkipNode}
    node.list.target === target.list || throw(ArgumentError("The provided node must belong to paired list."))
    hastarget(node) && removetarget!(node)
    hastarget(target) && removetarget!(target)
    return _link!(TargetKind(node), node, target)
end

function addtarget!(list::AbstractTargetedLinkedList{T,R}, target::R) where {T,R}
    hastarget(list) && removetarget!(list)
    return _link!(TargetKind(list), list, target)
end

function addtarget!(node::AbstractTargetedListNode{T,N,L}, target::N) where {T,N,L}
    if hastarget(node.list)
        node.list.target === target.list || throw(ArgumentError("The provided node must belong to the list being targeted."))
    end
    hastarget(node) && removetarget!(node)
    return _link!(TargetKind(node), node, target)
end

"""
    removetarget!(node) -> node
    removetarget!(list) -> list
    removetarget!(list, idx::Int) -> node

Remove the target link of the node or list (or of the `idx`-th node of `list`)
and return the object whose link was removed. An object without a target is
returned unchanged.

For a [`Reciprocal`](@ref) object the reverse link is removed as well. Removing
a list's target also removes the target link of each of its nodes.

See also [`TargetKind`](@ref), [`hastarget`](@ref), [`addtarget!`](@ref).
"""
removetarget!(node::AbstractNode) = _unlink!(TargetKind(node), node)

function removetarget!(list::AbstractList)
    hastarget(list) || return list
    _unlink!(TargetKind(list), list)
    for node in ListNodeIterator(list)
        removetarget!(node)
    end
    return list
end

function removetarget!(list::AbstractList, idx::Int)
    return removetarget!(getnode(list, idx))
end
