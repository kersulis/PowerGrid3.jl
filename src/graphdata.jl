export GraphNodes, GraphLinks, GraphData,
        getnodes, getlinks,
        setnodeproperty!, setlinkproperty!

struct GraphNodes
    nodes::Vector{Dict{String, Any}}

    "Constructor for PowerModels generic power model type"
    function GraphNodes(pm::AbstractPowerModel)
        b = ref(pm, :bus)
        busnodes = [Dict{String, Any}("id" => string(k), "size" => "bus") for k in keys(b)]
        g = ref(pm, :gen)
        gennodes = [Dict{String, Any}("id" => "g" * string(k), "size" => "gen") for k in keys(g)]
        new([busnodes; gennodes])
    end

    "Constructor for PowerModels network data dict format"
    function GraphNodes(nd::Dict{String, Any})
        @assert haskey(nd, "baseMVA") "Input must be PowerModels network data dict"
        b = nd["bus"]
        busnodes = [Dict{String, Any}("id" => string(d["bus_i"]), "size" => "bus") for d in values(b)]
        g = nd["gen"]
        gennodes = [Dict{String, Any}("id" => "g" * string(k), "size" => "gen") for k in keys(g)]
        new([busnodes; gennodes])
    end

end
getnodes(gn::GraphNodes) = gn.nodes
Base.length(gn::GraphNodes) = length(getnodes(gn))

struct GraphLinks
    links::Vector{Dict{String, Any}}

    "Constructor for PowerModels generic power model type"
    function GraphLinks(pm::AbstractPowerModel)
        bp = ref(pm, :buspairs)

        buslinks = Dict{String, Any}[]
        for k in keys(bp)
            src, tgt = string.(k)
            push!(
                buslinks, Dict{String, Any}(
                    "id" => (src, tgt),
                    "source" => src,
                    "target" => tgt
                )
            )
        end

        genlinks = Dict{String, Any}[]
        for (gid, g) in ref(pm, :gen)
            src, tgt = string(g["gen_bus"]), "g" * string(gid)
            push!(
                genlinks, Dict{String, Any}(
                    "id" => (src, tgt),
                    "source" => src,
                    "target" => tgt
                )
            )
        end
        new([buslinks; genlinks])
    end

    "Constructor for PowerModels network data dict format"
    function GraphLinks(nd::Dict{String, Any})
        @assert haskey(nd, "baseMVA") "Input must be PowerModels network data dict"
        b = nd["branch"]

        buslinks = Dict{String, Any}[]
        for v in values(b)
            src, tgt = string(v["f_bus"]), string(v["t_bus"])
            push!(
                buslinks, Dict{String, Any}(
                    "id" => (src, tgt),
                    "source" => src,
                    "target" => tgt
                )
            )
        end

        genlinks = Dict{String, Any}[]
        for (k, v) in nd["gen"]
            src, tgt = string(v["gen_bus"]), "g" * string(k)
            push!(
                genlinks, Dict{String, Any}(
                    "id" => (src, tgt),
                    "source" => src,
                    "target" => tgt
                )
            )
        end
        new([buslinks; genlinks])
    end
end
getlinks(gl::GraphLinks) = gl.links
Base.length(gl::GraphLinks) = length(getlinks(gl))

struct GraphData
    nodes::GraphNodes
    links::GraphLinks
end

GraphData(pm::AbstractPowerModel) = GraphData(GraphNodes(pm), GraphLinks(pm))

function GraphData(nd::Dict{String, Any})
    @assert haskey(nd, "baseMVA") "Input must be PowerModels network data dict"
    return GraphData(GraphNodes(nd), GraphLinks(nd))
end

JSON.print(io::IO, gd::GraphData) = JSON.print(io, Dict("nodes" => getnodes(gd.nodes), "links" => getlinks(gd.links)))

function setnodeproperty!(gn::GraphNodes, propertyname::String, values::Dict)
    if length(values) != length(gn)
        error("Expected $(length(gn)) key/value pairs, got $(length(values))")
    end

    for node in getnodes(gn)
        node[propertyname] = values[node["id"]]
    end
    return
end
setnodeproperty!(gd::GraphData, propertyname::String, values::Dict) = setnodeproperty!(gd.nodes, propertyname, values)

function setlinkproperty!(gl::GraphLinks, propertyname::String, values::Dict)
    unique_links = unique([d["id"] for d in getlinks(gl)])
    if length(values) != length(unique_links)
        error("Expected $(length(unique_links)) key/value pairs, got $(length(values))")
    end

    for link in getlinks(gl)
        link[propertyname] = values[(link["source"], link["target"])]
    end
    return
end
setlinkproperty!(gd::GraphData, propertyname::String, values::Dict) = setlinkproperty!(gd.links, propertyname, values)
