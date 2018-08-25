export GraphNodes, GraphLinks, GraphData,
        getnodes, getlinks,
        setnodeproperty!, setlinkproperty!

struct GraphNodes
    nodes::Vector{Dict{String, Any}}

    function GraphNodes(pm::GenericPowerModel)
        b = ref(pm, :bus)
        nodes = [Dict{String, Any}("id" => k) for k in keys(b)]
        new(nodes)
    end
end
getnodes(gn::GraphNodes) = gn.nodes
Base.length(gn::GraphNodes) = length(getnodes(gn))

struct GraphLinks
    links::Vector{Dict{String, Any}}

    function GraphLinks(pm::GenericPowerModel)
        bp = ref(pm, :buspairs)
        links = [Dict{String, Any}("source" => k[1], "target" => k[2]) for k in keys(bp)]
        new(links)
    end
end
getlinks(gl::GraphLinks) = gl.links
Base.length(gl::GraphLinks) = length(getlinks(gl))

struct GraphData
    nodes::GraphNodes
    links::GraphLinks
end
GraphData(pm::GenericPowerModel) = GraphData(GraphNodes(pm), GraphLinks(pm))

JSON.print(io::IO, gd::GraphData) = JSON.print(io, Dict("nodes" => getnodes(gd.nodes), "links" => getlinks(gd.links)))

Base.string(gd::GraphData) = JSON.print(gn)

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
    if length(values) != length(gl)
        error("Expected $(length(gn)) key/value pairs, got $(length(values))")
    end

    for link in getlinks(gl)
        link[propertyname] = values[(link["source"], link["target"])]
    end
    return
end
setlinkproperty!(gd::GraphData, propertyname::String, values::Dict) = setlinkproperty!(gd.links, propertyname, values)
