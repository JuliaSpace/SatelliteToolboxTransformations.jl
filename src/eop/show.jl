## Description #############################################################################
#
# Functions to show the EOP interpolated data.
#
############################################################################################

"""
    Base.show(io::IO, eop::EopIau1980) -> Nothing

Print the compact type name of the IAU 1980 EOP data `eop` to `io`.
"""
function Base.show(io::IO, eop::EopIau1980)
    print(io, "EopIau1980")
    return nothing
end

"""
    Base.show(io::IO, ::MIME"text/plain", eop::EopIau1980) -> Nothing

Print the IAU 1980 EOP data `eop` to `io` as a table with the timespan of each field.
"""
function Base.show(io::IO, ::MIME"text/plain", eop::EopIau1980)
    _show_eop(
        io,
        "EopIau1980",
        ("x", "y", "UT1-UTC", "LOD", "δΔψ", "δΔϵ"),
        (eop.x, eop.y, eop.Δut1_utc, eop.lod, eop.δΔψ, eop.δΔϵ),
    )
    return nothing
end

"""
    Base.show(io::IO, eop::EopIau2000A) -> Nothing

Print the compact type name of the IAU 2000A EOP data `eop` to `io`.
"""
function Base.show(io::IO, eop::EopIau2000A)
    print(io, "EopIau2000A")
    return nothing
end

"""
    Base.show(io::IO, ::MIME"text/plain", eop::EopIau2000A) -> Nothing

Print the IAU 2000A EOP data `eop` to `io` as a table with the timespan of each field.
"""
function Base.show(io::IO, ::MIME"text/plain", eop::EopIau2000A)
    _show_eop(
        io,
        "EopIau2000A",
        ("x", "y", "UT1-UTC", "LOD", "δx", "δy"),
        (eop.x, eop.y, eop.Δut1_utc, eop.lod, eop.δx, eop.δy),
    )
    return nothing
end

############################################################################################
#                                    Private Functions                                     #
############################################################################################

"""
    _show_eop(
        io::IO,
        name::String,
        labels::NTuple{6, String},
        itps::NTuple{6, EopInterpolation}
    ) -> Nothing

Print to `io` a table titled `name` with one row per EOP interpolation in `itps`, labeled
by `labels`, showing the timespan of each field. The styles are rendered only if `io`
supports colors.
"""
function _show_eop(
    io::IO, name::String, labels::NTuple{6, String}, itps::NTuple{6, EopInterpolation}
)
    header    = lpad("Data", 9)
    separator = " " * "─"^9 * "┼" * "─"^46

    println(io, name, ":")
    println(io, styled"{bold:$header} {bright_black:│ }{bold:Timespan}")
    println(io, styled"{bright_black:$separator}")

    for i in 1:6
        label    = lpad(labels[i], 9)
        timespan = _itp_timespan(itps[i])
        print(io, styled"{bold:$label} {bright_black:│ }$timespan")
        i < 6 && println(io)
    end

    return nothing
end
