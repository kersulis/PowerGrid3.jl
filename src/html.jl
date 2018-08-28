export savehtml

const header = """
<!DOCTYPE html>
<meta charset="utf-8">
"""

function css(edge_stroke::String="#aaa",
            node_stroke::String="none",
            node_stroke_width::String="40px")
    return """
    <style>

    .link line {
      stroke: $edge_stroke;
    }

    .node circle {
      pointer-events: all;
      stroke: $node_stroke;
      stroke-width: $node_stroke_width;
    }

    </style>
    """
end

"""
    svg(width, height)
returns an SVG tag with the specified width and height.
"""
function svg(width::Int64=960, height::Int64=600)
    return """
    <svg width="$width" height="$height"></svg>
    """
end

const d3 = """
<script src="https://d3js.org/d3.v4.min.js"></script>
"""

function js(
            nodeColor::D3Scale=OrdinalScale([0, 1], ["black", "black"]),
            nodeSize::D3Scale=OrdinalScale([0, 1], [3, 3]),
            edgeColor::D3Scale=OrdinalScale([0, 1], ["black", "black"]),
            edgeSize::D3Scale=OrdinalScale([0, 1], [1, 1])
    )

    return """
    <script>

    var svg = d3.select("svg"),
        width = +svg.attr("width"),
        height = +svg.attr("height");

    var simulation = d3.forceSimulation()
        .force("link", d3.forceLink().id(function(d) { return d.id; }))
        .force("charge", d3.forceManyBody())
        .force("center", d3.forceCenter(width / 2, height / 2));

    d3.json("graphdata.json", function(error, graph) {
      if (error) throw error;

      var nodeColor = $(string(nodeColor))

      var nodeSize = $(string(nodeSize))

      var edgeColor = $(string(edgeColor))

      var edgeSize = $(string(edgeSize))

      var link = svg.append("g")
        .attr("class", "link")
        .selectAll("line")
        .data(graph.links)
        .enter()
          .append("line")
          .attr("stroke", function(d) { return edgeColor(d.color); });

      var node = svg.append("g")
        .attr("class", "node")
        .selectAll("circle")
        .data(graph.nodes)
        .enter()
          .append("circle")
            .attr("r", function(d) { return nodeSize(d.size); })
            .style("fill", function(d) { return nodeColor(d.color); })
            .call(d3.drag()
                .on("start", dragstarted)
                .on("drag", dragged)
                .on("end", dragended));

      node.append("title")
        .text(function(d) { return d.id; });

      simulation
        .nodes(graph.nodes)
        .on("tick", ticked);

      simulation.force("link")
        .links(graph.links);

      function ticked() {
        link
          .attr("x1", function(d) { return d.source.x; })
          .attr("y1", function(d) { return d.source.y; })
          .attr("x2", function(d) { return d.target.x; })
          .attr("y2", function(d) { return d.target.y; });

        node
          .attr("cx", function(d) { return d.x; })
          .attr("cy", function(d) { return d.y; });
      }
    });

    function dragstarted(d) {
      if (!d3.event.active) simulation.alphaTarget(0.3).restart();
      d.fx = d.x;
      d.fy = d.y;
    }

    function dragged(d) {
      d.fx = d3.event.x;
      d.fy = d3.event.y;
    }

    function dragended(d) {
      if (!d3.event.active) simulation.alphaTarget(0);
      d.fx = null;
      d.fy = null;
    }

    </script>
    """
end

"""
Build html file by in chunks by calling `css(css_opts...)`, `svg(svg_opts...)`, and `js(js_opts...)`. Save to `savepath`.
"""
function savehtml(savepath::String;
            nodeColor::D3Scale=OrdinalScale([0, 1], ["black", "black"]),
            nodeSize::D3Scale=OrdinalScale([0, 1], [3, 3]),
            edgeColor::D3Scale=OrdinalScale([0, 1], ["black", "black"]),
            edgeSize::D3Scale=OrdinalScale([0, 1], [1, 1]))
    open(savepath, "w") do f
        write(f, *(header, css(), svg(), d3,
        js(nodeColor, nodeSize, edgeColor, edgeSize)))
    end
    return
end

# TODO: get this working
# using HttpServer
#
# function servehtml()
#     http = HttpHandler() do req::Request, res::Response
#         Response()
#     end
#     server = Server( http )
#     run( server, 8000 )
# end
