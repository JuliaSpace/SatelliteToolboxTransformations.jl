## Description #############################################################################
#
# Functions to perform conversions related to EOP data.
#
############################################################################################

export compute_δΔϵ_δΔψ

"""
    compute_δΔϵ_δΔψ(eop_iau2000a::EopIau2000A, JD_UTC::Number) -> (Float64, Float64)

Compute the celestial pole offsets in obliquity (`δΔϵ_2000`) and longitude (`δΔψ_2000`)
given the IERS EOP IAU 2000A `eop_iau2000a` at the UTC Julian date `JD_UTC`.

The EOP celestial pole offsets (`δx` and `δy`) and the returned corrections are in
milliarcseconds. The returned corrections have not yet been converted to radians; callers
must perform that conversion before using them in the IAU-2006 transformations.

This function obtains those values by converting the celestial pole offsets with respect to
the GCRS (`δx` and `δy`). These values are necessary in the equinox-based IAU-2006 theory.

The algorithm was obtained from **[1]**(eq. 5.25) and **[2]**(`DPSIDEPS2000_DXDY2000`).

# References

- **[1]**: IERS (2010). Transformation between the International Terrestrial Reference
    System and the Geocentric Celestial Reference System. IERS Technical Note No. 36,
    Chapter 5.
- **[2]**: ftp://hpiers.obspm.fr/eop-pc/models/uai2000.package
"""
function compute_δΔϵ_δΔψ(eop_iau2000a::EopIau2000A, JD_UTC::Number)
    # Constants.
    d2r = π / 180
    a2d = 1 / 3600
    a2r = a2d * d2r

    # Obtain the parameters `dX` and `dY` [milliarcseconds].
    # Pole offsets are EOP data and are tabulated against UTC.
    δx = eop_iau2000a.δx(JD_UTC)
    δy = eop_iau2000a.δy(JD_UTC)

    # The precession polynomials, however, are functions of TT.
    JD_TT = jd_utc_to_tt(JD_UTC)
    T_TT = (JD_TT - JD_J2000) / 36525

    # Luni-solar precession [rad].
    Ψ_a = @evalpoly(T_TT, 0, +5038.47875, -1.07259, -0.001147) * a2r

    # Planetary precession [rad].
    χ_a = @evalpoly(T_TT, 0, +10.5526, -2.38064, -0.001125) * a2r

    sϵ₀, cϵ₀ = sincos(84381.406 * a2r)

    aux = Ψ_a * cϵ₀ - χ_a
    den = aux^2 * sϵ₀ - sϵ₀
    δΔϵ = (aux * sϵ₀ * δx - sϵ₀ * δy) / den
    δΔΨ = (δx - aux * δy) / den

    return δΔϵ, δΔΨ
end
