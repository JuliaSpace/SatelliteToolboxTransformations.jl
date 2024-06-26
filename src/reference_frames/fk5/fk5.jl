## Description #############################################################################
#
# Functions related with the model IAU-76/FK5.
#
## References ##############################################################################
#
# [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm Press,
#     Hawthorn, CA, USA.
#
# [2] Gontier, A. M., Capitaine, N (1991). High-Accuracy Equation of Equinoxes and VLBI
#     Astrometric Modelling. Radio Interferometry: Theory, Techniques and Applications, IAU
#     Coll. 131, ASP Conference Series, Vol. 19.
#
############################################################################################

export r_itrf_to_pef_fk5, r_pef_to_itrf_fk5
export r_pef_to_tod_fk5,  r_tod_to_pef_fk5
export r_tod_to_mod_fk5,  r_mod_to_tod_fk5
export r_mod_to_gcrf_fk5, r_gcrf_to_mod_fk5

export r_itrf_to_gcrf_fk5, r_gcrf_to_itrf_fk5
export r_pef_to_mod_fk5,   r_mod_to_pef_fk5

############################################################################################
#                                 IAU-76 / FK5 Reductions                                  #
############################################################################################
#
# The conversion between the Geocentric Celestial Reference Frame (GCRF) to the
# International Terrestrial Reference Frame (ITRF) is done by means of:
#
#                          GCRF <=> MOD <=> TOD <=> PEF <=> ITRF
#
# in which:
#   - MOD: Mean of Date frame.
#   - TOD: True of Date frame.
#   - PEF: Pseudo-Earth fixed frame.
#
# Every rotation will be coded as a function using the IAU-76/FK5 theory. Additionally,
# composed rotations will also available. In general, the API is:
#
#   function r_<Origin Frame>_to_<Destination Frame>_fk5
#
# The arguments vary depending on the origin and destination frame and should be verified
# using the function documentation.
#
############################################################################################

############################################################################################
#                                     Single Rotations                                     #
############################################################################################

# == ITRF <=> PEF ==========================================================================

"""
    r_itrf_to_pef_fk5([T, ]x_p::Number, y_p::Number) -> T

Compute the rotation that aligns the International Terrestrial Reference Frame (ITRF) with
the Pseudo-Earth Fixed (PEF) frame considering the polar motion represented by the angles
`x_p` [rad] and `y_p` [rad] that are obtained from IERS EOP Data (see
[`fetch_iers_eop`](@ref)).

`x_p` is the polar motion displacement about X-axis, which is the IERS Reference Meridian
direction (positive south along the 0˚ longitude meridian). `y_p` is the polar motion
displacement about Y-axis (90˚W or 270˚E meridian).

The rotation type is described by the optional variable `T`. If it is `DCM`, then a DCM will
be returned. Otherwise, if it is `Quaternion`, then a Quaternion will be returned. In case
this parameter is omitted, then it falls back to `DCM`.

# Returns

- `T`: The rotation that aligns the ITRF frame with the PEF frame.

# Remarks

The ITRF is defined based on the International Reference Pole (IRP), which is the location
of the terrestrial pole agreed by international committees **[1]**.  The Pseudo-Earth Fixed,
on the other hand, is defined based on the Earth axis of rotation, or the Celestial
Intermediate Pole (CIP). Hence, PEF XY-plane contains the True Equator. Furthermore, since
the recovered latitude and longitude are sensitive to the CIP, then it should be computed
considering the PEF frame.

# References

- **[1]**: Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm
    Press, Hawthorn, CA, USA.
"""
r_itrf_to_pef_fk5(x_p::Number, y_p::Number) = r_itrf_to_pef_fk5(DCM, x_p, y_p)

function r_itrf_to_pef_fk5(T::Type, x_p::Number, y_p::Number)
    # Notice that `x_p` and `y_p` are displacements in X and Y directions and **not**
    # rotation angles. Hence, a displacement in X is a rotation in Y and a displacement in Y
    # is a rotation in X.
    return smallangle_to_rot(T, +y_p, +x_p, 0)
end

"""
    r_pef_to_itrf_fk5([T, ]x_p::Number, y_p::Number) -> T

Compute the rotation that aligns the Pseudo-Earth Fixed (PEF) with the International
Terrestrial Reference Frame (ITRF) considering the polar motion represented by the angles
`x_p` [rad] and `y_p` [rad] that are obtained from IERS EOP Data (see
[`fetch_iers_eop`](@ref)).

`x_p` is the polar motion displacement about X-axis, which is the IERS Reference Meridian
direction (positive south along the 0˚ longitude meridian). `y_p` is the polar motion
displacement about Y-axis (90˚W or 270˚E meridian).

The rotation type is described by the optional variable `T`. If it is `DCM`, then a DCM will
be returned. Otherwise, if it is `Quaternion`, then a Quaternion will be returned. In case
this parameter is omitted, then it falls back to `DCM`.

# Returns

- `T`: The rotation that aligns the PEF frame with the ITRF.

# Remarks

The ITRF is defined based on the International Reference Pole (IRP), which is the location
of the terrestrial pole agreed by international committees **[1]**.  The Pseudo-Earth Fixed,
on the other hand, is defined based on the Earth axis of rotation, or the Celestial
Intermediate Pole (CIP). Hence, PEF XY-plane contains the True Equator. Furthermore, since
the recovered latitude and longitude are sensitive to the CIP, then it should be computed
considering the PEF frame.

# References

- **[1]**: Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm
    Press, Hawthorn, CA, USA.
"""
r_pef_to_itrf_fk5(x_p::Number, y_p::Number) = r_pef_to_itrf_fk5(DCM, x_p, y_p)

function r_pef_to_itrf_fk5(T::Type, x_p::Number, y_p::Number)
    # Notice that `x_p` and `y_p` are displacements in X and Y directions and **not**
    # rotation angles. Hence, a displacement in X is a rotation in Y and a displacement in Y
    # is a rotation in X.
    return smallangle_to_rot(T, -y_p, -x_p, 0)
end

# == PEF <=> TOD ===========================================================================

"""
    r_pef_to_tod_fk5([T, ]jd_ut1::Number, jd_tt::Number[, δΔψ_1980::Number]) -> T

Compute the rotation that aligns the Pseudo-Earth Fixed (PEF) frame with the True of Date
(TOD) frame at the Julian Day `jd_ut1` [UT1] and `jd_tt` [Terrestrial Time]. This algorithm
uses the IAU-76/FK5 theory. Notice that one can provide correction for the nutation in
longitude (`δΔψ_1980`) [rad] that is usually obtained from IERS EOP Data (see
[`fetch_iers_eop`](@ref)).

The Julian Day in UT1 is used to compute the Greenwich Mean Sidereal Time (GMST) (see
`jd_to_gmst`), whereas the Julian Day in Terrestrial Time is used to compute the nutation in
the longitude. Notice that the Julian Day in UT1 and in Terrestrial Time must be equivalent,
i.e. must be related to the same instant.  This function **does not** check this.

The rotation type is described by the optional variable `T`. If it is `DCM`, then a DCM will
be returned. Otherwise, if it is `Quaternion`, then a Quaternion will be returned. In case
this parameter is omitted, then it falls back to `DCM`.

# Returns

- `T`: The rotation that aligns the PEF frame with the TOD frame.

# Remarks

The Pseudo-Earth Fixed (PEF) frame is rotated into the True of Date (TOD) frame considering
the 1980 IAU Theory of Nutation. The IERS EOP corrections must be added if one wants to make
the rotation consistent with the Geocentric Celestial Reference Systems (GCRS).
"""
function r_pef_to_tod_fk5(jd_ut1::Number, jd_tt::Number, δΔψ_1980::Number = 0)
    return r_pef_to_tod_fk5(DCM, jd_ut1, jd_tt, δΔψ_1980)
end

function r_pef_to_tod_fk5(T::Type, jd_ut1::Number, jd_tt::Number, δΔψ_1980::Number = 0)
    # Compute the nutation in the Julian Day (Terrestrial Time) `jd_tt`.
    mϵ_1980, Δϵ_1980, Δψ_1980 = nutation_fk5(jd_tt)

    # Add the corrections to the nutation in obliquity and longitude.
    Δψ_1980 += δΔψ_1980

    # Evaluate the Delaunay parameters associated with the Moon in the interval
    # [0,2π]°.
    #
    # The parameters here were updated as stated in the errata [2].
    t_tt = (jd_tt - JD_J2000) / 36525
    r    = 360
    Ω_m  = @evalpoly(
        t_tt,
        + 125.04452222,
        - (5r + 134.1362608),
        + 0.0020708,
        + 2.2e-6
    )
    Ω_m = mod(Ω_m, 360) * π / 180

    # Compute the equation of Equinoxes.
    #
    # According to [2], the constant unit before `sin(2Ω_m)` is also in [rad].
    Eq_equinox1982 = Δψ_1980 * cos(mϵ_1980) +
        (0.002640sin(1Ω_m) + 0.000063sin(2Ω_m) ) * π / 648000

    # Compute the Mean Greenwich Sidereal Time.
    θ_gmst = jd_to_gmst(jd_ut1)

    # Compute the Greenwich Apparent Sidereal Time (GAST).
    #
    # TODO: Should GAST be moved to a new function as the GMST?
    θ_gast = θ_gmst + Eq_equinox1982

    # Compute the rotation matrix.
    return angle_to_rot(T, -θ_gast, 0, 0, :ZYX)
end

"""
    r_tod_to_pef_fk5([T, ]jd_ut1::Number, jd_tt::Number[, δΔψ_1980::Number]) -> T

Compute the rotation that aligns the True of Date (TOD) frame with the Pseudo-Earth Fixed
(PEF) frame at the Julian Day `jd_ut1` [UT1] and `jd_tt` [Terrestrial Time]. This algorithm
uses the IAU-76/FK5 theory. Notice that one can provide correction for the nutation in
longitude (`δΔψ_1980`) [rad] that is usually obtained from IERS EOP Data (see
[`fetch_iers_eop`](@ref)).

The Julian Day in UT1 is used to compute the Greenwich Mean Sidereal Time (GMST) (see
`jd_to_gmst`), whereas the Julian Day in Terrestrial Time is used to compute the nutation in
the longitude. Notice that the Julian Day in UT1 and in Terrestrial Time must be equivalent,
i.e. must be related to the same instant.  This function **does not** check this.

The rotation type is described by the optional variable `T`. If it is `DCM`, then a DCM will
be returned. Otherwise, if it is `Quaternion`, then a Quaternion will be returned. In case
this parameter is omitted, then it falls back to `DCM`.

# Returns

- `T`: The rotation that aligns the TOD frame with the PEF frame.

# Remarks

The True of Date (TOD) frame is rotated into the Pseudo-Earth Fixed (PEF) frame considering
the 1980 IAU Theory of Nutation. The IERS EOP corrections must be added if one wants to make
the rotation consistent with the Geocentric Celestial Reference Systems (GCRS).
"""
function r_tod_to_pef_fk5(jd_ut1::Number, jd_tt::Number, δΔψ_1980::Number = 0)
    return r_tod_to_pef_fk5(DCM, jd_ut1, jd_tt, δΔψ_1980)
end

function r_tod_to_pef_fk5(T::T_ROT, jd_ut1::Number, jd_tt::Number, δΔψ_1980::Number = 0)
    return inv_rotation(r_pef_to_tod_fk5(T, jd_ut1, jd_tt, δΔψ_1980))
end

# == TOD <=> MOD ===========================================================================

"""
    r_tod_to_mod_fk5([T, ]jd_tt::Number[, δΔϵ_1980::Number, δΔψ_1980::Number]) -> T

Compute the rotation that aligns the True of Date (TOD) frame with the Mean of Date (MOD)
frame at the Julian Day `jd_tt` [Terrestrial Time]. This algorithm uses the IAU-76/FK5
theory. Notice that one can provide corrections for the nutation in obliquity (`δΔϵ_1980`)
[rad] and in longitude (`δΔψ_1980`) [rad] that are usually obtained from IERS EOP Data (see
[`fetch_iers_eop`](@ref)).

The rotation type is described by the optional variable `T`. If it is `DCM`, then a DCM will
be returned. Otherwise, if it is `Quaternion`, then a Quaternion will be returned. In case
this parameter is omitted, then it falls back to `DCM`.

# Returns

- `T`: The rotation that aligns the TOD frame with the MOD frame.

# Remarks

The True of Date (TOD) frame is rotated into the Mean of Date (MOD) frame considering the
1980 IAU Theory of Nutation. The IERS EOP corrections must be added if one wants to make the
rotation consistent with the Geocentric Celestial Reference Systems (GCRS).
"""
function r_tod_to_mod_fk5(jd_tt::Number, δΔϵ_1980::Number = 0, δΔψ_1980::Number = 0)
    return r_tod_to_mod_fk5(DCM, jd_tt, δΔϵ_1980, δΔψ_1980)
end

function r_tod_to_mod_fk5(T::Type, jd_tt::Number, δΔϵ_1980::Number = 0, δΔψ_1980::Number = 0)
    # Compute the nutation in the Julian Day (Terrestrial Time) `jd_tt`.
    mϵ_1980, Δϵ_1980, Δψ_1980 = nutation_fk5(jd_tt)

    # Add the corrections to the nutation in obliquity and longitude.
    Δϵ_1980 += δΔϵ_1980
    Δψ_1980 += δΔψ_1980

    # Compute the obliquity.
    ϵ_1980 = mϵ_1980 + Δϵ_1980

    # Compute and return the Direction Cosine DCM.
    return angle_to_rot(T, ϵ_1980, Δψ_1980, -mϵ_1980, :XZX)
end

"""
    r_mod_to_tod_fk5([T, ]jd_tt::Number[, δΔϵ_1980::Number, δΔψ_1980::Number]) -> T

Compute the rotation that aligns the Mean of Date (MOD) frame with the True of Date (TOD)
frame at the Julian Day `jd_tt` [Terrestrial Time]. This algorithm uses the IAU-76/FK5
theory. Notice that one can provide corrections for the nutation in obliquity (`δΔϵ_1980`)
[rad] and in longitude (`δΔψ_1980`) [rad] that are usually obtained from IERS EOP Data (see
[`fetch_iers_eop`](@ref)).

The rotation type is described by the optional variable `T`. If it is `DCM`, then a DCM will
be returned. Otherwise, if it is `Quaternion`, then a Quaternion will be returned. In case
this parameter is omitted, then it falls back to `DCM`.

# Returns

- `T`: The rotation that aligns the MOD frame with the TOD frame.

# Remarks

The Mean of Date (MOD) frame is rotated into the True of Date (TOD) frame considering the
1980 IAU Theory of Nutation. The IERS EOP corrections must be added if one wants to make the
rotation consistent with the Geocentric Celestial Reference Systems (GCRS).
"""
function r_mod_to_tod_fk5(jd_tt::Number, δΔϵ_1980::Number = 0, δΔψ_1980::Number = 0)
    return r_mod_to_tod_fk5(DCM, jd_tt, δΔϵ_1980, δΔψ_1980)
end

function r_mod_to_tod_fk5(T::T_ROT, jd_tt::Number, δΔϵ_1980::Number = 0, δΔψ_1980::Number = 0)
    return inv_rotation(r_tod_to_mod_fk5(T, jd_tt, δΔϵ_1980, δΔψ_1980))
end

# == MOD <=> GCRF ==========================================================================

"""
    r_mod_to_gcrf_fk5([T, ]jd_tt::Number) -> T

Compute the rotation that aligns the Mean of Date (MOD) frame with the Geocentric Celestial
Reference Frame (GCRF) at the Julian Day [Terrestrial Time] `jd_tt`. This algorithm uses the
IAU-76/FK5 theory.

The rotation type is described by the optional variable `T`. If it is `DCM`, then a DCM will
be returned. Otherwise, if it is `Quaternion`, then a Quaternion will be returned. In case
this parameter is omitted, then it falls back to `DCM`.

# Returns

- `T`: The rotation that aligns the MOD frame with the GCRF frame.

# Remarks

The Mean of Date (MOD) frame is rotated into the Geocentric Celestial Reference Frame (GCRF)
considering the IAU 1976 Precession model.

Notice that if the conversion `TOD => MOD` is performed **without** considering the EOP
corrections, then the GCRF obtained by this rotation is what is usually called the J2000
reference frame.
"""
r_mod_to_gcrf_fk5(jd_tt::Number) = r_mod_to_gcrf_fk5(DCM,jd_tt)

function r_mod_to_gcrf_fk5(T::Type, jd_tt::Number)
    ζ, Θ, z = precession_fk5(jd_tt)
    return angle_to_rot(T, z, -Θ, ζ, :ZYZ)
end

"""
    r_gcrf_to_mod_fk5([T, ]jd_tt::Number) -> T

Compute the rotation that aligns the Geocentric Celestial Reference Frame (GCRF) with the
Mean of Date (MOD) frame at the Julian Day [Terrestrial Time] `jd_tt`.  This algorithm uses
the IAU-76/FK5 theory.

The rotation type is described by the optional variable `T`. If it is `DCM`, then a DCM will
be returned. Otherwise, if it is `Quaternion`, then a Quaternion will be returned. In case
this parameter is omitted, then it falls back to `DCM`.

# Returns

- `T`: The rotation that aligns the GCRF frame with the MOD frame.

# Remarks

The Geocentric Celestial Reference Frame (GCRF) is rotated into the Mean of Date (MOD) frame
considering the IAU 1976 Precession model.

Notice that if the conversion `MOD => TOD` is performed **without** considering the EOP
corrections, then the GCRF in this rotation is what is usually called the J2000 reference
frame.
"""
r_gcrf_to_mod_fk5(jd_tt::Number) = r_gcrf_to_mod_fk5(DCM,jd_tt)

r_gcrf_to_mod_fk5(T::T_ROT, jd_tt::Number) = inv_rotation(r_mod_to_gcrf_fk5(T, jd_tt))

############################################################################################
#                                    Multiple Rotations                                    #
############################################################################################

# The functions with multiple rotations must be added only in two cases:
#
#   - ITRF <=> GCRF (Full rotation between ECI and ECEF).
#   - When the it will decrease the computational burden compared to calling the functions
#     with the single rotations.
#

# == ITRF <=> GCRF =========================================================================

"""
    r_itrf_to_gcrf_fk5([T, ]jd_ut1::Number, jd_tt::Number, x_p::Number, y_p::Number[, δΔϵ_1980::Number, δΔψ_1980::Number]) -> T

Compute the rotation that aligns the International Terrestrial Reference Frame (ITRF) with
the Geocentric Celestial Reference Frame (GCRF) at the Julian Day `jd_ut1` [UT1] and `jd_tt`
[Terrestrial Time], and considering the IERS EOP Data `x_p` [rad], `y_p` [rad], `δΔϵ_1980`
[rad], and `δΔψ_1980` [rad] \\(see [`fetch_iers_eop`](@ref)). This algorithm uses the
IAU-76/FK5 theory.

`x_p` is the polar motion displacement about X-axis, which is the IERS Reference Meridian
direction (positive south along the 0˚ longitude meridian). `y_p` is the polar motion
displacement about Y-axis (90˚W or 270˚E meridian). `δΔϵ_1980` is the nutation in obliquity.
`δΔψ_1980` is the nutation in longitude.

The Julian Day in UT1 is used to compute the Greenwich Mean Sidereal Time (GMST) (see
`jd_to_gmst`), whereas the Julian Day in Terrestrial Time is used to compute the nutation in
the longitude. Notice that the Julian Day in UT1 and in Terrestrial Time must be equivalent,
i.e. must be related to the same instant.  This function **does not** check this.

The rotation type is described by the optional variable `T`. If it is `DCM`, then a DCM will
be returned. Otherwise, if it is `Quaternion`, then a Quaternion will be returned. In case
this parameter is omitted, then it falls back to `DCM`.

# Returns

- `T`: The rotation that aligns the ITRF frame with the GCRF frame.

# Remarks

The EOP data related to the polar motion (`x_p` and `y_p`) is required, since this is the
only way available to compute the conversion ITRF <=> PEF (the models are highly imprecise
since the motion is still not very well understood **[1]**). However, the EOP data related
to the nutation of the obliquity (`δΔϵ_1980`) and the nutation of the longitude (`δΔψ_1980`)
can be omitted. In this case, the GCRF frame is what is usually called J2000 reference
frame.

# References

- **[1]**: Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications.  Microcosm
    Press, Hawthorn, CA, USA.
"""
function r_itrf_to_gcrf_fk5(
    jd_ut1::Number,
    jd_tt::Number,
    x_p::Number,
    y_p::Number,
    δΔϵ_1980::Number = 0,
    δΔψ_1980::Number = 0
)
    return r_itrf_to_gcrf_fk5(DCM, jd_ut1, jd_tt, x_p, y_p, δΔϵ_1980, δΔψ_1980)
end

function r_itrf_to_gcrf_fk5(
    T::Type,
    jd_ut1::Number,
    jd_tt::Number,
    x_p::Number,
    y_p::Number,
    δΔϵ_1980::Number = 0,
    δΔψ_1980::Number = 0
)
    # Compute the rotation ITRF => PEF.
    r_pef_itrf = r_itrf_to_pef_fk5(T, x_p, y_p)

    # Compute the rotation PEF => MOD.
    r_mod_pef = r_pef_to_mod_fk5(T, jd_ut1, jd_tt, δΔϵ_1980, δΔψ_1980)

    # Compute the rotation MOD => GCRF.
    r_gcrf_mod = r_mod_to_gcrf_fk5(T, jd_tt)

    # Return the full rotation.
    return compose_rotation(r_pef_itrf, r_mod_pef, r_gcrf_mod)
end

"""
    r_gcrf_to_itrf_fk5([T, ]jd_ut1::Number, jd_tt::Number, x_p::Number, y_p::Number[, δΔϵ_1980::Number, δΔψ_1980::Number]) -> T

Compute the rotation that aligns the Geocentric Celestial Reference Frame (GCRF) with the
International Terrestrial Reference Frame (ITRF) at the Julian Day `jd_ut1` [UT1] and
`jd_tt` [Terrestrial Time], and considering the IERS EOP Data `x_p` [rad], `y_p` [rad],
`δΔϵ_1980` [rad], and `δΔψ_1980` [rad] \\(see [`fetch_iers_eop`](@ref)). This algorithm uses
the IAU-76/FK5 theory.

`x_p` is the polar motion displacement about X-axis, which is the IERS Reference Meridian
direction (positive south along the 0˚ longitude meridian). `y_p` is the polar motion
displacement about Y-axis (90˚W or 270˚E meridian). `δΔϵ_1980` is the nutation in obliquity.
`δΔψ_1980` is the nutation in longitude.

The Julian Day in UT1 is used to compute the Greenwich Mean Sidereal Time (GMST) (see
`jd_to_gmst`), whereas the Julian Day in Terrestrial Time is used to compute the nutation in
the longitude. Notice that the Julian Day in UT1 and in Terrestrial Time must be equivalent,
i.e. must be related to the same instant.  This function **does not** check this.

The rotation type is described by the optional variable `T`. If it is `DCM`, then a DCM will
be returned. Otherwise, if it is `Quaternion`, then a Quaternion will be returned. In case
this parameter is omitted, then it falls back to `DCM`.

# Returns

- `T`: The rotation that aligns the GCRF frame with the ITRF frame.

# Remarks

The EOP data related to the polar motion (`x_p` and `y_p`) is required, since this is the
only way available to compute the conversion ITRF <=> PEF (the models are highly imprecise
since the motion is still not very well understood **[1]**). However, the EOP data related
to the nutation of the obliquity (`δΔϵ_1980`) and the nutation of the longitude (`δΔψ_1980`)
can be omitted. In this case, the GCRF frame is what is usually called J2000 reference
frame.

# References

- **[1]**: Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications.  Microcosm
    Press, Hawthorn, CA, USA.
"""
function r_gcrf_to_itrf_fk5(
    jd_ut1::Number,
    jd_tt::Number,
    x_p::Number,
    y_p::Number,
    δΔϵ_1980::Number = 0,
    δΔψ_1980::Number = 0
)
    return r_gcrf_to_itrf_fk5(DCM, jd_ut1, jd_tt, x_p, y_p, δΔϵ_1980, δΔψ_1980)
end

function r_gcrf_to_itrf_fk5(
    T::T_ROT,
    jd_ut1::Number,
    jd_tt::Number,
    x_p::Number,
    y_p::Number,
    δΔϵ_1980::Number = 0,
    δΔψ_1980::Number = 0
)
    return inv_rotation(r_itrf_to_gcrf_fk5(T, jd_ut1, jd_tt, x_p, y_p, δΔϵ_1980, δΔψ_1980))
end

# == PEF <=> MOD ===========================================================================

"""
    r_pef_to_mod_fk5([T, ]jd_ut1::Number, jd_tt::Number[, δΔϵ_1980::Number, δΔψ_1980::Number]) -> T

Compute the rotation that aligns the Pseudo-Earth Fixed (PEF) frame with the Mean of Date
(MOD) at the Julian Day `jd_ut1` [UT1] and `jd_tt` [Terrestrial Time]. This algorithm uses
the IAU-76/FK5 theory. Notice that one can provide corrections for the nutation in obliquity
(`δΔϵ_1980`) [rad] and in longitude (`δΔψ_1980`) [rad] that are usually obtained from IERS
EOP Data (see [`fetch_iers_eop`](@ref)).

The Julian Day in UT1 is used to compute the Greenwich Mean Sidereal Time (GMST) (see
`jd_to_gmst`), whereas the Julian Day in Terrestrial Time is used to compute the nutation in
the longitude. Notice that the Julian Day in UT1 and in Terrestrial Time must be equivalent,
i.e. must be related to the same instant.  This function **does not** check this.

The rotation type is described by the optional variable `T`. If it is `DCM`, then a DCM will
be returned. Otherwise, if it is `Quaternion`, then a Quaternion will be returned. In case
this parameter is omitted, then it falls back to `DCM`.

# Returns

- `T`: The rotation that aligns the PEF frame with the TOD frame.
"""
function r_pef_to_mod_fk5(
    jd_ut1::Number,
    jd_tt::Number,
    δΔϵ_1980::Number = 0,
    δΔψ_1980::Number = 0
)
    return r_pef_to_mod_fk5(DCM, jd_ut1, jd_tt, δΔϵ_1980, δΔψ_1980)
end

function r_pef_to_mod_fk5(
    T::Type,
    jd_ut1::Number,
    jd_tt::Number,
    δΔϵ_1980::Number = 0,
    δΔψ_1980::Number = 0
)
    # Notice that, in this case, we will not use `r_pef_to_tod` and `r_tod_to_mod` because
    # this would call the function `nutation` twice, leading to a huge performance drop.
    # Hence, the code of those two functions is almost entirely rewritten here.

    # Compute the nutation in the Julian Day (Terrestrial Time) `jd_tt`.
    mϵ_1980, Δϵ_1980, Δψ_1980 = nutation_fk5(jd_tt)

    # Add the corrections to the nutation in obliquity and longitude.
    Δϵ_1980 += δΔϵ_1980
    Δψ_1980 += δΔψ_1980

    # Compute the obliquity.
    ϵ_1980 = mϵ_1980 + Δϵ_1980

    # Evaluate the Delaunay parameters associated with the Moon in the interval [0, 2π]°.
    #
    # The parameters here were updated as stated in the errata [2].
    t_tt = (jd_tt - JD_J2000) / 36525
    r    = 360
    Ω_m  = @evalpoly(
        t_tt,
        + 125.04452222,
        - (5r + 134.1362608),
        + 0.0020708,
        + 2.2e-6
    )
    Ω_m = mod(Ω_m, 360) * π / 180

    # Compute the equation of Equinoxes.
    #
    # According to [2], the constant unit before `sin(2Ω_m)` is also in [rad].
    Eq_equinox1982 = Δψ_1980 * cos(mϵ_1980) + (0.002640sin(1Ω_m) + 0.000063sin(2Ω_m)) * π / 648000

    # Compute the Mean Greenwich Sidereal Time.
    θ_gmst = jd_to_gmst(jd_ut1)

    # Compute the Greenwich Apparent Sidereal Time (GAST).
    #
    # TODO: Should GAST be moved to a new function as the GMST?
    θ_gast = θ_gmst + Eq_equinox1982

    # Compute the rotation PEF => TOD.
    r_tod_pef = angle_to_rot(T, -θ_gast, 0, 0, :ZYX)

    # Compute the rotation TOD => MOD.
    r_mod_tod = angle_to_rot(T, ϵ_1980, Δψ_1980, -mϵ_1980, :XZX)

    return compose_rotation(r_tod_pef, r_mod_tod)
end

"""
    r_mod_to_pef_fk5([T, ]jd_ut1::Number, jd_tt::Number[, δΔϵ_1980::Number, δΔψ_1980::Number]) -> T

Compute the rotation that aligns the Mean of Date (MOD) reference frame with the
Pseudo-Earth Fixed (PEF) frame at the Julian Day `jd_ut1` [UT1] and `jd_tt` [Terrestrial
Time]. This algorithm uses the IAU-76/FK5 theory. Notice that one can provide corrections
for the nutation in obliquity (`δΔϵ_1980`) [rad] and in longitude (`δΔψ_1980`) [rad] that
are usually obtained from IERS EOP Data (see [`fetch_iers_eop`](@ref)).

The Julian Day in UT1 is used to compute the Greenwich Mean Sidereal Time (GMST) (see
`jd_to_gmst`), whereas the Julian Day in Terrestrial Time is used to compute the nutation in
the longitude. Notice that the Julian Day in UT1 and in Terrestrial Time must be equivalent,
i.e. must be related to the same instant.  This function **does not** check this.

The rotation type is described by the optional variable `T`. If it is `DCM`, then a DCM will
be returned. Otherwise, if it is `Quaternion`, then a Quaternion will be returned. In case
this parameter is omitted, then it falls back to `DCM`.

# Returns

- `T`: The rotation that aligns the MOD frame with the PEF frame.
"""
function r_mod_to_pef_fk5(
    jd_ut1::Number,
    jd_tt::Number,
    δΔϵ_1980::Number = 0,
    δΔψ_1980::Number = 0
)
    return r_mod_to_pef_fk5(DCM, jd_ut1, jd_tt, δΔϵ_1980, δΔψ_1980)
end

function r_mod_to_pef_fk5(
    T::T_ROT,
    jd_ut1::Number,
    jd_tt::Number,
    δΔϵ_1980::Number = 0,
    δΔψ_1980::Number = 0
)
    return inv_rotation(r_pef_to_mod_fk5(T, jd_ut1, jd_tt, δΔϵ_1980, δΔψ_1980))
end
