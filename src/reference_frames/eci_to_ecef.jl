## Description #############################################################################
#
# Rotations from an Earth-Fixed Inertial (ECI) reference frame to an Earth-Fixed,
# Earth-Centered (ECEF) reference frame.
#
## References ##############################################################################
#
# [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm Press,
#     Hawthorn, CA, USA.
#
############################################################################################

export r_eci_to_ecef

"""
    r_eci_to_ecef([T, ]ECI, ECEF, jd_utc::Number[, eop]) -> T

Compute the rotation from an Earth-Centered Inertial (`ECI`) reference frame to an
Earth-Centered, Earth-Fixed (`ECEF`) reference frame at the Julian Day `jd_utc` [UTC]. The
rotation description that will be used is given by `T`, which can be `DCM` or `Quaternion`.
The algorithm might also require the Earth Orientation Parameters (EOP) `eop` depending on
the source and destination frames.

!!! note

    For more information, including how to specify the origin and destination reference
    frames, see the **Extended Help**.

# Returns

- `T`: The rotation entity that aligns the ECI reference frame with the ECEF reference
    frame.

# Extended Help

## Rotation Description

The rotation can be described by Direction Cosine Matrices (DCMs) or Quaternions. This is
selected by the parameter `T`. The possible values are:

- `DCM`: The rotation will be described by a Direction Cosine Matrix.
- `Quaternion`: The rotation will be described by a Quaternion.

If no value is specified, it falls back to `DCM`.

## Conversion Model

The model that will be used to compute the rotation is automatically inferred given the
selection of the origin and destination frames. **Notice that mixing IAU-76/FK5 and
IAU-2006/2010 frames is not supported.**

## Supported ECI Reference Frames

The ECI frame is selected by the parameter `ECI`. The possible values are:

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

## Supported ECEF Reference Frames

The ECEF frame is selected by the parameter `ECEF`. The possible values are:

- `ITRF()`: ECEF will be selected as the International Terrestrial Reference Frame (ITRF).
- `PEF()`: ECEF will be selected as the Pseudo-Earth Fixed (PEF) reference frame.
- `TIRS()`: ECEF will be selected as the Terrestrial Intermediate Reference System (TIRS).

## Earth Orientation Parameters (EOP)

The conversion between the frames might depend on EOP (see [`fetch_iers_eop`](@ref) and
[`read_iers_eop`](@ref)). If IAU-76/FK5 model is used, the type of `eop` must be
[`EopIau1980`](@ref). Otherwise, if IAU-2006/2010 model is used, the type of `eop` must be
[`EopIau2000A`](@ref). The following table shows the requirements for EOP data given the
selected frames.

|   Model                     |   ECI    |  ECEF  |    EOP Data     |
|:----------------------------|:---------|:-------|:----------------|
| IAU-76/FK5                  | `GCRF`   | `ITRF` | EOP IAU1980     |
| IAU-76/FK5                  | `J2000`  | `ITRF` | EOP IAU1980     |
| IAU-76/FK5                  | `MOD`    | `ITRF` | EOP IAU1980     |
| IAU-76/FK5                  | `TOD`    | `ITRF` | EOP IAU1980     |
| IAU-76/FK5                  | `TEME`   | `ITRF` | EOP IAU1980     |
| IAU-76/FK5                  | `GCRF`   | `PEF`  | EOP IAU1980     |
| IAU-76/FK5                  | `J2000`  | `PEF`  | Not required¹   |
| IAU-76/FK5                  | `MOD`    | `PEF`  | Not required¹   |
| IAU-76/FK5                  | `TOD`    | `PEF`  | Not required¹   |
| IAU-76/FK5                  | `TEME`   | `PEF`  | Not required¹   |
| IAU-2006/2010 CIO-based     | `CIRS`   | `ITRF` | EOP IAU2000A    |
| IAU-2006/2010 CIO-based     | `GCRF`   | `ITRF` | EOP IAU2000A    |
| IAU-2006/2010 CIO-based     | `CIRS`   | `TIRS` | Not required¹   |
| IAU-2006/2010 CIO-based     | `GCRF`   | `TIRS` | Not required¹ ² |
| IAU-2006/2010 Equinox-based | `ERS`    | `TIRS` | EOP IAU2000A    |
| IAU-2006/2010 Equinox-based | `MOD06`  | `ITRF` | EOP IAU2000A    |
| IAU-2006/2010 Equinox-based | `MJ2000` | `ITRF` | EOP IAU2000A    |
| IAU-2006/2010 Equinox-based | `ERS`    | `TIRS` | Not required¹ ³ |
| IAU-2006/2010 Equinox-based | `MOD06`  | `TIRS` | Not required¹ ³ |
| IAU-2006/2010 Equinox-based | `MJ2000` | `TIRS` | Not required¹ ³ |

`¹`: In this case, UTC will be assumed equal to UT1 to compute the Greenwich Mean Sidereal
Time. This is an approximation but should be sufficiently accurate for some applications.
Notice that, if EOP Data is provided, UT1 will be accurately computed.

`²`: In this case, the terms that account for the free-core nutation and time dependent
effects of the Celestial Intermediate Pole (CIP) position with respect to the GCRF will not
be available, reducing the precision.

`³`: In this case, the terms that corrects the nutation in obliquity and in longitude due to
the free core nutation will not be available, reducing the precision.

!!! info

    In this function, if EOP corrections are not provided, MOD and TOD frames will be
    computed considering the original IAU-76/FK5 theory. Otherwise, the corrected frame will
    be used.

## Examples

```julia-repl
julia> eop_iau1980 = fetch_iers_eop(Val(:IAU1980));

julia> r_eci_to_ecef(DCM, GCRF(), ITRF(), date_to_jd(1986, 06, 19, 21, 35, 0), eop_iau1980)
DCM{Float64}:
 -0.619267    -0.78518     -0.000797312
  0.78518     -0.619267     0.00106478
 -0.00132979   3.33509e-5   0.999999

julia> r_eci_to_ecef(GCRF(), ITRF(), date_to_jd(1986, 06, 19, 21, 35, 0), eop_iau1980)
DCM{Float64}:
 -0.619267    -0.78518     -0.000797312
  0.78518     -0.619267     0.00106478
 -0.00132979   3.33509e-5   0.999999

julia> r_eci_to_ecef(J2000(), PEF(), date_to_jd(1986, 06, 19, 21, 35, 0))
DCM{Float64}:
 -0.619271    -0.785177    -0.000796885
  0.785176    -0.619272     0.00106622
 -0.00133066   3.45854e-5   0.999999

julia> r_eci_to_ecef(J2000(), PEF(), date_to_jd(1986, 06, 19, 21, 35, 0), eop_iau1980)
DCM{Float64}:
 -0.619267    -0.78518     -0.000796879
  0.78518     -0.619267     0.00106623
 -0.00133066   3.45854e-5   0.999999

julia> r_eci_to_ecef(Quaternion, GCRF(), ITRF(), date_to_jd(1986, 06, 19, 21, 35, 0), eop_iau1980)
Quaternion{Float64}:
  + 0.43631 + 0.000590997⋅i - 0.000305106⋅j - 0.899796⋅k

julia> eop_iau2000a = fetch_iers_eop(Val(:IAU2000A));

julia> r_eci_to_ecef(GCRF(), ITRF(), date_to_jd(1986, 06, 19, 21, 35, 0), eop_iau2000a)
DCM{Float64}:
 -0.619267    -0.78518     -0.000797311
  0.78518     -0.619267     0.00106478
 -0.00132979   3.33516e-5   0.999999

julia> r_eci_to_ecef(GCRF(), TIRS(), date_to_jd(1986, 06, 19, 21, 35, 0))
DCM{Float64}:
 -0.619271    -0.785177    -0.000796885
  0.785176    -0.619272     0.00106623
 -0.00133066   3.45884e-5   0.999999

julia> r_eci_to_ecef(Quaternion, GCRF(), ITRF(), date_to_jd(1986, 06, 19, 21, 35, 0), eop_iau2000a)
Quaternion{Float64}:
  + 0.43631 + 0.000590997⋅i - 0.000305106⋅j - 0.899796⋅k
```
"""
function r_eci_to_ecef(T_ECI::T_ECIs, T_ECEF::T_ECEFs, jd_utc::Number, eop::EopIau1980)
    return r_eci_to_ecef(DCM, T_ECI, T_ECEF, jd_utc, eop)
end

function r_eci_to_ecef(
    T::T_ROT,
    T_ECI::T_ECIs,
    T_ECEF::T_ECEFs,
    jd_utc::Number,
    eop::EopIau1980
)
    return inv_rotation(r_ecef_to_eci(T, T_ECEF, T_ECI, jd_utc, eop))
end

function r_eci_to_ecef(
    T_ECI::T_ECIs_IAU_2006,
    T_ECEF::T_ECEFs_IAU_2006,
    jd_utc::Number,
    eop::EopIau2000A
)
    return r_eci_to_ecef(DCM, T_ECI, T_ECEF, jd_utc, eop)
end

function r_eci_to_ecef(
    T::T_ROT,
    T_ECI::T_ECIs_IAU_2006,
    T_ECEF::T_ECEFs_IAU_2006,
    jd_utc::Number,
    eop::EopIau2000A
)
    return inv_rotation(r_ecef_to_eci(T, T_ECEF, T_ECI, jd_utc, eop))
end

# Specializations for those cases that EOP is not needed.
function r_eci_to_ecef(
    T_ECI::Union{Val{:J2000}, Val{:TOD}, Val{:MOD}, Val{:TEME}},
    T_ECEF::Val{:PEF},
    jd_utc::Number
)
    return r_eci_to_ecef(DCM, T_ECI, T_ECEF, jd_utc)
end

function r_eci_to_ecef(
    T::T_ROT,
    T_ECI::Union{Val{:J2000}, Val{:TOD}, Val{:MOD}, Val{:TEME}},
    T_ECEF::Val{:PEF},
    jd_utc::Number
)
    return inv_rotation(r_ecef_to_eci(T, T_ECEF, T_ECI, jd_utc))
end

function r_eci_to_ecef(
    T_ECI::T_ECIs_IAU_2006,
    T_ECEF::Val{:TIRS},
    jd_utc::Number
)
    return r_eci_to_ecef(DCM, T_ECI, T_ECEF, jd_utc)
end

function r_eci_to_ecef(
    T::T_ROT,
    T_ECI::T_ECIs_IAU_2006,
    T_ECEF::Val{:TIRS},
    jd_utc::Number
)
    return inv_rotation(r_ecef_to_eci(T, T_ECEF, T_ECI, jd_utc))
end
