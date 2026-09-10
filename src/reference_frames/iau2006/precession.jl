## Description #############################################################################
#
# Compute the precession as in equinox-based IAU-2006 theory.
#
## References ##############################################################################
#
# [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm Press,
#     Hawthorn, CA, USA.
#
# [2] Wallace, P. T., Capitaine, N (2006). Precession-nutation procedures consistent with
#     IAU 2006 resolutions. Astronomy & Astrophysics.
#
# [3] IERS (2010). Transformation between the International Terrestrial Reference System and
#     the Geocentric Celestial Reference System. IERS Technical Note No. 36, Chapter 5.
#
############################################################################################

export precession_iau2006

"""
    precession_iau2006(jd_tt::Number) -> NTuple{3, Number}

Compute the precession angles [rad] according to equinox-based IAU-2006 theory at the Julian
Day `jd_tt` [Terrestrial Time].

This algorithm was obtained from **[3]**(p. 49).

# Returns

- `Number`: The IAU-2006 precession angle `Ψ_a` [rad].
- `Number`: The IAU-2006 precession angle `ω_a` [rad].
- `Number`: The IAU-2006 precession angle `χ_a` [rad].

# References

- **[3]** IERS (2010). Transformation between the International Terrestrial Reference
    System and the Geocentric Celestial Reference System. IERS Technical Note No. 36,
    Chapter 5.
"""
function precession_iau2006(jd_tt::Number)
    # Compute the Julian Centuries from `jd_tt`.
    t_tt = (jd_tt - JD_J2000) / 36525

    # == Precession Angles =================================================================

    # Compute the angles [arcsec], convert them to [rad], and reduce them to the interval
    # [0, 2π].
    Ψ_a = @evalpoly(
        t_tt, 0, +5038.481_507, -1.079_006_9, -0.001_140_45, +1.328_51e-4, -9.51e-8
    )
    Ψ_a = mod(Ψ_a * _ARCSEC_TO_RAD, 2π)

    ω_a = @evalpoly(
        t_tt, +84381.406, -0.025_754, +0.051_262_3, -0.007_725_03, -4.67e-7, +3.337e-7
    )
    ω_a = mod(ω_a * _ARCSEC_TO_RAD, 2π)

    χ_a = @evalpoly(
        t_tt, 0, +10.556_403, -2.381_429_2, -0.001_211_97, +1.706_63e-4, -5.60e-8
    )
    χ_a = mod(χ_a * _ARCSEC_TO_RAD, 2π)

    return Ψ_a, ω_a, χ_a
end
