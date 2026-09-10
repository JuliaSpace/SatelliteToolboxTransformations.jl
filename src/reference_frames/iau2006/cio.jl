## Description #############################################################################
#
# Functions to compute the Celestial Intermediate Origin (CIO).
#
## References ##############################################################################
#
# [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm
#     Press, Hawthorn, CA, USA.
#
# [2] Vallado, D. A (06-Feb-2018). Consolidated Errata of Fundamentals of Astrodynamics and
#     Applications 4th Ed.
#
############################################################################################

export cio_iau2006

"""
    cio_iau2006(jd_tt::Number) -> NTuple{3, Number}

Compute the coordinates `X` and `Y` of the Celestial Intermediate Pole (CIP) with respect to
the Geocentric Celestial Reference Frame (GCRF), and the CIO locator `s` at the Julian Day
`jd_tt` [Terrestrial Time]. The algorithm is based on the IAU-2006 theory.

The CIO locator `s` provides the position of the CIO on the Equator of the CIP corresponding
to the kinematical definition of the non-rotation origin in the GCRS when the CIP is moving
with respect to the GCRS between the reference epoch and the epoch due to precession and
nutation **[1]**(p. 214).

# Returns

- `Number`: The coordinate `X` of the CIP w.r.t. the GCRF [rad].
- `Number`: The coordinate `Y` of the CIP w.r.t. the GCRF [rad].
- `Number`: The CIO locator `s` [rad].

# References

- **[1]** Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm
    Press, Hawthorn, CA, USA.
"""
function cio_iau2006(jd_tt::Number)
    # Compute the Julian Centuries from `jd_tt`.
    t_tt = (jd_tt - JD_J2000) / 36525

    # == Fundamental Arguments =============================================================

    # Luni-solar part.
    M_s, M_m, u_Mm, D_s, Ω_m = _luni_solar_args_iau2006(t_tt)

    # Planetary part.
    λ_M☿, λ_M♀, λ_Me, λ_M♂, λ_M♃, λ_M♄, λ_M⛢, λ_M♆, p_λ = _planetary_args_iau2006(t_tt)

    # == X Position of the CIP =============================================================

    ΔX = _iau2006_sum(
        (
            _IAU_2006_CIP_X0,
            _IAU_2006_CIP_X1,
            _IAU_2006_CIP_X2,
            _IAU_2006_CIP_X3,
            _IAU_2006_CIP_X4,
        ),
        t_tt,
        M_s,
        M_m,
        u_Mm,
        D_s,
        Ω_m,
        λ_M☿,
        λ_M♀,
        λ_Me,
        λ_M♂,
        λ_M♃,
        λ_M♄,
        λ_M⛢,
        λ_M♆,
        p_λ,
    )

    X =
        @evalpoly(
            t_tt,
            -0.016_617,
            +2004.191_898,
            -0.429_782_9,
            -0.198_618_34,
            +0.000_007_578,
            +0.000_005_928_5
        ) + ΔX

    # Convert to [rad].
    X *= _ARCSEC_TO_RAD

    # == Y Position of the CIP =============================================================

    ΔY = _iau2006_sum(
        (
            _IAU_2006_CIP_Y0,
            _IAU_2006_CIP_Y1,
            _IAU_2006_CIP_Y2,
            _IAU_2006_CIP_Y3,
            _IAU_2006_CIP_Y4,
        ),
        t_tt,
        M_s,
        M_m,
        u_Mm,
        D_s,
        Ω_m,
        λ_M☿,
        λ_M♀,
        λ_Me,
        λ_M♂,
        λ_M♃,
        λ_M♄,
        λ_M⛢,
        λ_M♆,
        p_λ,
    )

    Y =
        @evalpoly(
            t_tt,
            -0.006_951,
            -0.025_896,
            -22.407_274_7,
            +0.001_900_59,
            +0.001_112_526,
            +0.000_000_135_8
        ) + ΔY

    # Convert to [rad].
    Y *= _ARCSEC_TO_RAD

    # == Parameter `s` (CIO Locator) =======================================================

    # The value `s` provides the position of the CIO on the Equator of the CIP corresponding
    # to the kinematical definition of the non-rotation origin in the GCRS when the CIP is
    # moving with respect to the GCRS between the reference epoch and the epoch due to
    # precession and nutation [1, p. 214].
    Δs = _iau2006_sum(
        (
            _IAU_2006_CIO_S0,
            _IAU_2006_CIO_S1,
            _IAU_2006_CIO_S2,
            _IAU_2006_CIO_S3,
            _IAU_2006_CIO_S4,
        ),
        t_tt,
        M_s,
        M_m,
        u_Mm,
        D_s,
        Ω_m,
        λ_M☿,
        λ_M♀,
        λ_Me,
        λ_M♂,
        λ_M♃,
        λ_M♄,
        λ_M⛢,
        λ_M♆,
        p_λ,
    )

    s =
        @evalpoly(
            t_tt,
            # We must convert the term `-X * Y / 2` to [arcsec] to match the units of the
            # other coefficients.
            (-X * Y / 2) / _ARCSEC_TO_RAD + 0.000_094,
            +0.003_808_65,
            -0.000_122_68,
            -0.072_574_11,
            +0.000_027_98,
            +0.000_015_62
        ) + Δs

    # Convert to [rad].
    s *= _ARCSEC_TO_RAD

    return X, Y, s
end
