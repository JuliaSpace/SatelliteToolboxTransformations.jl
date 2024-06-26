## Description #############################################################################
#
# Functions related with the CIO-based model IAU-2006 with IAU-2010 conventions.
#
## References ##############################################################################
#
# [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications.  Microcosm
#     Press, Hawthorn, CA, USA.
#
############################################################################################

export r_itrf_to_tirs_iau2006, r_tirs_to_itrf_iau2006
export r_tirs_to_cirs_iau2006, r_cirs_to_tirs_iau2006
export r_cirs_to_gcrf_iau2006, r_gcrf_to_cirs_iau2006

############################################################################################
#                                   IAU-2006 Reductions                                    #
############################################################################################
#
# The conversion between the Geocentric Celestial Reference Frame (GCRF) to the
# International Terrestrial Reference Frame (ITRF) is done by means of:
#
#                             GCRF <=> CIRS <=> TIRS <=> ITRF
#
# in which:
#   - TIRS: Terrestrial Intermediate Reference System.
#   - CIRS: Celestial Intermediate Reference System.
#
# Every rotation will be coded as a function using the IAU-2006 theory with the IAU-2010
# conventions. The API is:
#
#   function r_<Origin Frame>_to_<Destination Frame>_iau2006
#
# The arguments vary depending on the origin and destination frame and should be verified
# using the function documentation.
#
############################################################################################

############################################################################################
#                                     Single Rotations                                     #
############################################################################################

# == ITRF <=> TIRS =========================================================================

"""
    r_itrf_to_tirs_iau2006([T, ]jd_tt::Number, x_p::Number, y_p::Number) -> T

Compute the rotation that aligns the International Terrestrial Reference Frame (ITRF) with
the Terrestrial Intermediate Reference System (TIRS) considering the polar motion
represented by the angles `x_p` [rad] and `y_p` [rad] that are obtained from IERS EOP Data
(see [`fetch_iers_eop`](@ref)).

`x_p` is the polar motion displacement about X-axis, which is the IERS Reference Meridian
direction (positive south along the 0˚ longitude meridian). `y_p` is the polar motion
displacement about Y-axis (90˚W or 270˚E meridian).

The rotation type is described by the optional variable `T`. If it is `DCM`, then a DCM will
be returned. Otherwise, if it is `Quaternion`, then a Quaternion will be returned. In case
this parameter is omitted, then it falls back to `DCM`.

# Returns

- `T`: The rotation that aligns the ITRF frame with the TIRS frame.

# Remarks

The ITRF is defined based on the International Reference Pole (IRP), which is the location
of the terrestrial pole agreed by international committees **[1]**.  The Terrestrial
Intermediate Reference Frame (TIRS), on the other hand, is defined based on the Earth axis
of rotation, or the Celestial Intermediate Pole (CIP). Hence, TIRS XY-plane contains the
True Equator. Furthermore, since the recovered latitude and longitude are sensitive to the
CIP, then it should be computed considering the TIRS frame.

The TIRS and PEF (IAU-76/FK5) are virtually the same reference frame, but according to
**[1]** it is convenient to separate the names as the exact formulae differ.

# References

- **[1]**: Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications.  Microcosm
    Press, Hawthorn, CA, USA.
"""
function r_itrf_to_tirs_iau2006(jd_tt::Number, x_p::Number, y_p::Number)
    return r_itrf_to_tirs_iau2006(DCM, jd_tt, x_p, y_p)
end

function r_itrf_to_tirs_iau2006(T::Type, jd_tt::Number, x_p::Number, y_p::Number)
    # Convert Julian days to Julian centuries.
    t_tt = (jd_tt - JD_J2000) / 36525

    # Notice that this rotation has an additional one, called `sl`, from the IAU-76/FK5
    # theory that accounts for the instantaneous prime meridian called TIO locator
    # [1, p. 212].
    sl = (-0.000047 * π / 648000) * t_tt # [rad]

    return angle_to_rot(T, y_p, x_p, -sl, :XYZ)
end

"""
    r_tirs_to_itrf_iau2006([T, ]jd_tt::Number, x_p::Number, y_p::Number) -> T

Compute the rotation that aligns the Terrestrial Intermediate Reference System (TIRS) with
the International Terrestrial Reference Frame (ITRF) considering the polar motion
represented by the angles `x_p` [rad] and `y_p` [rad] that are obtained from IERS EOP Data
(see [`fetch_iers_eop`](@ref)).

`x_p` is the polar motion displacement about X-axis, which is the IERS Reference Meridian
direction (positive south along the 0˚ longitude meridian). `y_p` is the polar motion
displacement about Y-axis (90˚W or 270˚E meridian).

The rotation type is described by the optional variable `T`. If it is `DCM`, then a DCM will
be returned. Otherwise, if it is `Quaternion`, then a Quaternion will be returned. In case
this parameter is omitted, then it falls back to `DCM`.

# Returns

- `T`: The rotation that aligns the TIRS frame with the ITRF frame.

# Remarks

The ITRF is defined based on the International Reference Pole (IRP), which is the location
of the terrestrial pole agreed by international committees **[1]**. The Terrestrial
Intermediate Reference Frame (TIRS), on the other hand, is defined based on the Earth axis
of rotation, or the Celestial Intermediate Pole (CIP). Hence, TIRS XY-plane contains the
True Equator. Furthermore, since the recovered latitude and longitude are sensitive to the
CIP, then it should be computed considering the TIRS frame.

The TIRS and PEF (IAU-76/FK5) are virtually the same reference frame, but according to
**[1]** it is convenient to separate the names as the exact formulae differ.

# References

- **[1]**: Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications.  Microcosm
    Press, Hawthorn, CA, USA.
"""
function r_tirs_to_itrf_iau2006(
    jd_tt::Number,
    x_p::Number,
    y_p::Number
)
    return r_tirs_to_itrf_iau2006(DCM, jd_tt, x_p, y_p)
end

function r_tirs_to_itrf_iau2006(T::Type, jd_tt::Number, x_p::Number, y_p::Number)
    # Convert Julian days to Julian centuries.
    t_tt = (jd_tt - JD_J2000) / 36525

    # Notice that this rotation has an additional one, called `sl`, from the IAU-76/FK5
    # theory that accounts for the instantaneous prime meridian called TIO locator [1, p.
    # 212].
    sl = (-0.000047 * π / 648000) * t_tt # [rad]

    return angle_to_rot(T, sl, -x_p, -y_p, :ZYX)
end

# == TIRS <=> CIRS =========================================================================

"""
    r_tirs_to_cirs_iau2006([T, ]jd_ut1::Number) -> T

Compute the rotation that aligns the Terrestrial Intermediate Reference System (TIRS) with
the Celestial Intermediate Reference System (CIRS) at the Julian Day `jd_ut1` [UT1]. This
algorithm uses the IAU-2006 theory.

The rotation type is described by the optional variable `T`. If it is `DCM`, then a DCM will
be returned. Otherwise, if it is `Quaternion`, then a Quaternion will be returned. In case
this parameter is omitted, then it falls back to `DCM`.

# Returns

- `T`: The rotation that aligns the TIRS frame with the CIRS frame.

# Remarks

The reference frames TIRS and CIRS are separated by a rotation about the Z-axis of the Earth
Rotation Angle, which is the angle between the Conventional International Origin (CIO) and
the Terrestrial Intermediate Origin (TIO) **[1]**.  The latter is a reference meridian on
Earth that is located about 100m away from Greenwich meridian along the equator of the
Celestial Intermediate Pole (CIP) **[1]**.

# References

- **[1]**: Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications.  Microcosm
    Press, Hawthorn, CA, USA.
"""
r_tirs_to_cirs_iau2006(jd_ut1::Number) = r_tirs_to_cirs_iau2006(DCM, jd_ut1)

function r_tirs_to_cirs_iau2006(T::Type, jd_ut1::Number)
    # In this theory, the rotation of Earth is taken into account by the Earth Rotation
    # Angle, which is the angle between the Conventional International Origin (CIO) and the
    # Terrestrial Intermediate Origin (TIO) [1]. The latter is a reference meridian on Earth
    # that is located about 100m away from Greenwich meridian along the equator of the
    # Celestial Intermediate Pole (CIP) [1].
    θ_era = 2π * (0.7790572732640 + 1.00273781191135448 * (jd_ut1 - JD_J2000))

    return angle_to_rot(T, -θ_era, 0, 0, :ZXY)
end

"""
    r_cirs_to_tirs_iau2006([T, ]jd_ut1::Number) -> T

Compute the rotation that aligns the Celestial Intermediate Reference System (CIRS) with the
Terrestrial Intermediate Reference System (TIRS) at the Julian Day `jd_ut1` [UT1]. This
algorithm uses the IAU-2006 theory.

The rotation type is described by the optional variable `T`. If it is `DCM`, then a DCM will
be returned. Otherwise, if it is `Quaternion`, then a Quaternion will be returned. In case
this parameter is omitted, then it falls back to `DCM`.

# Returns

The rotation that aligns the CIRS frame with the TIRS frame. The rotation representation is
selected by the optional parameter `T`.

# Remarks

The reference frames TIRS and CIRS are separated by a rotation about the Z-axis of the Earth
Rotation Angle, which is the angle between the Conventional International Origin (CIO) and
the Terrestrial Intermediate Origin (TIO) **[1]**. The latter is a reference meridian on
Earth that is located about 100m away from Greenwich meridian along the equator of the
Celestial Intermediate Pole (CIP) **[1]**.

# References

- **[1]**: Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications.  Microcosm
    Press, Hawthorn, CA, USA.
"""
r_cirs_to_tirs_iau2006(jd_ut1::Number) = r_cirs_to_tirs_iau2006(DCM, jd_ut1)

function r_cirs_to_tirs_iau2006(T::Type, jd_ut1::Number)
    # In this theory, the rotation of Earth is taken into account by the Earth Rotation
    # Angle, which is the angle between the Conventional International Origin (CIO) and the
    # Terrestrial Intermediate Origin (TIO) [1]. The latter is a reference meridian on Earth
    # that is located about 100m away from Greenwich meridian along the equator of the
    # Celestial Intermediate Pole (CIP) [1].
    θ_era = 2π * (0.7790572732640 + 1.00273781191135448 * (jd_ut1 - JD_J2000))

    return angle_to_rot(T, θ_era, 0, 0, :ZXY)
end

# == CIRS <=> GCRF =========================================================================

"""
    r_cirs_to_gcrf_iau2006([T, ]jd_tt::Number, δx::Number = 0, δy::Number = 0) -> T

Compute the rotation that aligns the Celestial Intermediate Reference System (CIRS) with the
Geocentric Celestial Reference Frame (GCRF) at the Julian Day `jd_tt` [TT] and considering
the IERS EOP Data `δx` [rad] and `δy` [rad] \\(see [`fetch_iers_eop`](@ref)). This algorithm
uses the IAU-2006 theory.

The IERS EOP Data `δx` and `δy` accounts for the free-core nutation and time dependent
effects of the Celestial Intermediate Pole (CIP) position with respect to the GCRF.

The rotation type is described by the optional variable `T`. If it is `DCM`, then a DCM will
be returned. Otherwise, if it is `Quaternion`, then a Quaternion will be returned. In case
this parameter is omitted, then it falls back to `DCM`.

# Returns

- `T`: The rotation that aligns the CIRS frame with the GCRF frame.
"""
function r_cirs_to_gcrf_iau2006(jd_tt::Number, δx::Number = 0, δy::Number = 0)
    return r_cirs_to_gcrf_iau2006(DCM, jd_tt, δx, δy)
end

function r_cirs_to_gcrf_iau2006(::Type{DCM}, jd_tt::Number, δx::Number = 0, δy::Number = 0)
    # Compute the rotations to obtain the Celestial Intermediate Origin (CIO).
    x, y, s = cio_iau2006(jd_tt)

    # Add the corrections.
    x += δx
    y += δy

    # Auxiliary variables.
    x² = x^2
    y² = y^2
    xy = x * y

    # == Compute the Rotation Matrix =======================================================

    # This is the approximate value for:
    #
    #   a = 1/(1 + cos(d)), d = atan( sqrt( ( x^2 + y^2 )/( 1 - x^2 - y^2 ) ) )
    a = 1 / 2 + 1 / 8 * (x² + y²)

    D = DCM(1 - a * x²,    -a * xy, x,
               -a * xy, 1 - a * y², y,
                    -x,        -y , 1 - a * (x² + y²))'

    return D * angle_to_dcm(s, :Z)
end

function r_cirs_to_gcrf_iau2006(
    ::Type{Quaternion},
    jd_tt::Number,
    δx::Number = 0,
    δy::Number = 0
)
    return dcm_to_quat(r_cirs_to_gcrf_iau2006(DCM, jd_tt, δx, δy))
end

"""
    r_gcrf_to_cirs_iau2006([T, ]jd_tt::Number, δx::Number = 0, δy::Number = 0) -> T

Compute the rotation that aligns the Geocentric Celestial Reference Frame (GCRF) with the
Celestial Intermediate Reference System (CIRS) at the Julian Day `jd_tt` [TT] and
considering the IERS EOP Data `δx` [rad] and `δy` [rad] \\(see [`fetch_iers_eop`](@ref)).
This algorithm uses the IAU-2006 theory.

The IERS EOP Data `δx` and `δy` accounts for the free-core nutation and time dependent
effects of the Celestial Intermediate Pole (CIP) position with respect to the GCRF.

The rotation type is described by the optional variable `T`. If it is `DCM`, then a DCM will
be returned. Otherwise, if it is `Quaternion`, then a Quaternion will be returned. In case
this parameter is omitted, then it falls back to `DCM`.

# Returns

- `T`: The rotation that aligns the GCRF frame with the CIRS frame.
"""
function r_gcrf_to_cirs_iau2006(jd_tt::Number, δx::Number = 0, δy::Number = 0)
    return r_gcrf_to_cirs_iau2006(DCM, jd_tt, δx, δy)
end

function r_gcrf_to_cirs_iau2006(::Type{DCM}, jd_tt::Number, δx::Number = 0, δy::Number = 0)
    # Compute the rotations to obtain the Celestial Intermediate Origin (CIO).
    x, y, s = cio_iau2006(jd_tt)

    # Add the corrections.
    x += δx
    y += δy

    # Auxiliary variables.
    x² = x^2
    y² = y^2
    xy = x * y

    # == Compute the Rotation Matrix =======================================================

    # This is the approximate value for:
    #
    #   a = 1/(1 + cos(d)), d = atan( sqrt( ( x^2 + y^2 )/( 1 - x^2 - y^2 ) ) )
    a = 1 / 2 + 1 / 8 * (x² + y²)

    D = DCM(1 - a * x²,    -a * xy, x,
               -a * xy, 1 - a * y², y,
                   -x ,        -y , 1 - a * (x² + y²))

    return angle_to_dcm(-s, :Z) * D
end

function r_gcrf_to_cirs_iau2006(
    ::Type{Quaternion},
    jd_tt::Number,
    δx::Number = 0,
    δy::Number = 0
)
    return dcm_to_quat(r_gcrf_to_cirs_iau2006(DCM, jd_tt, δx, δy))
end
