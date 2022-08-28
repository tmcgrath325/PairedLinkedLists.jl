nodetype(::Type{<:AbstractSkipList{T,F}}) where {T,F} = SkipNode{T,SkipList{T,F}}
nodetype(::Type{<:AbstractPairedSkipList{T,F}}) where {T,F} = PairedSkipNode{T,PairedSkipList{T,F}}

attop(n::AbstractSkipNode) = n.up === n
atbottom(n::AbstractSkipNode) = n.down === n

function SkipList{T}(elts...; sortedby::F=identity, skipfactor::Int=2) where {T,F}
    l = SkipList{T}(;sortedby=sortedby, skipfactor=skipfactor)
    nlevels = Int(ceil(log(skipfactor, max(length(elts),skipfactor))))
    l.nlevels = nlevels

    sortedelts = sort(T[elts...]; by=sortedby)
    left = insertafter!(newnode(l, first(sortedelts)), l.head)
    right = l.tail
    currentnodes = [left]
    for i=2:nlevels
        aboveleft = newnode(l, first(sortedelts))
        left.up = aboveleft
        aboveleft.down = left

        aboveright = SkipNode{T,SkipList{T,F}}(l)
        right.up = aboveright
        aboveright.down = right

        left = aboveleft
        right = aboveright
        left.next = right
        right.prev = left

        push!(currentnodes, left)
    end
    l.top = left
    l.toptail = right

    spacings = [skipfactor^x for x in 0:nlevels-1]
    for i=2:length(sortedelts)
        for j=1:nlevels
            if j === 1 
                currentnodes[j] = insertafter!(newnode(l,sortedelts[i]), currentnodes[j])
            elseif i % spacings[j] === 1
                currentnodes[j] = insertskipafter!(newnode(l,sortedelts[i]), currentnodes[j])
                currentnodes[j].down = currentnodes[j-1]
                currentnodes[j-1].up = currentnodes[j]
            else
                break
            end
        end
    end
    return l
end

function search(l::AbstractSkipLinkedList{T}, data::T) where T
    sdata = l.sortedby(data)
    left = Vector{nodetype(l)}(undef, l.nlevels)
    rn = getfirst(x -> l.sortedby(x.data) > sdata, l.top)
    rn = isnothing(rn) ? l.toptail : rn
    ln = rn.prev
    left[end] = ln
    for level = l.nlevels-1:-1:1
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
        left[level] = ln
    end
    return left
end

# this function similar to insertafter!, but does not modify the length of the list, making it appropriate for skip nodes not on the bottom row.
function insertskipafter!(node::N, prev::N) where N <: AbstractSkipNode
    node.list === prev.list || throw(ArgumentError("The nodes must have the same parent list."))
    next = prev.next
    node.prev = prev
    node.next = next
    prev.next = node
    next.prev = node
    return node
end

function Base.push!(l::AbstractSkipLinkedList{T}, data::T) where T
    left = search(l, data)
    bottomnode = insertafter!(newnode(l,data), left[1])
    if left[1] === l.head
        if l.nlevels === 1
           l.top = bottomnode 
        else
            node = l.top
            for i=1:l.nlevels-1
                node.data = data
                node = node.down
            end
            node.up.down = bottomnode
            bottomnode.up = node.up 
            node.up = node
        end
        return l
    elseif l.len > l.skipfactor ^ l.nlevels
        l.nlevels += 1
        top = newnode(l, l.top.data)
        top.down = l.top
        l.top.up = top
        toptail = nodetype(l)(l)
        toptail.down = l.toptail
        l.toptail.up = toptail
        top.next = toptail
        toptail.prev = top
        l.top = top
        l.toptail = toptail
    end
    for i=2:length(left)
        rand() > 1 / l.skipfactor && break 
        node = insertskipafter!(newnode(l,data), left[i])
        node.down = bottomnode
        bottomnode.up = node
        bottomnode = node
    end
    return l
end

"""
    deletenode!(node::SkipNode)

Remove `node` from the list to which it belongs, update the list's length, and return the node.

The node can be at any level of the skip list, and all nodes directly above or below will also be removed.
"""
function deletenode!(node::AbstractSkipNode)
    if !attop(node)
        deletenode!(node.up)
    elseif athead(node)
        if node.next == node.list.toptail
            if atbottom(node)
                node.list.top = node.list.head
            else
                node.down.up = node.down
                node.toptail = node.toptail.down
                node.toptail.up = node.toptail
                node.list.nlevels -= 1
            end
        else
            node.list.top = node.next
        end
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
function deletenode!(node::PairedSkipNode)
    if !attop(node)
        deletenode!(node.up)
    elseif athead(node)
        if node.next == node.list.toptail
            if atbottom(node)
                node.list.top = node.list.head
            else
                node.down.up = node.down
                node.toptail = node.toptail.down
                node.toptail.up = node.toptail
                node.list.nlevels -= 1
            end
        else
            node.list.top = node.next
        end
    end
    prev = node.prev
    next = node.next
    prev.next = next
    next.prev = prev
    if atbottom(node) 
        node.list.len -= 1
    end
    hastarget(node) && removetarget!(node)
    return node
end


function Base.pop!(l::AbstractSkipList)
    isempty(l) && throw(ArgumentError("List must be non-empty"))
    node = tail(l)
    data = node.data
    deletenode!(node)
    return data
end

function Base.popfirst!(l::AbstractSkipList)
    isempty(l) && throw(ArgumentError("List must be non-empty"))
    node = head(l)
    deletenode!(node)
    return node.data
end

