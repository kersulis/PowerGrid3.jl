using PowerGrid3, PowerModels, Ipopt

casepath = joinpath(@__DIR__, "data", "pglib_opf_case14_ieee.m")

pm = build_generic_model(casepath, ACPPowerModel, PowerModels.post_opf)

solver = IpoptSolver()
result = solve_generic_model(pm, solver)

##

gd = GraphData(pm)

# dictionary with bus_id keys and vmag values
vmag = mapbuspropertysol(pm, result, "vm")

# encode vmag as color in JSON data
setnodeproperty!(gd, "color", vmag)

# set lower and upper extrema to blue and red, resp.
nodeColor = ContinuousScale(vmag, ["blue", "red"])

mkdir(joinpath(@__DIR__, "temp"))

jsonpath = joinpath(@__DIR__, "temp", "graphdata.json")
savegraphdata(jsonpath, gd)

htmlpath = joinpath(@__DIR__, "temp", "index.html")
savehtml(htmlpath, nodeColor=nodeColor)
