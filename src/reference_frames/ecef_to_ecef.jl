## Description #############################################################################
#
# Rotations from an Earth-Centered, Earth-Fixed (ECEF) reference frame to another ECEF
#   reference frame.
#
## References ##############################################################################
#
# [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm Press,
#     Hawthorn, CA, USA.
#
############################################################################################

export r_ecef_to_ecef

"""
    r_ecef_to_ecef([T, ]ECEFo, ECEFf, jd_utc::Number, eop) -> T

Compute the rotation from an Earth-Centered, Earth-Fixed (`ECEF`) reference frame to another
ECEF reference frame at the Julian Day [UTC] `jd_utc`. The rotation description that will be
used is given by `T`, which can be `DCM` or `Quaternion`. The origin ECEF frame is selected
by the input `ECEFo` and the destination ECEF frame is selected by the input `ECEFf`. The
model used to compute the rotation is specified by the selection of the origin and
destination frames. Currently, there are two supported models: IAU-76/FK5 and IAU-2006 with
2010 conventions.

# Rotation description

The rotations that aligns the origin ECEF frame with the destination ECEF frame can be
described by Direction Cosine Matrices or Quaternions. This is selected by the parameter
`T`.

The possible values are:

- `DCM`: The rotation will be described by a Direction Cosine Matrix.
- `Quaternion`: The rotation will be described by a Quaternion.

If no value is specified, then it falls back to `DCM`.

# Conversion model

The model that will be used to compute the rotation is automatically inferred given the
selection of the origin and destination frames. **Notice that mixing IAU-76/FK5 and
IAU-2006/2010 frames is not supported.**

# ECEF Frame

The supported ECEF frames for both origin `ECEFo` and destination `ECEFf` are:

- `ITRF()`: ECEF will be selected as the International Terrestrial Reference Frame (ITRF).
- `PEF()`: ECEF will be selected as the Pseudo-Earth Fixed (PEF) reference frame.
- `TIRS()`: ECEF will be selected as the Terrestrial Intermediate Reference System (TIRS).

# Earth orientation parameters (EOP)

The conversion between the supported ECEF frames **always** depends on EOP (see
[`fetch_iers_eop`](@ref) and [`read_iers_eop`](@ref)). If IAU-76/FK5 model is used, then the
type of `eop` must be [`EopIau1980`](@ref). Otherwise, if IAU-2006/2010 model is used, then
the type of `eop` must be [`EopIau2000A`](@ref).

# Returns

- `T`: The rotation that aligns the ECEF reference frame with the ECI reference frame.

# Examples

```julia-repl
julia> eop_iau1980 = fetch_iers_eop();

julia> r_ecef_to_ecef(PEF(), ITRF(), date_to_jd(1986, 6, 19, 21, 35, 0), eop_IAU1980)
3×3 StaticArrays.SMatrix{3, 3, Float64, 9} with indices SOneTo(3)×SOneTo(3):
  1.0          0.0         -4.34677e-7
 -6.29476e-13  1.0         -1.44815e-6
  4.34677e-7   1.44815e-6   1.0

julia> r_ecef_to_ecef(Quaternion, PEF(), ITRF(), date_to_jd(1986, 6, 19, 21, 35, 0), eop_IAU1980)
Quaternion{Float64}:
  + 1.0 - 7.24073e-7⋅i + 2.17339e-7⋅j + 2.17339e-7⋅k

julia> eop_IAU2000A = fetch_iers_eop(Val(:IAU2000A));

julia> r_ecef_to_ecef(TIRS(), ITRF(), date_to_jd(1986, 6, 19, 21, 35, 0), eop_IAU2000A)
3×3 StaticArrays.SMatrix{3, 3, Float64, 9} with indices SOneTo(3)×SOneTo(3):
  1.0          3.08408e-11  -4.34677e-7
 -3.14703e-11  1.0          -1.44815e-6
  4.34677e-7   1.44815e-6    1.0

julia> r_ecef_to_ecef(Quaternion, TIRS(), ITRF(), date_to_jd(1986, 6, 19, 21, 35, 0), eop_IAU2000A)
Quaternion{Float64}:
  + 1.0 - 7.24073e-7⋅i + 2.17339e-7⋅j + 2.17339e-7⋅k
```
"""
function r_ecef_to_ecef(T_ECEFo::T_ECEFs, T_ECEFf::T_ECEFs, jd_utc::Number, eop::EopIau1980)
    return r_ecef_to_ecef(DCM, T_ECEFo, T_ECEFf, jd_utc, eop)
end

function r_ecef_to_ecef(
    T_ECEFo::T_ECEFs_IAU_2006,
    T_ECEFf::T_ECEFs_IAU_2006,
    jd_utc::Number,
    eop::EopIau2000A
)
    return r_ecef_to_ecef(DCM, T_ECEFo, T_ECEFf, jd_utc, eop)
end

############################################################################################
#                                       IAU-76 / FK5                                       #
############################################################################################

# == ITRF <=> PEF ==========================================================================

function r_ecef_to_ecef(T::T_ROT, ::Val{:ITRF}, ::Val{:PEF}, jd_utc::Number, eop::EopIau1980)
    arcsec_to_rad = π / 648000

    # Get the EOP data related to the desired epoch.
    #
    # TODO: The difference is small, but should it be `JD_TT` or `jd_utc`?
    x_p = eop.x(jd_utc) * arcsec_to_rad
    y_p = eop.y(jd_utc) * arcsec_to_rad

    # Return the rotation.
    return r_itrf_to_pef_fk5(T, x_p, y_p)
end

function r_ecef_to_ecef(
    T::T_ROT,
    T_ECEFo::Val{:PEF},
    T_ECEFf::Val{:ITRF},
    jd_utc::Number,
    eop::EopIau1980
)
    return inv_rotation(r_ecef_to_ecef(T, T_ECEFf, T_ECEFo, jd_utc, eop))
end

############################################################################################
#                                     IAU-2006 / 2010                                      #
############################################################################################

# == ITRF <=> TIRS =========================================================================

function r_ecef_to_ecef(
    T::T_ROT,
    ::Val{:ITRF},
    ::Val{:TIRS},
    jd_utc::Number,
    eop::EopIau2000A
)
    arcsec_to_rad = π / 648000

    # Get the EOP data related to the desired epoch.
    x_p = eop.x(jd_utc) * arcsec_to_rad
    y_p = eop.y(jd_utc) * arcsec_to_rad

    # Return the rotation.
    return r_itrf_to_tirs_iau2006(T, jd_utc, x_p, y_p)
end

function r_ecef_to_ecef(
    T::T_ROT,
    T_ECEFo::Val{:TIRS},
    T_ECEFf::Val{:ITRF},
    jd_utc::Number,
    eop::EopIau2000A
)
    return inv_rotation(r_ecef_to_ecef(T, T_ECEFf, T_ECEFo, jd_utc, eop))
end
