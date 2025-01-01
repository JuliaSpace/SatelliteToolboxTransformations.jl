## Description #############################################################################
#
# Convert an orbit representation from an Earth-Centered Inertial (ECI) reference frame to
# another ECI reference frame.
#
## References ##############################################################################
#
# [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm Press,
#     Hawthorn, CA, USA.
#
############################################################################################

export orb_eci_to_eci

"""
    orb_eci_to_eci(orb::T, args...) where T<:Orbit -> T
    orb_eci_to_eci(orb::T, ECIo, ECIf[, jd_utc::Number][, eop]) where T<: Orbit -> T
    orb_eci_to_eci(orb::T, ECIo, [jd_utco::Number, ]ECIf[, jd_utcf::Number][, eop]) where T<:Orbit -> T

Convert the orbit representation `orb` from an Earth-Centered Inertial (ECI) reference frame
`ECIo` to another ECI reference frame `ECIf`. If the origin and destination frame contain
only one *of date* frame, the first signature is used and the Julian Day `jd_utc` [UTC] is
the epoch of this frame. On the other hand, if the origin and destination frame contain two
*of date* frame`¹`, e.g. TOD => MOD, the second signature must be used in which the Julian
Day `jd_utco` [UTC] is the epoch of the origin frame and the Julian Day `jd_utcf` [UTC] is
the epoch of the destination frame. The algorithm might also require the Earth Orientation
Parameters (EOP) `eop` depending on the source and destination frames.

!!! note

    For more information, including how to specify the origin and destination reference
    frames, see the **Extended Help**.

# Returns

- `T`: Orbit representation converted to the `ECIf` reference frame.

# Extended Help

## Conversion Model

The model that will be used to compute the rotation is automatically inferred given the
selection of the origin and destination frames. **Notice that mixing IAU-76/FK5 and
IAU-2006/2010 frames is not supported.**

## Supported ECI Reference Frames

The supported ECI frames for both origin `ECIo` and destination `ECIf` are:

- `TEME()`: ECI will be selected as the True Equator Mean Equinox (TEME) reference frame.
- `TOD()`: ECI will be selected as the True of Date (TOD).
- `MOD()`: ECI will be selected as the Mean of Date (MOD).
- `J2000()`: ECI will be selected as the J2000 reference frame.
- `GCRF()`: ECI will be selected as the Geocentric Celestial Reference Frame (GCRF).
- `CIRS()`: ECEF will be selected as the Celestial Intermediate Reference System (CIRS).
- `ERS()`: ECI will be selected as the Earth Reference System (ERS).
- `MOD06()`: ECI will be selected as the Mean of Date (MOD) according to the definition in
    IAU-2006/2010 theory.
- `MJ2000()`: ECI will be selected as the J2000 mean equatorial frame (MJ2000).

!!! note

    The frames `MOD()` and `MOD06()` are virtually the same. However, we selected different
    names to make clear which theory are being used since mixing transformation between
    frames from IAU-76/FK5 and IAU-2006/2010 must be performed with caution.

## Earth Orientation Parameters (EOP)

The conversion between the frames might depend on EOP Data (see [`fetch_iers_eop`](@ref) and
[`read_iers_eop`](@ref)). If IAU-76/FK5 model is used, the type of `eop` must be
[`EopIau1980`](@ref). Otherwise, if IAU-2006/2010 model is used, the type of `eop` must be
[`EopIau2000A`](@ref). The following table shows the requirements for EOP data given the
selected frames.

|   Model                     |   ECIo   |   ECIf   |    EOP Data   | Function Signature |
|:----------------------------|:---------|:---------|:--------------|:-------------------|
| IAU-76/FK5                  | `GCRF`   | `J2000`  | EOP IAU1980   | First              |
| IAU-76/FK5                  | `GCRF`   | `MOD`    | EOP IAU1980   | First              |
| IAU-76/FK5                  | `GCRF`   | `TOD`    | EOP IAU1980   | First              |
| IAU-76/FK5                  | `GCRF`   | `TEME`   | EOP IAU1980   | First              |
| IAU-76/FK5                  | `J2000`  | `GCRF`   | EOP IAU1980   | First              |
| IAU-76/FK5                  | `J2000`  | `MOD`    | Not required  | First              |
| IAU-76/FK5                  | `J2000`  | `TOD`    | Not required  | First              |
| IAU-76/FK5                  | `J2000`  | `TEME`   | Not required  | First              |
| IAU-76/FK5                  | `MOD`    | `GCRF`   | EOP IAU1980   | First              |
| IAU-76/FK5                  | `MOD`    | `J2000`  | Not required  | First              |
| IAU-76/FK5                  | `MOD`    | `TOD`    | Not required  | Second             |
| IAU-76/FK5                  | `MOD`    | `TEME`   | Not required  | Second             |
| IAU-76/FK5                  | `TOD`    | `GCRF`   | EOP IAU1980   | First              |
| IAU-76/FK5                  | `TOD`    | `J2000`  | Not required  | First              |
| IAU-76/FK5                  | `TOD`    | `MOD`    | Not required  | Second             |
| IAU-76/FK5                  | `TOD`    | `TEME`   | Not required  | Second             |
| IAU-76/FK5                  | `TEME`   | `GCRF`   | EOP IAU1980   | First              |
| IAU-76/FK5                  | `TEME`   | `J2000`  | Not required  | First              |
| IAU-76/FK5                  | `TEME`   | `MOD`    | Not required  | Second             |
| IAU-76/FK5                  | `TEME`   | `TOD`    | Not required  | Second             |
| IAU-2006/2010 CIO-based     | `GCRF`   | `CIRS`   | Not required¹ | First              |
| IAU-2006/2010 CIO-based     | `CIRS`   | `CIRS`   | Not required¹ | Second             |
| IAU-2006/2010 Equinox-based | `GCRF`   | `MJ2000` | Not required  | First²             |
| IAU-2006/2010 Equinox-based | `GCRF`   | `MOD06`  | Not required  | First              |
| IAU-2006/2010 Equinox-based | `GCRF`   | `ERS`    | Not required³ | First              |
| IAU-2006/2010 Equinox-based | `MJ2000` | `GCRF`   | Not required  | First²             |
| IAU-2006/2010 Equinox-based | `MJ2000` | `MOD06`  | Not required  | First              |
| IAU-2006/2010 Equinox-based | `MJ2000` | `ERS`    | Not required³ | First              |
| IAU-2006/2010 Equinox-based | `MOD06`  | `GCRF`   | Not required  | First              |
| IAU-2006/2010 Equinox-based | `MOD06`  | `MJ2000` | Not required  | First              |
| IAU-2006/2010 Equinox-based | `MOD06`  | `ERS`    | Not required³ | First              |
| IAU-2006/2010 Equinox-based | `ERS`    | `GCRF`   | Not required³ | First              |
| IAU-2006/2010 Equinox-based | `ERS`    | `MJ2000` | Not required³ | First              |
| IAU-2006/2010 Equinox-based | `ERS`    | `MOD06`  | Not required³ | First              |

`¹`: In this case, the terms that account for the free-core nutation and time dependent
effects of the Celestial Intermediate Pole (CIP) position with respect to the GCRF will not
be available, reducing the precision.

`²`: The transformation between GCRF and MJ2000 is a constant rotation matrix called bias.
Hence, the date does not modify it. However, this signature was kept to avoid complications
in the API.

`³`: In this case, the terms that corrects the nutation in obliquity and in longitude due to
the free core nutation will not be available, reducing the precision.

!!! info

    In this function, if EOP corrections are not provided, MOD and TOD frames will be
    computed considering the original IAU-76/FK5 theory. Otherwise, the corrected frame will
    be used.

# Examples

```julia-repl
julia> orb = KeplerianElements(
    date_to_jd(2025, 1, 1),
    8000e3,
    0.015,
    28.5 |> deg2rad,
    100  |> deg2rad,
    200  |> deg2rad,
    45   |> deg2rad
)
KeplerianElements{Float64, Float64}:
           Epoch :    2.46068e6 (2025-01-01T00:00:00)
 Semi-major axis : 8000.0   km
    Eccentricity :    0.015
     Inclination :   28.5   °
            RAAN :  100.0   °
 Arg. of Perigee :  200.0   °
    True Anomaly :   45.0   °

julia> orb_eci_to_eci(orb, TOD(), J2000())
KeplerianElements{Float64, Float64}:
           Epoch :    2.46068e6 (2025-01-01T00:00:00)
 Semi-major axis : 8000.0    km
    Eccentricity :    0.015
     Inclination :   28.6376 °
            RAAN :   99.6403 °
 Arg. of Perigee :  200.045  °
    True Anomaly :   45.0    °
```
"""
function orb_eci_to_eci(orb::T, args::Vararg{Any, N}) where {N, T<:Orbit}
    # First, we need to convert to state vector.
    sv_o = convert(OrbitStateVector, orb)

    # Now, we can transform the state vector to the desired reference frame.
    sv_f = sv_eci_to_eci(sv_o, args...)

    # Finally, we convert the state vector back to the orbit representation.
    return convert(T, sv_f)
end
