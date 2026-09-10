## Description #############################################################################
#
# Functions to compute the precession according to IAU-76/FK5.
#
## References ##############################################################################
#
# [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm Press,
#     Hawthorn, CA, USA.
#
############################################################################################

export precession_fk5

############################################################################################
#                                        Functions                                         #
############################################################################################

"""
    precession_fk5(jd_tt::Number) -> NTuple{3, Number}

Compute the angles related to the precession movement in the Julian Day `jd_tt`
[Terrestrial Time] using the theory IAU-76/FK5.

# Returns

- `NTuple{3, Number}`: The angles (ζ, Θ, z) as described in **[1]**(p. 226-228).

# References

- **[1]**: Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm
    Press, Hawthorn, CA, USA.
"""
function precession_fk5(jd_tt::Number)
    # Compute the Julian Centuries from `jd_tt`.
    t_tt = (jd_tt - JD_J2000) / 36525

    # Compute the angles [arcsec].
    ζ = @evalpoly(t_tt, 0, +2306.2181, +0.30188, +0.017998)
    Θ = @evalpoly(t_tt, 0, +2004.3109, -0.42665, -0.041833)
    z = @evalpoly(t_tt, 0, +2306.2181, +1.09468, +0.018203)

    # Convert the angles from arcsec to rad and normalize them to the interval [0, 2π] rad.

    ζ = mod(ζ * _ARCSEC_TO_RAD, 2π)
    Θ = mod(Θ * _ARCSEC_TO_RAD, 2π)
    z = mod(z * _ARCSEC_TO_RAD, 2π)

    # Return the precession angles.
    return ζ, Θ, z
end
