using Base.Test
using PowerGrid3, PowerModels
import PowerGrid3: delimited_string

casepath = joinpath(Pkg.dir("PowerGrid3"), "test", "data", "pglib_opf_case14_ieee.m")

pm = build_generic_model(casepath, ACPPowerModel, PowerModels.post_opf)

##

@testset "ContinuousScale" begin
    try
        l = ContinuousScale("test", :BadValue, [], [])
    catch err
        @test err isa ErrorException
    end

    testdomain = [-1, 0, 1]
    testrange = ["blue", "beige", "red"]
    l = ContinuousScale("test", testdomain, testrange)

    @test getscalekind(l) == :Linear
    @test getdomain(l) == testdomain
    @test getrange(l) == testrange

    @test delimited_string(getdomain(l)) == "-1, 0, 1"
    @test delimited_string(getrange(l)) == "'blue', 'beige', 'red'"

    @test string(l) == """
                    var test = d3.scaleLinear()
                      .domain([-1, 0, 1])
                      .range(['blue', 'beige', 'red'])
                    """
end

@testset "OrdinalScale" begin
    try
        o = OrdinalScale("test", [], ["blue"])
    catch err
        @test err isa ErrorException
    end

    o = OrdinalScale("test", [1], ["blue"])
    @test getdomain(o) == [1]
    @test getrange(o) == ["blue"]

    @test delimited_string(getdomain(o)) == "1"

    @test string(o) == """
                var test = d3.scaleOrdinal()
                  .domain([1])
                  .range(['blue'])
                """
end

@testset "GraphNodes" begin
    gn = GraphNodes(pm)

    @test getnodes(gn)[2]["id"] == 11

    testprop = Dict{Int64, String}()
    for k in keys(ref(pm, :bus))
        testprop[k] = string(k)*" test"
    end

    setnodeproperty!(gn, "testprop", testprop)

    id = getnodes(gn)[4]["id"]
    @test getnodes(gn)[4]["testprop"] == "$id test"
end

@testset "GraphLinks" begin
    gl = GraphLinks(pm)
    @test getlinks(gl)[end]["source"] == 3

    testprop = Dict{Tuple, String}()
    for k in keys(ref(pm, :buspairs))
        testprop[k] = string(k)*" test"
    end

    setlinkproperty!(gl, "testprop", testprop)

    l = getlinks(gl)[5]
    bp = (l["source"], l["target"])
    @test getlinks(gl)[5]["testprop"] == "$bp test"
end

@testset "GraphData" begin
    gl, gn = GraphLinks(pm), GraphNodes(pm)
    gd = GraphData(gn, gl)
    @test gl == gd.links
    @test gn == gd.nodes

    testpath = joinpath(Pkg.dir("PowerGrid3"), "test", "data", "test.json")
    open(testpath, "w") do f
        JSON.print(f, gd)
    end

    @test readlines(testpath)[1][100:110] == "5},{\"id\":13"

    rm(testpath)

    open(testpath, "w") do f
        JSON.print(f, GraphData(pm))
    end

    @test readlines(testpath)[1][100:110] == "5},{\"id\":13"

    rm(testpath)

    gd = GraphData(pm)
    testprop = Dict{Int64, String}()
    for k in keys(ref(pm, :bus))
        testprop[k] = string(k)*" test"
    end
    setnodeproperty!(gd, "testprop", testprop)

    getnodes(gd.nodes)[1]["testprop"] == "2 test"
end
