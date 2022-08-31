nodetype(::Type{<:AbstractSkipList{T,F}}) where {T,F} = SkipNode{T,SkipList{T,F}}
nodetype(::Type{<:AbstractPairedSkipList{T,F}}) where {T,F} = PairedSkipNode{T,PairedSkipList{T,F}}

attop(n::AbstractSkipNode) = n.up === n
atbottom(n::AbstractSkipNode) = n.down === n

# function SkipList{T}(elts...; sortedby::F=identity, skipfactor::Int=2) where {T,F}
#     l = SkipList{T,F}(skipfactor, sortedby)
#     length(elts) === 0 && return l
#     nlevels = Int(ceil(log(skipfactor, max(length(elts),skipfactor))))
#     l.nlevels = nlevels

#     sortedelts = sort(T[elts...]; by=sortedby)
#     left = insertafter!(newnode(l, first(sortedelts)), l.head)
#     right = l.tail
#     currentnodes = [left]
#     for i=2:nlevels
#         aboveleft = newnode(l, first(sortedelts))
#         left.up = aboveleft
#         aboveleft.down = left

#         aboveright = SkipNode{T,SkipList{T,F}}(l)
#         right.up = aboveright
#         aboveright.down = right

#         left = aboveleft
#         right = aboveright
#         left.next = right
#         right.prev = left

#         push!(currentnodes, left)
#     end
#     l.top = left
#     l.toptail = right

#     spacings = [skipfactor^x for x in 0:nlevels-1]
#     for i=2:length(sortedelts)
#         for j=1:nlevels
#             if j === 1 
#                 currentnodes[j] = insertafter!(newnode(l,sortedelts[i]), currentnodes[j])
#             elseif i % spacings[j] === 1
#                 currentnodes[j] = insertskipafter!(newnode(l,sortedelts[i]), currentnodes[j])
#                 currentnodes[j].down = currentnodes[j-1]
#                 currentnodes[j-1].up = currentnodes[j]
#             else
#                 break
#             end
#         end
#     end
#     return l
# end    

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

function search(l::AbstractSkipLinkedList{T}, data::T) where T
    sdata = l.sortedby(data)
    rn = getfirst(x -> l.sortedby(x.data) > sdata, l.top)
    rn = isnothing(rn) ? l.toptail : rn
    ln = rn.prev
    for i = l.nlevels-1:-1:1
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

function searchinsert!(l::AbstractSkipLinkedList{T}, bottomnode::AbstractSkipNode{T}, level::Int) where T
    data = bottomnode.data
    sdata = l.sortedby(data)
    rn = getfirst(x -> l.sortedby(x.data) > sdata, l.nlevels > 1 ? l.top : l.head.next)
    rn = isnothing(rn) ? l.toptail : rn
    ln = rn.prev
    abovenode = l.head
    if level === l.nlevels 
        abovenode = level === 1 ? insertafter!(bottomnode, ln) : insertskipafter!(newnode(l,data), ln)
    end
    for lvl = l.nlevels-1:-1:1
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
            node = lvl === 1 ? insertafter!(bottomnode, ln) : insertskipafter!(newnode(l,data), ln)
            if abovenode !== l.head 
                node.up = abovenode
                abovenode.down = node
            end
            abovenode = node
        end
    end
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

# generate a random level at which to insert a new node
function randomlevel(max::Int, skipfactor::Int)
    level = 1
    for i=2:max
        rand() > 1 / skipfactor && break 
        level += 1
    end
    return level
end

Base.push!(l::AbstractSkipLinkedList{T}, data) where T = push!(l, newnode(l,data))

function Base.push!(l::AbstractSkipLinkedList{T}, bottomnode::AbstractSkipNode{T}) where T
    data = bottomnode.data
    sdata = l.sortedby(data)
    if l.len === 0
        insertafter!(bottomnode, l.head)
        l.top = head(l)
        return l
    elseif sdata < l.sortedby(first(l))
        insertafter!(bottomnode, l.head)
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
    else
        (l.len > l.skipfactor ^ l.nlevels) && addlevel!(l)
        searchinsert!(l, bottomnode, randomlevel(l.nlevels, l.skipfactor))
    end
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
        # remove the provided node
        next = node.next
        prev = node.prev
        prev.next = next
        next.prev = prev
        l.len -= 1
        if l.nlevels === 1              # if there is only a single level, all that remains is to update the "top"
            l.top = l.len === 0 ? l.head : head(l)             
        else                            # otherwise, adjust the first node for each level
            oldlevelhead = node
            currentnode = next
            prevnode = next
            for i=2:l.nlevels
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
    if !attop(node)
        deletenode!(node.up)
    elseif athead(node)
        if node.next == node.list.toptail
            if atbottom(node)
                node.list.top = node.list.head
            else # remove an entire level
                node.list.top = node.down
                node.list.top.up = node.list.top
                node.list.toptail = node.list.toptail.down
                node.list.toptail.up = node.list.toptail
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

function Base.empty!(l::AbstractSkipLinkedList)
    if hastarget(l)
        # remove all of the inter-list links
        target = l.target
        removetarget!(l)
        addtarget!(l, target)
    end
    
    l.head.next = l.tail
    l.tail.prev = l.head
    l.tail.up = l.tail
    l.top = l.head
    l.toptail = l.tail
    l.len = 0
    l.nlevels = 1
    return l
end
