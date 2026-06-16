function getfirst(p, itr)
    for el in itr
        p(el) && return el
    end
    return nothing
end
