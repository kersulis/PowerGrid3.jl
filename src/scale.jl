export D3Scale, ContinuousScale, OrdinalScale,
        getscalekind, getdomain, getrange

abstract type D3Scale end

struct ContinuousScale <: D3Scale
    kind::Symbol
    domain::Vector
    range::Vector

    function ContinuousScale(kind::Symbol, domain::Vector, range::Vector)
        if !(kind in [:Linear, :Pow, :Log, :Time])
            error("Invalid scale type.")
        end
        new(kind, domain, range)
    end
end

# default to linear when kind is unspecified
ContinuousScale(domain::Vector, range::Vector) = ContinuousScale(:Linear, domain, range)

# default domain when only range is specified
function ContinuousScale(mapping::Dict, range::Vector)
    assert(length(range) == 2)

    a, b = extrema(values(mapping))
    domain = [a, b]
    return ContinuousScale(domain, range)
end

struct OrdinalScale <: D3Scale
    domain::Vector
    range::Vector

    function OrdinalScale(domain::Vector, range::Vector)
        nd, nr = length(domain), length(range)
        if nd != nr
            error("Domain and range must have matching length.")
        end
        new(domain, range)
    end
end

getscalekind(s::ContinuousScale) = s.kind
getdomain(s::ContinuousScale) = s.domain
getrange(s::ContinuousScale) = s.range

getdomain(s::OrdinalScale) = s.domain
getrange(s::OrdinalScale) = s.range

function Base.string(s::ContinuousScale)
    kind = getscalekind(s)
    d = getdomain(s)
    r = getrange(s)
    return """
    d3.scale$kind()
      .domain([$(delimited_string(d))])
      .range([$(delimited_string(r))]);
    """
end

function Base.string(s::OrdinalScale)
    d = getdomain(s)
    r = getrange(s)
    return """
    d3.scaleOrdinal()
      .domain([$(delimited_string(d))])
      .range([$(delimited_string(r))]);
    """
end
