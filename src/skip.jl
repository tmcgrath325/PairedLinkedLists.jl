pushcache!(cache::SkipListCache, data, level) = begin
    push!(cache.data, data)
    push!(cache.levels, level)
end

pushcache!(::Nothing, data, level) = nothing

removecache!(cache::SkipListCache, node) = begin
    level = 1
    while !atbottom(node)
        node = node.down
        level += 1
    end
    pushcache!(cache, node.data, -level)
end

removecache!(::Nothing, node) = nothing

emptycache!(cache::SkipListCache) = begin
    empty!(cache.data)
    empty!(cache.levels)
end

emptycache!(::Nothing) = nothing

nodetype(::Type{<:AbstractSkipList{T, F}}) where {T, F} = SkipNode{T, SkipList{T, F}}
nodetype(::Type{<:AbstractPairedSkipList{T, F}}) where {T, F} = PairedSkipNode{T, PairedSkipList{T, F}}

attop(n::AbstractSkipNode) = n.up === n
atbottom(n::AbstractSkipNode) = n.down === n

function height(n::AbstractSkipNode)
    h = 1
    if !attop(n)
        abovenode = n.up
        h += 1
        while !attop(abovenode)
            abovenode = abovenode.up
            h += 1
        end
    end
    if !atbottom(n)
        belownode = n.down
        h += 1
        while !atbottom(belownode)
            belownode = belownode.down
            h += 1
        end
    end
    return h
end

# this function similar to insertafter!, but does not modify the length of the list, making it appropriate for skip nodes not on the bottom row.
function insertskipafter!(node::N, prev::N) where {N <: AbstractSkipNode}
    if node.list !== prev.list
        throw(ArgumentError("The nodes must have the same parent list."))
    end
    next = prev.next
    node.prev = prev
    node.next = next
    prev.next = node
    next.prev = node
    return node
end

function search(l::AbstractSkipLinkedList{T}, data::T) where {T}
    sdata = l.sortedby(data)
    rn = getfirst(x -> l.sortedby(x.data) > sdata, l.nlevels > 1 ? l.top : l.head.next)
    rn = isnothing(rn) ? l.toptail : rn
    ln = rn.prev
    for i in (l.nlevels - 1):-1:1
        ln = ln.down
        rn = rn.down
        for n in ln
            if l.sortedby(n.data) > sdata
                ln = n.prev
                rn = n
                break
            elseif n.next === rn
                ln = n
                break
            end
        end
    end
    return ln
end

function searchinsert!(l::AbstractSkipLinkedList{T}, bottomnode::AbstractSkipNode{T}, level::Int) where {T}
    data = bottomnode.data
    sdata = l.sortedby(data)
    if level > l.nlevels
        for i in (l.nlevels + 1):level
            addlevel!(l)
        end
    end
    rn = getfirst(x -> l.sortedby(x.data) > sdata, l.nlevels > 1 ? l.top : l.head.next)
    rn = isnothing(rn) ? l.toptail : rn
    ln = rn.prev
    # !(attop(rn) && attop(ln)) && throw(ErrorException("Invalid top of skip list"))

    abovenode = l.head
    if level === l.nlevels
        abovenode = level === 1 ? insertafter!(bottomnode, ln) : insertskipafter!(newnode(l, data), ln)
    end
    for lvl in (l.nlevels - 1):-1:1
        @assert !atbottom(ln)
        ln = ln.down
        rn = rn.down
        for n in ln
            if l.sortedby(n.data) > sdata
                ln = n.prev
                rn = n
                break
            elseif n.next === rn
                ln = n
                break
            end
        end
        if lvl <= level
            if ln.list !== l
                throw(ErrorException("ln should belong to the list"))
            end
            node = lvl === 1 ? insertafter!(bottomnode, ln) : insertskipafter!(newnode(l, data), ln)
            if abovenode !== l.head
                node.up = abovenode
                abovenode.down = node
            end
            abovenode = node
        end
    end
    pushcache!(l.cache, data, level)
    return ln
end

# add a new row to the top of the skip list
function addlevel!(l::AbstractSkipLinkedList)
    l.nlevels += 1
    top = newnode(l, l.top.data)
    top.down = l.nlevels === 2 ? head(l) : l.top
    l.top.up = top
    toptail = nodetype(l)(l)
    toptail.down = l.toptail
    l.toptail.up = toptail
    top.next = toptail
    toptail.prev = top
    l.top = top
    l.toptail = toptail
    return l
end

# removelevel! and trimlevels! are not currently called by any other function.
# They may be useful in the future for maintaining a reasonable list height
# when many nodes have been deleted.
#
# function removelevel!(l::AbstractSkipLinkedList)
#     l.nlevels <= 1 && throw(ErrorException("Cannot remove the only level of a skip list"))
#     for n in ListNodeIterator(l.top.next)
#         n.down.top = n.down
#     end
#     l.top = l.top.down
#     l.top.up = l.top
#     l.toptail = l.toptail.down
#     l.toptail.up = l.toptail
#     l.nlevels -= 1
# end
#
# function trimlevels!(l::AbstractSkipLinkedList)
#     while l.nlevels > 1 && l.top.next === l.toptail
#         l.top = l.top.down
#         l.top.up = l.top
#         l.toptail = l.toptail.down
#         l.toptail.up = l.toptail
#         l.nlevels -= 1
#     end
# end

# generate a random level at which to insert a new node
function randomlevel(max::Int, skipfactor::Int)
    level = 1
    for i in 2:max
        rand() > 1 / skipfactor && break
        level += 1
    end
    return level
end

Base.push!(l::AbstractSkipLinkedList{T}, data) where {T} = pushskip!(l, data)
Base.push!(l::AbstractSkipLinkedList{T}, node::AbstractSkipNode{T}) where {T} = pushskip!(l, node)

pushskip!(l::AbstractSkipLinkedList{T}, data, level::Int = randomlevel(l.nlevels, l.skipfactor)) where {T} = pushskip!(l, newnode(l, data), level)

function pushskip!(l::AbstractSkipLinkedList{T}, bottomnode::AbstractSkipNode{T}, level::Int = randomlevel(l.nlevels, l.skipfactor)) where {T}
    bottomnode.list === l || throw(ArgumentError("The provided node does not belong to the list."))
    bottomnode.down = bottomnode
    bottomnode.up = bottomnode
    data = bottomnode.data
    sdata = l.sortedby(data)
    if (level > l.nlevels) && l.len > 0
        for i in (l.nlevels + 1):level
            addlevel!(l)
        end
    end
    if l.len === 0
        @assert l.nlevels === 1
        pushcache!(l.cache, bottomnode.data, 1)
        insertafter!(bottomnode, l.head)
        l.top = bottomnode
        return l
    elseif sdata < l.sortedby(first(l))
        pushcache!(l.cache, bottomnode.data, l.nlevels)
        insertafter!(bottomnode, l.head)
        if l.nlevels === 1
            l.top = bottomnode
        else
            node = l.top
            for i in 1:(l.nlevels - 1)
                node.data = data
                node = node.down
            end
            node.up.down = bottomnode
            bottomnode.up = node.up
            node.up = node
        end
        return l
    else
        searchinsert!(l, bottomnode, level)
    end
    (l.len > l.skipfactor^l.nlevels) && addlevel!(l)
    return l
end

"""
    deletenode!(node::SkipNode)

Remove `node` from the list to which it belongs, update the list's length, and return the node.

The node can be at any level of the skip list, and all nodes directly above or below will also be removed.
"""
function deletenode!(node::AbstractSkipNode)
    l = node.list
    hastarget(node) && removetarget!(node.target)
    # handle deletion of the first node in the bottom list
    if node === head(l)
        pushcache!(l.cache, node.data, -l.nlevels)
        # remove the provided node
        next = node.next
        prev = node.prev
        prev.next = next
        next.prev = prev
        l.len -= 1
        if l.len === 0                  # if the list is now empty, reset the top and toptail nodes
            l.top = l.head
            l.toptail = l.tail
            l.tail.up = l.tail
            l.nlevels = 1
        elseif l.nlevels === 1          # if there is only a single level, all that remains is to update the "top"
            l.top = l.len === 0 ? l.head : head(l)
        else                            # otherwise, adjust the first node for each level
            oldlevelhead = node
            currentnode = next
            prevnode = next
            for i in 2:l.nlevels
                @assert !attop(oldlevelhead)
                oldlevelhead = oldlevelhead.up
                if attop(currentnode)               # if the node from the previous level has no node above, use the node at the head of the level
                    currentnode = oldlevelhead
                    currentnode.down = prevnode
                    prevnode.up = currentnode
                else                                # if the node from the previous level already has a node above, make it the head of the level
                    currentnode = currentnode.up
                    currentnode.prev = currentnode
                end
                currentnode.data = next.data
                prevnode = currentnode
            end
            l.top = currentnode
        end
        return node
    end

    # handle deletion of any other node
    if athead(node) && !atbottom(node)
        return deletenode!(node.down)
    elseif !attop(node)
        deletenode!(node.up)
    else
        removecache!(l.cache, node)
    end
    prev = node.prev
    next = node.next
    prev.next = next
    next.prev = prev
    if atbottom(node)
        node.list.len -= 1
    end
    return node
end

function Base.empty!(l::AbstractSkipLinkedList)
    if hastarget(l)
        # remove all of the inter-list links
        target = l.target
        removetarget!(l)
        addtarget!(l, target)
    end

    emptycache!(l.cache)

    l.head.next = l.tail
    l.tail.prev = l.head
    l.tail.up = l.tail
    l.top = l.head
    l.toptail = l.tail
    l.len = 0
    l.nlevels = 1
    return l
end

"""
    copyfromcache(l::AbstractSkipLinkedList)

Returns a copy of a skip list created from its cache. This adds and removes entries in the same order as had been previously done in original list.
"""
function copyfromcache(l::L) where {T, F, L <: AbstractSkipLinkedList{T, F}}
    @assert !isnothing(l.cache)
    return copyfromcache(L, l.cache; skipfactor = l.skipfactor, sortedby = l.sortedby)
end

"""
    copyfromcache(c::SkipListCache)

Returns a skip list created from a SkipListCache. This adds and removes entries as speficied by the cache.
"""
function copyfromcache(L::Type{<:AbstractSkipLinkedList{T, F}}, cache::SkipListCache{T}; skipfactor::Int = 2, sortedby::F = identity) where {T, F}
    lcopy = L(skipfactor, sortedby)
    lcopy.cache = SkipListCache{T}()
    for (data, level) in zip(cache.data, cache.levels)
        if level < 0
            node_to_delete = lcopy.head.next
            while !(node_to_delete.data == data && height(node_to_delete) == -level)
                node_to_delete = node_to_delete.next
                if attail(node_to_delete)
                    throw(ErrorException("Node not found: $(data), $(level)"))
                end
            end
            @assert atbottom(node_to_delete)
            deletenode!(node_to_delete)
        else
            pushskip!(lcopy, data, level)
        end
    end
    return lcopy
end

"""
    skiplistsidentical(l1::AbstractSkipLinkedList, l2::AbstractSkipLinkedList)

Returns true if the two skip lists are identical, false otherwise. 
    
The lists are considered identical if the values of their nodes are the same at each "level" of the list.
Because nodes are typically added at a random level, two skip lists constructed from the same data will generally not be identical unless generated using `copyfromcache`.

See also [`copyfromcache`](@ref)
"""
function skiplistsidentical(l1::AbstractSkipLinkedList, l2::AbstractSkipLinkedList)
    if (l1.len != l2.len) || (l1.nlevels != l2.nlevels)
        return false
    end
    h1 = l1.top
    h2 = l2.top
    level = l1.nlevels
    while level > 0
        for (n1, n2) in zip(ListNodeIterator(h1), ListNodeIterator(h2))
            if athead(n1) && athead(n2)
                continue
            end
            if attail(n1) && attail(n2)
                break
            end
            if n1.data != n2.data
                return false
            end
        end
        h1 = h1.down
        h2 = h2.down
        level -= 1
    end
    return true
end
