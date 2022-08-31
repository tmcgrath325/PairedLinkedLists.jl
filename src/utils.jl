# returns the first element of the iterator that satisfies the predicate
function getfirst(p, itr)
    for el in itr
        p(el) && return el
    end
    return nothing
end