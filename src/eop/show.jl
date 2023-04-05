# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==========================================================================================
#
#   Functions to show the EOP interpolated data.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

function show(io::IO, eop::EopIau1980)
    print(io, "EopIau1980")
    return nothing
end

function show(io::IO, mime::MIME"text/plain", eop::EopIau1980)
    # Check if IO has support for colors.
    color = get(io, :color, false)::Bool

    b = color ? string(_B) : ""
    g = color ? string(_G) : ""
    r = color ? string(_R) : ""

    println(io, "EopIau1980:")
    println(io, b, "     Data ", g, "│ ", r, b, "Timespan", r)
    println(io, g, " ─────────┼──────────────────────────────────────────────", r)
    println(io, b, "        x ", g, "│ ", r, _itp_timespan(eop.x))
    println(io, b, "        y ", g, "│ ", r, _itp_timespan(eop.y))
    println(io, b, "  UT1-UTC ", g, "│ ", r, _itp_timespan(eop.Δut1_utc))
    println(io, b, "      LOD ", g, "│ ", r, _itp_timespan(eop.lod))
    println(io, b, "      δΔψ ", g, "│ ", r, _itp_timespan(eop.δΔψ))
    print(io,   b, "      δΔϵ ", g, "│ ", r, _itp_timespan(eop.δΔϵ))

    return nothing
end

function show(io::IO, eop::EopIau2000A)
    print(io, "EopIau2000A")
    return nothing
end

function show(io::IO, mime::MIME"text/plain", eop::EopIau2000A)
    # Check if IO has support for colors.
    color = get(io, :color, false)::Bool

    b = color ? string(_B) : ""
    g = color ? string(_G) : ""
    r = color ? string(_R) : ""

    println(io, "EopIau2000A:")
    println(io, _b, "     Data ", _g, "│ ", _r, _b, "Timespan", _r)
    println(io, _g, " ─────────┼──────────────────────────────────────────────", _r)
    println(io, _b, "        x ", _g, "│ ", _r, _itp_timespan(eop.x))
    println(io, _b, "        y ", _g, "│ ", _r, _itp_timespan(eop.y))
    println(io, _b, "  UT1-UTC ", _g, "│ ", _r, _itp_timespan(eop.Δut1_utc))
    println(io, _b, "      LOD ", _g, "│ ", _r, _itp_timespan(eop.lod))
    println(io, _b, "       δx ", _g, "│ ", _r, _itp_timespan(eop.δx))
    print(io,   _b, "       δy ", _g, "│ ", _r, _itp_timespan(eop.δy))

    return nothing
end
