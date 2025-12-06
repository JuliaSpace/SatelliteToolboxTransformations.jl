## Description #############################################################################
#
# Convert an orbit state vector from an Earth-Centered Inertial (ECI) reference frame to an
# Earth-Centered, Earth-Fixed (ECEF) reference frame.
#
## References ##############################################################################
#
# [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm Press,
#     Hawthorn, CA, USA.
#
############################################################################################

export sv_eci_to_ecef

"""
    sv_eci_to_ecef(sv::OrbitStateVector, ECI, ECEF[, jd_utc][, eop]) -> OrbitStateVector

Compute the orbit state vector `sv` from an Earth-Centered Inertial (`ECI`) reference frame
to an Earth-Centered, Earth-Fixed (`ECEF`) reference frame at the Julian Day `jd_utc` [UTC].
If the epoch `jd_utc` is not provided, the algorithm will use the epoch of the orbit state
vector `sv` (`sv.t`). The algorithm might also require the Earth Orientation Parameters
(EOP) `eop` depending on the source and destination frames.

It is assumed that the input velocity and acceleration in `sv` are obtained by an observer
on the ECI frame. Thus, the output will contain the velocity and acceleration as measured by
an observer on the ECEF frame.

!!! note

    For more information, including how to specify the origin and destination reference
    frames, see the **Extended Help**.

# Returns

- `OrbitStateVector`: Orbit state vector `sv` converted to the `ECI` reference frame.

# Extended Help

## Conversion model

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

julia> jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009);

julia> r_gcrf = [5102.50895790; 6123.01140070; 6378.13692820] * 1000;

julia> v_gcrf = [-4.7432201570; 0.7905364970; 5.5337557270] * 1000;

julia> sv_gcrf = OrbitStateVector(jd_utc, r_gcrf, v_gcrf)
OrbitStateVector{Float64, Float64}:
  epoch : 2.4531e6 (2004-04-06T07:51:28.386)
      r : [5102.51, 6123.01, 6378.14]    km
      v : [-4.74322, 0.790536, 5.53376]  km/s

julia> sv_itrf = sv_eci_to_ecef(sv_gcrf, GCRF(), ITRF(), eop_iau1980)
OrbitStateVector{Float64, Float64}:
  epoch : 2.4531e6 (2004-04-06T07:51:28.386)
      r : [-1033.48, 7901.3, 6380.36]    km
      v : [-3.22564, -2.87245, 5.53192]  km/s

julia> eop_iau2000a = fetch_iers_eop(Val(:IAU2000A));

julia> sv_tirs = sv_eci_to_ecef(sv_gcrf, GCRF(), TIRS(), eop_iau2000a)
OrbitStateVector{Float64, Float64}:
  epoch : 2.4531e6 (2004-04-06T07:51:28.386)
      r : [-1033.48, 7901.31, 6380.34]   km
      v : [-3.22563, -2.87244, 5.53193]  km/s
```
"""
function sv_eci_to_ecef(
    sv::OrbitStateVector,
    T_ECI::T_ECIs,
    T_ECEF::Val{:ITRF},
    jd_utc::Number,
    eop::EopIau1980
)
    # First, convert from ECI to PEF.
    sv_pef = sv_eci_to_ecef(sv, T_ECI, Val(:PEF), jd_utc, eop)

    # Now, convert from PEF to ITRF.
    return sv_ecef_to_ecef(sv_pef, Val(:PEF), Val(:ITRF), jd_utc, eop)
end

function sv_eci_to_ecef(
    sv::OrbitStateVector,
    T_ECI::T_ECIs,
    T_ECEF::Val{:ITRF},
    eop::EopIau1980
)
    return sv_eci_to_ecef(sv, T_ECI, T_ECEF, sv.t, eop)
end

function sv_eci_to_ecef(
    sv::OrbitStateVector,
    T_ECI::T_ECIs_IAU_2006,
    T_ECEF::Val{:ITRF},
    jd_utc::Number,
    eop::EopIau2000A
)
    # First, convert from ECI to TIRS.
    sv_tirs = sv_eci_to_ecef(sv, T_ECI, Val(:TIRS), jd_utc, eop)

    # Now, convert from TIRS to ITRF.
    return sv_ecef_to_ecef(sv_tirs, Val(:TIRS), Val(:ITRF), jd_utc, eop)
end

function sv_eci_to_ecef(
    sv::OrbitStateVector,
    T_ECI::T_ECIs_IAU_2006,
    T_ECEF::Val{:ITRF},
    eop::EopIau2000A
)
    return sv_eci_to_ecef(sv, T_ECI, T_ECEF, sv.t, eop)
end

# == ECI to PEF (IAU-76/FK5) ===============================================================

# GCRF to PEF requires EOP data.
function sv_eci_to_ecef(
    sv::OrbitStateVector,
    T_ECI::Val{:GCRF},
    T_ECEF::Val{:PEF},
    jd_utc::Number,
    eop::EopIau1980
)
    D = r_eci_to_ecef(DCM, T_ECI, T_ECEF, jd_utc, eop)

    ω  = EARTH_ANGULAR_SPEED * (1 - eop.lod(jd_utc) / 86400000)
    vω = SVector{3}(0, 0, ω)

    r_ecef = D * sv.r
    vω_x_r = vω × r_ecef
    v_ecef = D * sv.v - vω_x_r
    a_ecef = D * sv.a - vω × vω_x_r - 2vω × v_ecef

    return OrbitStateVector(sv.t, r_ecef, v_ecef, a_ecef)
end

function sv_eci_to_ecef(
    sv::OrbitStateVector,
    T_ECI::Val{:GCRF},
    T_ECEF::Val{:PEF},
    eop::EopIau1980
)
    return sv_eci_to_ecef(sv, T_ECI, T_ECEF, sv.t, eop)
end

# J2000/MOD/TOD/TEME to PEF does not require EOP data.
function sv_eci_to_ecef(
    sv::OrbitStateVector,
    T_ECI::Union{Val{:J2000}, Val{:MOD}, Val{:TOD}, Val{:TEME}},
    T_ECEF::Val{:PEF},
    jd_utc::Number,
    eop::Union{Nothing, EopIau1980} = nothing
)
    if eop === nothing
        D = r_eci_to_ecef(DCM, T_ECI, T_ECEF, jd_utc)
    else
        D = r_eci_to_ecef(DCM, T_ECI, T_ECEF, jd_utc, eop)
    end

    ω  = EARTH_ANGULAR_SPEED * (1 - (eop !== nothing ? eop.lod(jd_utc) / 86400000 : 0))
    vω = SVector{3}(0, 0, ω)

    r_ecef = D * sv.r
    vω_x_r = vω × r_ecef
    v_ecef = D * sv.v - vω_x_r
    a_ecef = D * sv.a - vω × vω_x_r - 2vω × v_ecef

    return OrbitStateVector(sv.t, r_ecef, v_ecef, a_ecef)
end

function sv_eci_to_ecef(
    sv::OrbitStateVector,
    T_ECI::Union{Val{:J2000}, Val{:MOD}, Val{:TOD}, Val{:TEME}},
    T_ECEF::Val{:PEF},
    eop::Union{Nothing, EopIau1980} = nothing
)
    return sv_eci_to_ecef(sv, T_ECI, T_ECEF, sv.t, eop)
end

# == ECI to TIRS (IAU-2006/2010) ===========================================================

function sv_eci_to_ecef(
    sv::OrbitStateVector,
    T_ECI::T_ECIs_IAU_2006,
    T_ECEF::Val{:TIRS},
    jd_utc::Number,
    eop::Union{Nothing, EopIau2000A} = nothing
)
    # Get the matrix that converts the ECI to the ECEF.
    if eop === nothing
        D = r_eci_to_ecef(DCM, T_ECI, T_ECEF, jd_utc)
    else
        D = r_eci_to_ecef(DCM, T_ECI, T_ECEF, jd_utc, eop)
    end

    # Since the ECI and ECEF frames have a relative velocity between them, then we must
    # account from it when converting the velocity and acceleration. The angular velocity
    # between those frames is computed using `we` and corrected by the length of day (LOD)
    # parameter of the EOP data, if available.
    ω  = EARTH_ANGULAR_SPEED * (1 - (eop !== nothing ? eop.lod(jd_utc) / 86400000 : 0))
    vω = SVector{3}(0, 0, ω)

    # Compute the position in the ECEF frame.
    r_ecef = D * sv.r

    # Compute the velocity in the ECEF frame.
    vω_x_r = vω × r_ecef
    v_ecef = D * sv.v - vω_x_r

    # Compute the acceleration in the ECI frame.
    a_ecef = D * sv.a - vω × vω_x_r - 2vω × v_ecef

    return OrbitStateVector(sv.t, r_ecef, v_ecef, a_ecef)
end

function sv_eci_to_ecef(
    sv::OrbitStateVector,
    T_ECI::T_ECIs_IAU_2006,
    T_ECEF::Val{:TIRS},
    eop::Union{Nothing, EopIau2000A} = nothing
)
    return sv_eci_to_ecef(sv, T_ECI, T_ECEF, sv.t, eop)
end
