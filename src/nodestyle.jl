export mapbusproperty, mapbuspropertysol
#
# struct NodeColor{T} where T <: D3Scale
#     "Keys are bus indices; values are color"
#     d::Dict
#     "Scale for mapping values to colors"
#     s::T
#
#     function nodeColor(d::Dict, s::T) where T <: D3Scale
#
# end

function mapbusproperty(pm::GenericPowerModel, buskey::String)
    p = Dict()
    for (id, busdata) in ref(pm, :bus)
        p[id] = busdata[buskey]
    end
    return p
end

function mapbuspropertysol(pm::GenericPowerModel, result, buskey::String)
    p = Dict()
    for id in ids(pm, :bus)
        p[id] = result["solution"]["bus"][string(id)][buskey]
    end
    for (id, g) in ref(pm, :gen)
        p["g"*string(id)] = p[g["gen_bus"]]
    end
    return p
end
