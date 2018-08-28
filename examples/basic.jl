using PowerGrid3, PowerModels, Ipopt

casepath = joinpath(Pkg.dir("PowerGrid3"), "test", "data", "pglib_opf_case14_ieee.m")

pm = build_generic_model(casepath, ACPPowerModel, PowerModels.post_opf)

Pkg.build("Ipopt")
solver = IpoptSolver()
result = solve_generic_model(pm, solver)

##

gd = GraphData(pm)

# dictionary with bus_id keys and vmag values
vmag = mapbuspropertysol(pm, result, "vm")

# encode vmin as color in JSON data
setnodeproperty!(gd, "color", vmag)

# set lower and upper extrema to blue and red, resp.
nodeColor = ContinuousScale(vmag, ["blue", "red"])

jsonpath = joinpath(Pkg.dir("PowerGrid3"), "html", "graphdata.json")
savegraphdata(jsonpath, gd)

htmlpath = joinpath(Pkg.dir("PowerGrid3"), "html", "index.html")
savehtml(htmlpath, nodeColor=nodeColor)
