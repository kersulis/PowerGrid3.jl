export savegraphdata

function delimited_string(v::Vector{T};
    delimiter=", ", element_encloser=(T == String ? "'" : "")) where T

    vs = [element_encloser * string(vi) * element_encloser for vi in v]
    if length(vs) == 1
        return vs[1]
    else
        return *((vi * delimiter for vi in vs[1:(end - 1)])...) * vs[end]
    end
end

"""
Save graph data to JSON file path.
"""
function savegraphdata(path::String, gd::GraphData)
    open(path, "w") do f
        JSON.print(f, gd)
    end
end
