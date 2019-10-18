using PowerGrid3, PowerModels, Ipopt

casepath = joinpath(@__DIR__, "data", "pglib_opf_case14_ieee.m")

using PowerModels: build_model, optimize_model!
pm = build_model(casepath, ACPPowerModel, PowerModels.post_opf)

optimizer = Ipopt.Optimizer()
result = optimize_model!(pm, with_optimizer(Ipopt.Optimizer, print_level=0))

##

gd = GraphData(pm)

# dictionary with bus_id keys and vmag values
vmag = mapbuspropertysol(pm, result, "vm")

# encode vmag as color in JSON data
setnodeproperty!(gd, "color", vmag)

# set lower and upper extrema to blue and red, resp.
nodeColor = ContinuousScale(vmag, ["blue", "red"])

##
try
    mkdir(joinpath(@__DIR__, "temp"))
catch
    @warn "Folder exists"
end

jsonpath = joinpath(@__DIR__, "temp", "graphdata.json")
savegraphdata(jsonpath, gd)

htmlpath = joinpath(@__DIR__, "temp", "index.html")
savehtml(htmlpath; nodeColor=nodeColor, svg_width=1000, svg_height=700)
