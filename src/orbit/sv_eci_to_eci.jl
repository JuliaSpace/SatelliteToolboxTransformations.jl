## Description #############################################################################
#
# Convert an orbit state vector from an Earth-Centered Inertial (ECI) reference frame to
# another ECI reference frame.
#
## References ##############################################################################
#
# [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm Press,
#     Hawthorn, CA, USA.
#
############################################################################################

export sv_eci_to_eci

"""
    sv_eci_to_eci(sv::OrbitStateVector, ECIo, ECIf[, jd_utc::Number][, eop]) -> OrbitStateVector
    sv_eci_to_eci(sv::OrbitStateVector, ECIo, [jd_utco::Number, ]ECIf[, jd_utcf::Number][, eop]) -> OrbitStateVector

Convert the orbit state vector `sv` from an Earth-Centered Inertial (ECI) reference frame
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

`¹`: TEME is an *of date* frame.

# Returns

- `OrbitStateVector`: Orbit state vector `sv` converted to the `ECIf` reference frame.

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
```
"""

############################################################################################
#                                       IAU-76 / FK5                                       #
############################################################################################

# == GCRF <=> J2000 ========================================================================

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Val{:GCRF},
    T_ECIf::Val{:J2000},
    jd_utc::Number,
    eop::EopIau1980
)
    D = r_eci_to_eci(DCM, T_ECIo, T_ECIf, jd_utc, eop)

    # Since both frames does not have a significant angular velocity between them, we just
    # need to convert the representations.
    return OrbitStateVector(sv.t, D * sv.r, D * sv.v, D * sv.a)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Val{:GCRF},
    T_ECIf::Val{:J2000},
    eop::EopIau1980
)
    return sv_eci_to_eci(sv, T_ECIo, T_ECIf, sv.t, eop)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Val{:J2000},
    T_ECIf::Val{:GCRF},
    jd_utc::Number,
    eop::EopIau1980
)
    D = r_eci_to_eci(DCM, T_ECIo, T_ECIf, jd_utc, eop)

    # Since both frames does not have a significant angular velocity between them, we just
    # need to convert the representations.
    return OrbitStateVector(sv.t, D * sv.r, D * sv.v, D * sv.a)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Val{:J2000},
    T_ECIf::Val{:GCRF},
    eop::EopIau1980
)
    return sv_eci_to_eci(sv, T_ECIo, T_ECIf, sv.t, eop)
end

# == GCRF <=> MOD, TOD, TEME ===============================================================

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Val{:GCRF},
    T_ECIf::Union{Val{:MOD}, Val{:TOD}, Val{:TEME}},
    jd_utc::Number,
    eop::EopIau1980
)
    D = r_eci_to_eci(DCM, T_ECIo, T_ECIf, jd_utc, eop)

    # Since both frames does not have a significant angular velocity between them, we just
    # need to convert the representations.
    return OrbitStateVector(sv.t, D * sv.r, D * sv.v, D * sv.a)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Val{:GCRF},
    T_ECIf::Union{Val{:MOD}, Val{:TOD}, Val{:TEME}},
    eop::EopIau1980
)
    return sv_eci_to_eci(sv, T_ECIo, T_ECIf, sv.t, eop)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Union{Val{:MOD}, Val{:TOD}, Val{:TEME}},
    T_ECIf::Val{:GCRF},
    jd_utc::Number,
    eop::EopIau1980
)
    D = r_eci_to_eci(DCM, T_ECIo, T_ECIf, jd_utc, eop)

    # Since both frames does not have a significant angular velocity between them, we just
    # need to convert the representations.
    return OrbitStateVector(sv.t, D * sv.r, D * sv.v, D * sv.a)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Union{Val{:MOD}, Val{:TOD}, Val{:TEME}},
    T_ECIf::Val{:GCRF},
    eop::EopIau1980
)
    return sv_eci_to_eci(sv, T_ECIo, T_ECIf, sv.t, eop)
end

# == J2000 <=> MOD, TOD, TEME ==============================================================

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Val{:J2000},
    T_ECIf::Union{Val{:MOD}, Val{:TOD}, Val{:TEME}},
    jd_utc::Number,
    eop::EopIau1980
)
    D = r_eci_to_eci(DCM, T_ECIo, T_ECIf, jd_utc, eop)

    # Since both frames does not have a significant angular velocity between them, we just
    # need to convert the representations.
    return OrbitStateVector(sv.t, D * sv.r, D * sv.v, D * sv.a)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Val{:J2000},
    T_ECIf::Union{Val{:MOD}, Val{:TOD}, Val{:TEME}},
    eop::EopIau1980
)
    return sv_eci_to_eci(sv, T_ECIo, T_ECIf, sv.t, eop)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Val{:J2000},
    T_ECIf::Union{Val{:MOD}, Val{:TOD}, Val{:TEME}},
    jd_utc::Number
)
    D = r_eci_to_eci(DCM, T_ECIo, T_ECIf, jd_utc)

    # Since both frames does not have a significant angular velocity between them, we just
    # need to convert the representations.
    return OrbitStateVector(sv.t, D * sv.r, D * sv.v, D * sv.a)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Val{:J2000},
    T_ECIf::Union{Val{:MOD}, Val{:TOD}, Val{:TEME}}
)
    return sv_eci_to_eci(sv, T_ECIo, T_ECIf, sv.t)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Union{Val{:MOD}, Val{:TOD}, Val{:TEME}},
    T_ECIf::Val{:J2000},
    jd_utc::Number,
    eop::EopIau1980
)
    D = r_eci_to_eci(DCM, T_ECIo, T_ECIf, jd_utc, eop)

    # Since both frames does not have a significant angular velocity between them, we just
    # need to convert the representations.
    return OrbitStateVector(sv.t, D * sv.r, D * sv.v, D * sv.a)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Union{Val{:MOD}, Val{:TOD}, Val{:TEME}},
    T_ECIf::Val{:J2000},
    eop::EopIau1980
)
    return sv_eci_to_eci(sv, T_ECIo, T_ECIf, sv.t, eop)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Union{Val{:MOD}, Val{:TOD}, Val{:TEME}},
    T_ECIf::Val{:J2000},
    jd_utc::Number
)
    D = r_eci_to_eci(DCM, T_ECIo, T_ECIf, jd_utc)

    # Since both frames does not have a significant angular velocity between them, we just
    # need to convert the representations.
    return OrbitStateVector(sv.t, D * sv.r, D * sv.v, D * sv.a)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Union{Val{:MOD}, Val{:TOD}, Val{:TEME}},
    T_ECIf::Val{:J2000}
)
    return sv_eci_to_eci(sv, T_ECIo, T_ECIf, sv.t)
end

# == Between MOD, TOD, and TEME ============================================================

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::T_ECIs_of_date,
    jd_utco::Number,
    T_ECIf::T_ECIs_of_date,
    jd_utcf::Number,
    eop::EopIau1980
)
    D = r_eci_to_eci(DCM, T_ECIo, jd_utco, T_ECIf, jd_utcf, eop)

    # Since both frames does not have a significant angular velocity between them, we just
    # need to convert the representations.
    return OrbitStateVector(sv.t, D * sv.r, D * sv.v, D * sv.a)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::T_ECIs_of_date,
    T_ECIf::T_ECIs_of_date,
    eop::EopIau1980
)
    return sv_eci_to_eci(sv, T_ECIo, sv.t, T_ECIf, sv.t, eop)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::T_ECIs_of_date,
    jd_utco::Number,
    T_ECIf::T_ECIs_of_date,
    jd_utcf::Number,
)
    D = r_eci_to_eci(DCM, T_ECIo, jd_utco, T_ECIf, jd_utcf)

    # Since both frames does not have a significant angular velocity between them, we just
    # need to convert the representations.
    return OrbitStateVector(sv.t, D * sv.r, D * sv.v, D * sv.a)
end

function sv_eci_to_eci(sv::OrbitStateVector, T_ECIo::T_ECIs_of_date, T_ECIf::T_ECIs_of_date)
    return sv_eci_to_eci(sv, T_ECIo, sv.t, T_ECIf, sv.t)
end

############################################################################################
#                                IAU-2006 / 2010 CIO-based                                 #
############################################################################################

# == GCRF <=> CIRS =========================================================================

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Val{:GCRF},
    T_ECIf::Val{:CIRS},
    jd_utc::Number,
    eop::EopIau2000A
)
    D = r_eci_to_eci(DCM, T_ECIo, T_ECIf, jd_utc, eop)

    # Since both frames does not have a significant angular velocity between them, we just
    # need to convert the representations.
    return OrbitStateVector(sv.t, D * sv.r, D * sv.v, D * sv.a)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Val{:GCRF},
    T_ECIf::Val{:CIRS},
    eop::EopIau2000A
)
    return sv_eci_to_eci(sv, T_ECIo, T_ECIf, sv.t, eop)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Val{:GCRF},
    T_ECIf::Val{:CIRS},
    jd_utc::Number,
)
    D = r_eci_to_eci(DCM, T_ECIo, T_ECIf, jd_utc)

    # Since both frames does not have a significant angular velocity between them, we just
    # need to convert the representations.
    return OrbitStateVector(sv.t, D * sv.r, D * sv.v, D * sv.a)
end

function sv_eci_to_eci(sv::OrbitStateVector, T_ECIo::Val{:GCRF}, T_ECIf::Val{:CIRS})
    return sv_eci_to_eci(sv, T_ECIo, T_ECIf, sv.t)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Val{:CIRS},
    T_ECIf::Val{:GCRF},
    jd_utc::Number,
    eop::EopIau2000A
)
    D = r_eci_to_eci(DCM, T_ECIo, T_ECIf, jd_utc, eop)

    # Since both frames does not have a significant angular velocity between them, we just
    # need to convert the representations.
    return OrbitStateVector(sv.t, D * sv.r, D * sv.v, D * sv.a)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Val{:CIRS},
    T_ECIf::Val{:GCRF},
    eop::EopIau2000A
)
    return sv_eci_to_eci(sv, T_ECIo, T_ECIf, sv.t, eop)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Val{:CIRS},
    T_ECIf::Val{:GCRF},
    jd_utc::Number,
)
    D = r_eci_to_eci(DCM, T_ECIo, T_ECIf, jd_utc)

    # Since both frames does not have a significant angular velocity between them, we just
    # need to convert the representations.
    return OrbitStateVector(sv.t, D * sv.r, D * sv.v, D * sv.a)
end

function sv_eci_to_eci(sv::OrbitStateVector, T_ECIo::Val{:CIRS}, T_ECIf::Val{:GCRF},)
    return sv_eci_to_eci(sv, T_ECIo, T_ECIf, sv.t)
end

# == Between CIRS ==========================================================================

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Val{:CIRS},
    jd_utco::Number,
    T_ECIf::Val{:CIRS},
    jd_utcf::Number,
    eop::EopIau2000A
)
    D = r_eci_to_eci(DCM, T_ECIo, jd_utco, T_ECIf, jd_utcf, eop)

    # Since both frames does not have a significant angular velocity between them, we just
    # need to convert the representations.
    return OrbitStateVector(sv.t, D * sv.r, D * sv.v, D * sv.a)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Val{:CIRS},
    T_ECIf::Val{:CIRS},
    eop::EopIau2000A
)
    return sv_eci_to_eci(sv, T_ECIo, sv.t, T_ECIf, sv.t, eop)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Val{:CIRS},
    jd_utco::Number,
    T_ECIf::Val{:CIRS},
    jd_utcf::Number
)
    D = r_eci_to_eci(DCM, T_ECIo, jd_utco, T_ECIf, jd_utcf)

    # Since both frames does not have a significant angular velocity between them, we just
    # need to convert the representations.
    return OrbitStateVector(sv.t, D * sv.r, D * sv.v, D * sv.a)
end

function sv_eci_to_eci(sv::OrbitStateVector, T_ECIo::Val{:CIRS}, T_ECIf::Val{:CIRS})
    return sv_eci_to_eci(sv, T_ECIo, sv.t, T_ECIf, sv.t)
end

############################################################################################
#                              IAU-2006 / 2010 Equinox-based                               #
############################################################################################

# == GCRF <=> MJ2000 =======================================================================

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Val{:GCRF},
    T_ECIf::Val{:MJ2000},
    jd_utc::Number,
    eop::EopIau2000A
)
    D = r_eci_to_eci(DCM, T_ECIo, T_ECIf, jd_utc, eop)

    # Since both frames does not have a significant angular velocity between them, we just
    # need to convert the representations.
    return OrbitStateVector(sv.t, D * sv.r, D * sv.v, D * sv.a)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Val{:GCRF},
    T_ECIf::Val{:MJ2000},
    eop::EopIau2000A
)
    return sv_eci_to_eci(sv, T_ECIo, T_ECIf, sv.t, eop)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Val{:GCRF},
    T_ECIf::Val{:MJ2000},
    jd_utc::Number
)
    D = r_eci_to_eci(DCM, T_ECIo, T_ECIf, jd_utc)

    # Since both frames does not have a significant angular velocity between them, we just
    # need to convert the representations.
    return OrbitStateVector(sv.t, D * sv.r, D * sv.v, D * sv.a)
end

function sv_eci_to_eci(sv::OrbitStateVector, T_ECIo::Val{:GCRF}, T_ECIf::Val{:MJ2000})
    return sv_eci_to_eci(sv, T_ECIo, T_ECIf, sv.t)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Val{:MJ2000},
    T_ECIf::Val{:GCRF},
    jd_utc::Number,
    eop::EopIau2000A
)
    D = r_eci_to_eci(DCM, T_ECIo, T_ECIf, jd_utc, eop)

    # Since both frames does not have a significant angular velocity between them, we just
    # need to convert the representations.
    return OrbitStateVector(sv.t, D * sv.r, D * sv.v, D * sv.a)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Val{:MJ2000},
    T_ECIf::Val{:GCRF},
    eop::EopIau2000A
)
    return sv_eci_to_eci(sv, T_ECIo, T_ECIf, sv.t, eop)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Val{:MJ2000},
    T_ECIf::Val{:GCRF},
    jd_utc::Number
)
    D = r_eci_to_eci(DCM, T_ECIo, T_ECIf, jd_utc)

    # Since both frames does not have a significant angular velocity between them, we just
    # need to convert the representations.
    return OrbitStateVector(sv.t, D * sv.r, D * sv.v, D * sv.a)
end

function sv_eci_to_eci(sv::OrbitStateVector, T_ECIo::Val{:MJ2000}, T_ECIf::Val{:GCRF})
    return sv_eci_to_eci(sv, T_ECIo, T_ECIf, sv.t)
end

# == GCRF, MJ2000 <=> MOD, ERS =============================================================

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Union{Val{:MOD06}, Val{:ERS}},
    T_ECIf::Union{Val{:GCRF}, Val{:MJ2000}},
    jd_utc::Number,
    eop::EopIau2000A
)
    D = r_eci_to_eci(DCM, T_ECIo, T_ECIf, jd_utc, eop)

    # Since both frames does not have a significant angular velocity between them, we just
    # need to convert the representations.
    return OrbitStateVector(sv.t, D * sv.r, D * sv.v, D * sv.a)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Union{Val{:MOD06}, Val{:ERS}},
    T_ECIf::Union{Val{:GCRF}, Val{:MJ2000}},
    eop::EopIau2000A
)
    return sv_eci_to_eci(sv, T_ECIo, T_ECIf, sv.t, eop)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Union{Val{:MOD06}, Val{:ERS}},
    T_ECIf::Union{Val{:GCRF}, Val{:MJ2000}},
    jd_utc::Number
)
    D = r_eci_to_eci(DCM, T_ECIo, T_ECIf, jd_utc)

    # Since both frames does not have a significant angular velocity between them, we just
    # need to convert the representations.
    return OrbitStateVector(sv.t, D * sv.r, D * sv.v, D * sv.a)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Union{Val{:MOD06}, Val{:ERS}},
    T_ECIf::Union{Val{:GCRF}, Val{:MJ2000}}
)
    return sv_eci_to_eci(sv, T_ECIo, T_ECIf, sv.t)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Union{Val{:GCRF}, Val{:MJ2000}},
    T_ECIf::Union{Val{:MOD06}, Val{:ERS}},
    jd_utc::Number,
    eop::EopIau2000A
)
    D = r_eci_to_eci(DCM, T_ECIo, T_ECIf, jd_utc, eop)

    # Since both frames does not have a significant angular velocity between them, we just
    # need to convert the representations.
    return OrbitStateVector(sv.t, D * sv.r, D * sv.v, D * sv.a)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Union{Val{:GCRF}, Val{:MJ2000}},
    T_ECIf::Union{Val{:MOD06}, Val{:ERS}},
    eop::EopIau2000A
)
    return sv_eci_to_eci(sv, T_ECIo, T_ECIf, sv.t, eop)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Union{Val{:GCRF}, Val{:MJ2000}},
    T_ECIf::Union{Val{:MOD06}, Val{:ERS}},
    jd_utc::Number
)
    D = r_eci_to_eci(DCM, T_ECIo, T_ECIf, jd_utc)

    # Since both frames does not have a significant angular velocity between them, we just
    # need to convert the representations.
    return OrbitStateVector(sv.t, D * sv.r, D * sv.v, D * sv.a)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::Union{Val{:GCRF}, Val{:MJ2000}},
    T_ECIf::Union{Val{:MOD06}, Val{:ERS}}
)
    return sv_eci_to_eci(sv, T_ECIo, T_ECIf, sv.t)
end

# == Between ERS and MOD ===================================================================

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::T_ECIs_IAU_2006_Equinox_of_date,
    jd_utco::Number,
    T_ECIf::T_ECIs_IAU_2006_Equinox_of_date,
    jd_utcf::Number,
    eop::EopIau2000A
)
    D = r_eci_to_eci(DCM, T_ECIo, jd_utco, T_ECIf, jd_utcf, eop)

    # Since both frames does not have a significant angular velocity between them, we just
    # need to convert the representations.
    return OrbitStateVector(sv.t, D * sv.r, D * sv.v, D * sv.a)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::T_ECIs_IAU_2006_Equinox_of_date,
    T_ECIf::T_ECIs_IAU_2006_Equinox_of_date,
    eop::EopIau2000A
)
    return sv_eci_to_eci(sv, T_ECIo, sv.t, T_ECIf, sv.t, eop)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::T_ECIs_IAU_2006_Equinox_of_date,
    jd_utco::Number,
    T_ECIf::T_ECIs_IAU_2006_Equinox_of_date,
    jd_utcf::Number,
)
    D = r_eci_to_eci(DCM, T_ECIo, jd_utco, T_ECIf, jd_utcf)

    # Since both frames does not have a significant angular velocity between them, we just
    # need to convert the representations.
    return OrbitStateVector(sv.t, D * sv.r, D * sv.v, D * sv.a)
end

function sv_eci_to_eci(
    sv::OrbitStateVector,
    T_ECIo::T_ECIs_IAU_2006_Equinox_of_date,
    T_ECIf::T_ECIs_IAU_2006_Equinox_of_date
)
    return sv_eci_to_eci(sv, T_ECIo, sv.t, T_ECIf, sv.t)
end

