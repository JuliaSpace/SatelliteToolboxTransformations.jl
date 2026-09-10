## Description #############################################################################
#
# Compute the fundamental arguments related to the IAU-2006 theory.
#
## References ##############################################################################
#
# [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm
#     Press, Hawthorn, CA, USA.
#
############################################################################################

export luni_solar_args_iau2006, planetary_args_iau2006

"""
    luni_solar_args_iau2006(jd_tt::Number) -> NTuple{5, Number}

Compute the fundamental arguments related to the luni-solar effect for the IAU-2006 theory
**[1]**(p. 211) at the Julian Day `jd_tt` [Terrestrial Time].

# Returns

- `Number`: Mean anomaly of the Sun [rad].
- `Number`: Mean anomaly of the Moon [rad].
- `Number`: Mean argument of latitude of the Moon [rad].
- `Number`: Mean elongation of the Moon from the Sun [rad].
- `Number`: Mean longitude of the ascending node of the Moon [rad].

# References

- **[1]** Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm
    Press, Hawthorn, CA, USA.
"""
function luni_solar_args_iau2006(jd_tt::Number)
    # Compute the Julian Centuries from `jd_tt`.
    return _luni_solar_args_iau2006((jd_tt - JD_J2000) / 36525)
end

"""
    _luni_solar_args_iau2006(t_tt::Number) -> NTuple{5, Number}

Compute the fundamental arguments related to the luni-solar effect for the IAU-2006 theory
**[1]**(p. 211) given the Julian centuries `t_tt` since J2000.0 in Terrestrial Time (TT).

This is the implementation of [`luni_solar_args_iau2006`](@ref). It takes `t_tt` instead of
the Julian Day so that the callers that already have it, like [`cio_iau2006`](@ref) and
[`nutation_eo_iau2006`](@ref), do not need to compute it again.

# Returns

- `Number`: Mean anomaly of the Sun [rad].
- `Number`: Mean anomaly of the Moon [rad].
- `Number`: Mean argument of latitude of the Moon [rad].
- `Number`: Mean elongation of the Moon from the Sun [rad].
- `Number`: Mean longitude of the ascending node of the Moon [rad].

# References

- **[1]** Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm
    Press, Hawthorn, CA, USA.
"""
function _luni_solar_args_iau2006(t_tt::Number)
    # == Delaunay Arguments of the Sun and Moon ============================================
    #
    # Evaluate the Delaunay arguments associated with the Moon and the Sun in [arcsec]
    # [1, p. 210].

    M_m = @evalpoly(
        t_tt, +485868.249036, +1717915923.2178, +31.8792, +0.051635, -0.00024470
    )

    M_s = @evalpoly(t_tt, +1287104.79305, +129596581.0481, -0.5532, +0.000136, -0.00001149)

    u_Mm = @evalpoly(
        t_tt, +335779.526232, +1739527262.8478, -12.7512, -0.001037, +0.00000417
    )

    D_s = @evalpoly(t_tt, +1072260.70369, +1602961601.2090, -6.3706, +0.006593, -0.00003169)

    Ω_m = @evalpoly(t_tt, +450160.398036, -6962890.5431, +7.4722, +0.007702, -0.00005939)

    # Convert to the interval [0, 2π].
    M_s  = deg2rad(mod(M_s * _ARCSEC_TO_DEG, 360))
    M_m  = deg2rad(mod(M_m * _ARCSEC_TO_DEG, 360))
    u_Mm = deg2rad(mod(u_Mm * _ARCSEC_TO_DEG, 360))
    D_s  = deg2rad(mod(D_s * _ARCSEC_TO_DEG, 360))
    Ω_m  = deg2rad(mod(Ω_m * _ARCSEC_TO_DEG, 360))

    return M_s, M_m, u_Mm, D_s, Ω_m
end

"""
    planetary_args_iau2006(jd_tt::Number) -> NTuple{9, Number}

Compute the fundamental arguments related to the planetary effects for the IAU-2006 theory
**[1]**(p. 211) at the Julian Day `jd_tt` [Terrestrial Time].

# Returns

- `Number`: Mean heliocentric longitude of Mercury [rad].
- `Number`: Mean heliocentric longitude of Venus [rad].
- `Number`: Mean heliocentric longitude of the Earth [rad].
- `Number`: Mean heliocentric longitude of Mars [rad].
- `Number`: Mean heliocentric longitude of Jupiter [rad].
- `Number`: Mean heliocentric longitude of Saturn [rad].
- `Number`: Mean heliocentric longitude of Uranus [rad].
- `Number`: Mean heliocentric longitude of Neptune [rad].
- `Number`: General accumulated precession in longitude [rad].

# References

- **[1]** Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm
    Press, Hawthorn, CA, USA.
"""
function planetary_args_iau2006(jd_tt::Number)
    # Compute the Julian Centuries from `jd_tt`.
    return _planetary_args_iau2006((jd_tt - JD_J2000) / 36525)
end

"""
    _planetary_args_iau2006(t_tt::Number) -> NTuple{9, Number}

Compute the fundamental arguments related to the planetary effects for the IAU-2006 theory
**[1]**(p. 211) given the Julian centuries `t_tt` since J2000.0 in Terrestrial Time (TT).

This is the implementation of [`planetary_args_iau2006`](@ref). It takes `t_tt` instead of
the Julian Day so that the callers that already have it, like [`cio_iau2006`](@ref) and
[`nutation_eo_iau2006`](@ref), do not need to compute it again.

# Returns

- `Number`: Mean heliocentric longitude of Mercury [rad].
- `Number`: Mean heliocentric longitude of Venus [rad].
- `Number`: Mean heliocentric longitude of the Earth [rad].
- `Number`: Mean heliocentric longitude of Mars [rad].
- `Number`: Mean heliocentric longitude of Jupiter [rad].
- `Number`: Mean heliocentric longitude of Saturn [rad].
- `Number`: Mean heliocentric longitude of Uranus [rad].
- `Number`: Mean heliocentric longitude of Neptune [rad].
- `Number`: General accumulated precession in longitude [rad].

# References

- **[1]** Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm
    Press, Hawthorn, CA, USA.
"""
function _planetary_args_iau2006(t_tt::Number)
    # Mean heliocentric longitudes of the planets [rad].
    #
    # TODO: In the example in [1, p. 221], the value related to Uranus is slightly
    # different. The value used here is shown in [1, p. 211].

    λ_M☿ = @evalpoly(t_tt, 4.402_608_842, 2608.790_314_157_4)
    λ_M♀ = @evalpoly(t_tt, 3.176_146_697, 1021.328_554_621_1)
    λ_Me = @evalpoly(t_tt, 1.753_470_314, 628.307_584_999_1)
    λ_M♂ = @evalpoly(t_tt, 6.203_480_913, 334.061_242_670_0)
    λ_M♃ = @evalpoly(t_tt, 0.599_546_497, 52.969_096_264_1)
    λ_M♄ = @evalpoly(t_tt, 0.874_016_757, 21.329_910_496_0)
    λ_M⛢ = @evalpoly(t_tt, 5.481_293_872, 7.478_159_856_7)
    λ_M♆ = @evalpoly(t_tt, 5.311_886_287, 3.813_303_563_8)

    # General precession in longitude [rad].
    p_λ = @evalpoly(t_tt, 0, 0.024_381_75, 0.000_005_386_91)

    # Convert to the interval [0, 2π].
    λ_M☿ = mod(λ_M☿, 2π)
    λ_M♀ = mod(λ_M♀, 2π)
    λ_Me = mod(λ_Me, 2π)
    λ_M♂ = mod(λ_M♂, 2π)
    λ_M♃ = mod(λ_M♃, 2π)
    λ_M♄ = mod(λ_M♄, 2π)
    λ_M⛢ = mod(λ_M⛢, 2π)
    λ_M♆ = mod(λ_M♆, 2π)
    p_λ  = mod(p_λ, 2π)

    return λ_M☿, λ_M♀, λ_Me, λ_M♂, λ_M♃, λ_M♄, λ_M⛢, λ_M♆, p_λ
end
