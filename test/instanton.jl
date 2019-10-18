using Revise, PowerGrid3, PowerModels, TemporalInstanton

casepath = joinpath("/home/jk/jdocuments/projects/sdp-opf-decomp/pglib-opf", "pglib_opf_case118_ieee.m")

# casepath = joinpath("/home/jk/jdocuments/projects/sdp-opf-decomp/pglib-opf", "pglib_opf_case240_pserc.m")
# casepath = joinpath(@__DIR__, "data", "pglib_opf_case14_ieee.m")
# casepath = joinpath("/home/jk/jdocuments/projects/sdp-opf-decomp/pglib-opf", "pglib_opf_case30_ieee.m")
# casepath = joinpath("/home/jk/jdocuments/projects/sdp-opf-decomp/pglib-opf", "pglib_opf_case300_ieee.m")

nd = PowerModels.parse_file(casepath)
gd = GraphData(nd)
i = build_instanton_input(casepath)
conventional_to_renewable!(i)
set_temperatures!(i; Tamb=40.0, T0=90.0)

# one hour in ten-minute intervals
# set_timing!(i; time_values=0:600:3600)

# nominal injections and loads
Gp, Dp, Rp = i.G0, i.D0, i.R0
Gp = Gp ./ sum(Gp)
Dp = Dp ./ sum(Dp)
Rp = Rp ./ sum(Rp)

# just one time step
set_timing!(i; time_values=0:600:600)
G0 = 1.0 * Gp
D0 = 1.0 * Dp
R0 = 1.0 * Rp

set_injections!(i; G0=G0, D0=D0, R0=R0)

o = solve_temporal_instanton(i)


o.score

## use opt. score to color lines
min_score, max_score = extrema([s[1] for s in o.score if s[1] < Inf])

score = Dict{Tuple, Float64}()
for d in getlinks(gd.links)
    score[(d["source"], d["target"])] = max_score * 2
end

# why are lines duplicated in IEEE 118 data???
unique([(d["f_bus"], d["t_bus"]) for d in values(nd["branch"])])

# lack of unique-ness is messing this up:
unique([d["id"] for d in getlinks(gd.links)])

for (s, idx) in o.score
    line = i.lines[idx]
    id = string.(line)
    if s == Inf
        score[id] = max_score
    else
        score[id] = s
    end
end

# set lower and upper extrema to red and black, resp.
domain = [min_score, min_score * 1.5, max_score]
edgeColor = ContinuousScale(:Linear, domain, ["red", "#666", "black"])
# edgeColor = ContinuousScale(score, ["red", "black"])

setlinkproperty!(gd, "color", score)

## use generator type to color nodes
all_nodes = [d["id"] for d in getnodes(gd.nodes)]
# "g40" in all_nodes
sridx = string.(i.Ridx)

gen_type = Dict{String, String}()
for bus_idx in all_nodes
    if bus_idx[1] == 'g'
        if bus_idx[2:end] in sridx
            # is renewable
            gen_type[bus_idx] = "renewable"
        else
            # is conventional
            gen_type[bus_idx] = "conventional"
        end
    else
        gen_type[bus_idx] = "none"
    end
end

# "renewable" in values(gen_type)
setnodeproperty!(gd, "color", gen_type)

nodeColor = OrdinalScale(["conventional", "none", "renewable"], ["blue", "#444", "red"])

# save viz code

jsonpath = joinpath(@__DIR__, "temp", "graphdata.json")
savegraphdata(jsonpath, gd)

htmlpath = joinpath(@__DIR__, "temp", "index.html")
savehtml(htmlpath; edgeColor=edgeColor, nodeColor=nodeColor)



## Use load to color nodes
demand = Dict{String, Float64}()
for d in values(nd["load"])
    demand[string(d["load_bus"])] = d["pd"]
end

all_nodes = [b["id"] for b in values(getnodes(gd.nodes))]
for bus in all_nodes
    if !haskey(demand, bus)
        demand[bus] = -1.0
    end
end

setnodeproperty!(gd, "color", demand)
nodeColor = ContinuousScale([-1, 0, maximum(values(demand)) * 0.4], ["black", "blue", "red"])

# save viz code
jsonpath = joinpath(@__DIR__, "temp", "graphdata.json")
savegraphdata(jsonpath, gd)

htmlpath = joinpath(@__DIR__, "temp", "index.html")
savehtml(htmlpath; nodeColor=nodeColor)
