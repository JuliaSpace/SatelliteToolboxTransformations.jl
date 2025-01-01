## Description #############################################################################
#
# Convert an orbit state vector from an Earth-Centered, Earth-Fixed (ECEF) reference frame
# to a Earth-Centered Inertial (ECI) reference frame.
#
## References ##############################################################################
#
# [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm
#     Press, Hawthorn, CA, USA.
#
############################################################################################

export sv_ecef_to_eci

"""
    sv_ecef_to_eci(sv::OrbitStateVector, ECEF, ECI[, jd_utc][, eop]) -> OrbitStateVector

Convert the orbit state vector `sv` from the Earth-Centered, Earth-Fixed (`ECEF`) reference
frame to the Earth-Centered Inertial (`ECI`) reference frame at the Julian day `jd_utc`
[UTC]. If the epoch `jd_utc` is not provided, the algorithm will use the epoch of the orbit
state vector `sv` (`sv.t`). The algorithm might also require the Earth Orientation
Parameters (EOP) `eop` depending on the source and destination frames.

It is assumed that the input velocity and acceleration in `sv` are obtained by an observer
on the ECEF frame. Thus, the output will contain the velocity and acceleration as measured
by an observer on the ECI frame.

!!! note

    For more information, including how to specify the origin and destination reference
    frames, see the **Extended Help**.

# Returns

- `OrbitStateVector`: Orbit state vector `sv` converted to the `ECI` reference frame.

# Extended Help

## Conversion Model

The model that will be used to compute the rotation is automatically inferred given the
selection of the origin and destination frames. **Notice that mixing IAU-76/FK5 and
IAU-2006/2010 frames is not supported.**

## Supported ECEF Reference Frames

The ECEF frame is selected by the parameter `ECEF`. The possible values are:

- `ITRF()`: ECEF will be selected as the International Terrestrial Reference Frame (ITRF).
- `PEF()`: ECEF will be selected as the Pseudo-Earth Fixed (PEF) reference frame.
- `TIRS()`: ECEF will be selected as the Terrestrial Intermediate Reference System (TIRS).

## Supported ECI Reference Frames

The ECI frame is selected by the parameter `ECI`. The possible values are:

- `TEME()`: ECI will be selected as the True Equator Mean Equinox (TEME) reference frame.
- `TOD()`: ECI will be selected as the True of Date (TOD).
- `MOD()`: ECI will be selected as the Mean of Date (MOD).
- `J2000()`: ECI will be selected as the J2000 reference frame.
- `GCRF()`: ECI will be selected as the Geocentric Celestial Reference Frame (GCRF).
- `CIRS()`: ECI will be selected as the Celestial Intermediate Reference System (CIRS).
- `ERS()`: ECI will be selected as the Earth Reference System (ERS).
- `MOD06()`: ECI will be selected as the Mean of Date (MOD) according to the definition in
    IAU-2006/2010 theory.
- `MJ2000()`: ECI will be selected as the J2000 mean equatorial frame (MJ2000).

!!! note

    The frames `MOD()` and `MOD06()` are virtually the same. However, we selected different
    names to make clear which theory are being used since mixing transformation between
    frames from IAU-76/FK5 and IAU-2006/2010 must be performed with caution.

# Earth Orientation Parameters (EOP)

The conversion between the frames might depend on EOP (see [`fetch_iers_eop`](@ref) and
[`read_iers_eop`](@ref)). If IAU-76/FK5 model is used, the type of `eop` must be
[`EopIau1980`](@ref). Otherwise, if IAU-2006/2010 model is used, the type of `eop` must be
[`EopIau2000A`](@ref). The following table shows the requirements for EOP data given the
selected frames.

|   Model                     |  ECEF  |   ECI    |    EOP Data     |
|:----------------------------|:-------|:---------|:----------------|
| IAU-76/FK5                  | `ITRF` | `GCRF`   | EOP IAU1980     |
| IAU-76/FK5                  | `ITRF` | `J2000`  | EOP IAU1980     |
| IAU-76/FK5                  | `ITRF` | `MOD`    | EOP IAU1980     |
| IAU-76/FK5                  | `ITRF` | `TOD`    | EOP IAU1980     |
| IAU-76/FK5                  | `ITRF` | `TEME`   | EOP IAU1980     |
| IAU-76/FK5                  | `PEF`  | `GCRF`   | EOP IAU1980     |
| IAU-76/FK5                  | `PEF`  | `J2000`  | Not required¹   |
| IAU-76/FK5                  | `PEF`  | `MOD`    | Not required¹   |
| IAU-76/FK5                  | `PEF`  | `TOD`    | Not required¹   |
| IAU-76/FK5                  | `PEF`  | `TEME`   | Not required¹   |
| IAU-2006/2010 CIO-based     | `ITRF` | `CIRS`   | EOP IAU2000A    |
| IAU-2006/2010 CIO-based     | `ITRF` | `GCRF`   | EOP IAU2000A    |
| IAU-2006/2010 CIO-based     | `TIRS` | `CIRS`   | Not required¹   |
| IAU-2006/2010 CIO-based     | `TIRS` | `GCRF`   | Not required¹ ² |
| IAU-2006/2010 Equinox-based | `ITRF` | `ERS`    | EOP IAU2000A    |
| IAU-2006/2010 Equinox-based | `ITRF` | `MOD06`  | EOP IAU2000A    |
| IAU-2006/2010 Equinox-based | `ITRF` | `MJ2000` | EOP IAU2000A    |
| IAU-2006/2010 Equinox-based | `TIRS` | `ERS`    | Not required¹ ³ |
| IAU-2006/2010 Equinox-based | `TIRS` | `MOD06`  | Not required¹ ³ |
| IAU-2006/2010 Equinox-based | `TIRS` | `MJ2000` | Not required¹ ³ |

`¹`: In this case, UTC will be assumed equal to UT1 to compute the Greenwich Mean Sidereal
Time. This is an approximation, but should be sufficiently accurate for some applications.
Notice that, if EOP Data is provided, UT1 will be accurately computed.

`²`: In this case, the terms that account for the free core nutation and time dependent
effects of the Celestial Intermediate Pole (CIP) position with respect to the GCRF will not
be available, reducing the precision.

`³`: In this case, the terms that corrects the nutation in obliquity and in longitude due to
the free core nutation will not be available, reducing the precision.

!!! info

    In this function, if EOP corrections are not provided, MOD and TOD frames will be
    computed considering the original IAU-76/FK5 theory. Otherwise, the corrected frame will
    be used.

# Examples

```julia-repl
julia> eop_iau1980 = fetch_iers_eop(Val(:IAU1980));

julia> jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009);

julia> r_itrf  = [-1033.4793830; 7901.2952754; 6380.3565958] * 1000;

julia> v_itrf  = [-3.225636520; -2.872451450; +5.531924446] * 1000;

julia> sv_itrf = OrbitStateVector(jd_utc, r_itrf, v_itrf)
OrbitStateVector{Float64, Float64}:
  epoch : 2.4531e6 (2004-04-06T07:51:28.386)
      r : [-1033.48, 7901.3, 6380.36]    km
      v : [-3.22564, -2.87245, 5.53192]  km/s

julia> sv_gcrf = sv_ecef_to_eci(sv_itrf, ITRF(), GCRF(), eop_iau1980)
OrbitStateVector{Float64, Float64}:
  epoch : 2.4531e6 (2004-04-06T07:51:28.386)
      r : [5102.51, 6123.01, 6378.14]    km
      v : [-4.74322, 0.790537, 5.53376]  km/s

julia> eop_iau2000a = fetch_iers_eop(Val(:IAU2000A));

julia> sv_cirs = sv_ecef_to_eci(sv_itrf, ITRF(), CIRS(), eop_iau2000a)
OrbitStateVector{Float64, Float64}:
  epoch : 2.4531e6 (2004-04-06T07:51:28.386)
      r : [5100.02, 6122.79, 6380.34]    km
      v : [-4.74538, 0.790342, 5.53193]  km/s
```
"""
function sv_ecef_to_eci(
    sv::OrbitStateVector,
    T_ECEF::Val{:ITRF},
    T_ECI::T_ECIs,
    jd_utc::Number,
    eop::EopIau1980
)
    # First, convert from the ITRF to PEF.
    sv_pef = sv_ecef_to_ecef(sv, Val(:ITRF), Val(:PEF), jd_utc, eop)

    # Now, convert from PEF to ECI.
    return sv_ecef_to_eci(sv_pef, Val(:PEF), T_ECI, jd_utc, eop)
end

function sv_ecef_to_eci(
    sv::OrbitStateVector,
    T_ECEF::Val{:ITRF},
    T_ECI::T_ECIs,
    eop::EopIau1980
)
    return sv_ecef_to_eci(sv, Val(:ITRF), T_ECI, sv.t, eop)
end

function sv_ecef_to_eci(
    sv::OrbitStateVector,
    T_ECEF::Val{:ITRF},
    T_ECI::T_ECIs_IAU_2006,
    jd_utc::Number,
    eop::EopIau2000A
)
    # First, convert from the ITRF to TIRS.
    sv_tirs = sv_ecef_to_ecef(sv, Val(:ITRF), Val(:TIRS), jd_utc, eop)

    # Now, convert from TIRS to ECI.
    return sv_ecef_to_eci(sv_tirs, Val(:TIRS), T_ECI, jd_utc, eop)
end

function sv_ecef_to_eci(
    sv::OrbitStateVector,
    T_ECEF::Val{:ITRF},
    T_ECI::T_ECIs_IAU_2006,
    eop::EopIau2000A
)
    return sv_ecef_to_eci(sv, T_ECEF, T_ECI, sv.t, eop)
end

function sv_ecef_to_eci(
    sv::OrbitStateVector,
    T_ECEF::Union{Val{:PEF}, Val{:TIRS}},
    T_ECI::Union{T_ECIs, T_ECIs_IAU_2006},
    jd_utc::Number,
    eop::Union{Nothing, EopIau1980, EopIau2000A} = nothing
)
    # Get the matrix that converts the ECEF to the ECI.
    if eop === nothing
        D = r_ecef_to_eci(DCM, T_ECEF, T_ECI, jd_utc)
    else
        D = r_ecef_to_eci(DCM, T_ECEF, T_ECI, jd_utc, eop)
    end

    # Since the ECI and ECEF frames have a relative velocity between them, then we must
    # account from it when converting the velocity and acceleration. The angular velocity
    # between those frames is computed using `we` and corrected by the length of day (LOD)
    # parameter of the EOP data, if available.
    ω  = EARTH_ANGULAR_SPEED * (1 - (eop !== nothing ? eop.lod(jd_utc) / 86400000 : 0))
    vω = SVector{3}(0, 0, ω)

    # Compute the position in the ECI frame.
    r_eci = D * sv.r

    # Compute the velocity in the ECI frame.
    vω_x_r = vω × sv.r
    v_eci = D * (sv.v + vω_x_r )

    # Compute the acceleration in the ECI frame.
    a_eci = D * (sv.a + vω × vω_x_r + 2vω × sv.v)

    return OrbitStateVector(sv.t, r_eci, v_eci, a_eci)
end

function sv_ecef_to_eci(
    sv::OrbitStateVector,
    T_ECEF::Union{Val{:PEF}, Val{:TIRS}},
    T_ECI::Union{T_ECIs, T_ECIs_IAU_2006},
    eop::Union{Nothing, EopIau1980, EopIau2000A} = nothing
)
    return sv_ecef_to_eci(sv, T_ECEF, T_ECI, sv.t, eop)
end
