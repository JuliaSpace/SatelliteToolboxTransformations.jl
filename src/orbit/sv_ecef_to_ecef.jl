## Description #############################################################################
#
# Convert an orbit state vector from an Earth-Centered, Earth-Fixed (ECEF) reference frame
# to another ECEF reference frame.
#
## References ##############################################################################
#
# [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm Press,
#     Hawthorn, CA, USA.
#
############################################################################################

export sv_ecef_to_ecef

"""
    sv_ecef_to_ecef(sv::OrbitStateVector, ECEFo, ECEFf[, jd_utc::Number], eop) -> OrbitStateVector

Convert the orbit state vector `sv` from an Earth-Centered, Earth-Fixed (ECEF) reference
frame `ECEFo` to another ECEF reference frame `ECEFf` at the Julian Day `jd_utc` [UTC]. If
the epoch `jd_utc` is not provided, the algorithm will use the epoch of the orbit state
vector `sv` (`sv.t`). The algorithm also requires the Earth Orientation Parameters (EOP)
`eop`.

!!! note

    For more information, including how to specify the origin and destination reference
    frames, see the **Extended Help**.

# Returns

- `OrbitStateVector`: The orbit state vector `sv` converted to the `ECEFf` reference frame.

# Extended Help

## Conversion Model

The model that will be used to compute the rotation is automatically inferred given the
selection of the origin and destination frames. **Notice that mixing IAU-76/FK5 and
IAU-2006/2010 frames is not supported.**

## Supported ECEF Reference Frames

The supported ECEF frames for both origin `ECEFo` and destination `ECEFf` are:

- `ITRF()`: ECEF will be selected as the International Terrestrial Reference Frame (ITRF).
- `PEF()`: ECEF will be selected as the Pseudo-Earth Fixed (PEF) reference frame
    (IAU-76/FK5).
- `TIRS()`: ECEF will be selected as the Terrestrial Intermediate Reference System (TIRS)
    (IAU-2006/2010).

## Earth Orientation Parameters (EOP)

The conversion between the supported ECEF frames **always** depends on EOP (see
[`fetch_iers_eop`](@ref) and [`read_iers_eop`](@ref)). If IAU-76/FK5 model is used, the type
of `eop` must be [`EopIau1980`](@ref). Otherwise, if IAU-2006/2010 model is used, the type
of `eop` must be [`EopIau2000A`](@ref).

## Examples

```julia-repl
julia> eop_iau1980 = fetch_iers_eop();

julia> jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
2.453101827411875e6

julia> r_itrf  = [-1033.4793830; 7901.2952754; 6380.3565958] * 1000;

julia> v_itrf  = [-3.225636520; -2.872451450; +5.531924446] * 1000;

julia> sv_itrf = OrbitStateVector(jd_utc, r_itrf, v_itrf);

julia> sv_ecef_to_ecef(sv_itrf, ITRF(), PEF(), eop_iau1980)
OrbitStateVector{Float64, Float64}:
  epoch : 2.4531e6 (2004-04-06T07:51:28.386)
      r : [-1033.48, 7901.31, 6380.34]   km
      v : [-3.22563, -2.87244, 5.53193]  km/s
```
"""
function sv_ecef_to_ecef(
    sv::OrbitStateVector,
    T_ECEFo::T_ECEFs,
    T_ECEFf::T_ECEFs,
    jd_utc::Number,
    eop::EopIau1980
)
    D = r_ecef_to_ecef(DCM, T_ECEFo, T_ECEFf, jd_utc, eop)

    # Since both frames does not have a significant angular velocity between
    # them, then we just need to convert the representations.
    return OrbitStateVector(sv.t, D * sv.r, D * sv.v, D * sv.a)
end

function sv_ecef_to_ecef(
    sv::OrbitStateVector,
    T_ECEFo::T_ECEFs,
    T_ECEFf::T_ECEFs,
    eop::EopIau1980
)
    return sv_ecef_to_ecef(sv, T_ECEFo, T_ECEFf, sv.t, eop)
end

function sv_ecef_to_ecef(
    sv::OrbitStateVector,
    T_ECEFo::T_ECEFs_IAU_2006,
    T_ECEFf::T_ECEFs_IAU_2006,
    jd_utc::Number,
    eop::EopIau2000A
)
    D = r_ecef_to_ecef(DCM, T_ECEFo, T_ECEFf, jd_utc, eop)

    # Since both frames does not have a significant angular velocity between
    # them, then we just need to convert the representations.
    return OrbitStateVector(sv.t, D * sv.r, D * sv.v, D * sv.a)
end

function sv_ecef_to_ecef(
    sv::OrbitStateVector,
    T_ECEFo::T_ECEFs_IAU_2006,
    T_ECEFf::T_ECEFs_IAU_2006,
    eop::EopIau2000A
)
    return sv_ecef_to_ecef(sv, T_ECEFo, T_ECEFf, sv.t, eop)
end
