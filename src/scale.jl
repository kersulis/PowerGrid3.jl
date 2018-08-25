export ContinuousScale, OrdinalScale,
        getname, getscalekind, getdomain, getrange

struct ContinuousScale
    name::String
    kind::Symbol
    domain::Vector
    range::Vector

    function ContinuousScale(name, kind, domain, range)
        if !(kind in [:Linear, :Pow, :Log, :Time])
            error("Invalid scale type.")
        end
        new(name, kind, domain, range)
    end
end
ContinuousScale(name::String, domain::Vector, range::Vector) = ContinuousScale(name, :Linear, domain, range)

struct OrdinalScale
    name::String
    domain::Vector
    range::Vector

    function OrdinalScale(name, domain, range)
        nd, nr = length(domain), length(range)
        if nd != nr
            error("Domain and range must have matching length.")
        end
        new(name, domain, range)
    end
end

getname(s::ContinuousScale) = s.name
getscalekind(s::ContinuousScale) = s.kind
getdomain(s::ContinuousScale) = s.domain
getrange(s::ContinuousScale) = s.range

getname(s::OrdinalScale) = s.name
getdomain(s::OrdinalScale) = s.domain
getrange(s::OrdinalScale) = s.range

function Base.string(s::ContinuousScale)
    name = getname(s)
    kind = getscalekind(s)
    d = getdomain(s)
    r = getrange(s)
    return """
    var $name = d3.scale$kind()
      .domain([$(delimited_string(d))])
      .range([$(delimited_string(r))])
    """
end

function Base.string(s::OrdinalScale)
    name = getname(s)
    d = getdomain(s)
    r = getrange(s)
    return """
    var $name = d3.scaleOrdinal()
      .domain([$(delimited_string(d))])
      .range([$(delimited_string(r))])
    """
end
