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

"""
Return a dictionary assigning to each bus the value of a specified bus
property. Valid properties are determined by PowerModels:

- zone
- bus_i
- bus_type
- vmax
- area
- vmin
- index
- va
- vm
- base_kv
"""
function mapbusproperty(pm::GenericPowerModel, buskey::String)
    p = Dict()
    for (id, busdata) in ref(pm, :bus)
        p[id] = busdata[buskey]
    end
    for (id, g) in ref(pm, :gen)
        p["g" * string(id)] = p[g["gen_bus"]]
    end
    return p
end

function mapbusproperty(nd::Dict{String, Any}, buskey::String)
    p = Dict()
    for (id, busdata) in nd["bus"]
        p[id] = busdata[buskey]
    end
    for (id, g) in nd["gen"]
        p["g" * string(id)] = p[string(g["gen_bus"])]
    end
    return p
end

function mapbuspropertysol(pm::GenericPowerModel, result, buskey::String)
    p = Dict()
    for id in ids(pm, :bus)
        p[id] = result["solution"]["bus"][string(id)][buskey]
    end
    for (id, g) in ref(pm, :gen)
        p["g" * string(id)] = p[g["gen_bus"]]
    end
    return p
end
