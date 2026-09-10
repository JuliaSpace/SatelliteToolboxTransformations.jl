## Description #############################################################################
#
# Functions to perform conversions related to EOP data.
#
############################################################################################

export compute_δΔϵ_δΔψ

"""
    compute_δΔϵ_δΔψ(eop_iau2000a::EopIau2000A, JD_UTC::Number) -> Number, Number
    compute_δΔϵ_δΔψ(
        eop_iau2000a::EopIau2000A,
        JD_UTC::Number,
        JD_TT::Number
    ) -> Number, Number

Compute the celestial pole offsets in obliquity (`δΔϵ_2000`) and in longitude (`δΔψ_2000`)
[mas] given the IERS EOP IAU-2000A data `eop_iau2000a` at the Julian Day `JD_UTC` [UTC].

The celestial pole offsets are tabulated against UTC, whereas the precession polynomials are
functions of TT. If the caller already computed the Julian Day `JD_TT` [TT], it can be
passed to avoid recomputing it. Otherwise, it is obtained from `JD_UTC` using
[`jd_utc_to_tt`](@ref).

The offsets are obtained by converting the celestial pole offsets with respect to the GCRS
(`δx` and `δy` [mas]), which is what the EOP data provides. The result is required by the
equinox-based IAU-2006 theory, whose functions expect it in [rad], so the caller must
convert it before use.

The algorithm was obtained from **[1]** (eq. 5.25) and **[2]** (`DPSIDEPS2000_DXDY2000`).

# Returns

- `Number`: Celestial pole offset in obliquity `δΔϵ_2000` [mas].
- `Number`: Celestial pole offset in longitude `δΔψ_2000` [mas].

# References

- **[1]** IERS (2010). Transformation between the International Terrestrial Reference System
    and the Geocentric Celestial Reference System. IERS Technical Note No. 36, Chapter 5.
- **[2]** ftp://hpiers.obspm.fr/eop-pc/models/uai2000.package
"""
function compute_δΔϵ_δΔψ(eop_iau2000a::EopIau2000A, JD_UTC::Number)
    return compute_δΔϵ_δΔψ(eop_iau2000a, JD_UTC, jd_utc_to_tt(JD_UTC))
end

function compute_δΔϵ_δΔψ(eop_iau2000a::EopIau2000A, JD_UTC::Number, JD_TT::Number)
    # Obtain the celestial pole offsets `δx` and `δy` [mas] with respect to the GCRS, which
    # are EOP data tabulated against UTC.
    δx = eop_iau2000a.δx(JD_UTC)
    δy = eop_iau2000a.δy(JD_UTC)

    # The precession polynomials, however, are functions of TT.
    T_TT = (JD_TT - JD_J2000) / 36525

    # Luni-solar precession [rad].
    Ψ_a = @evalpoly(T_TT, 0, +5038.47875, -1.07259, -0.001147) * _ARCSEC_TO_RAD

    # Planetary precession [rad].
    χ_a = @evalpoly(T_TT, 0, +10.5526, -2.38064, -0.001125) * _ARCSEC_TO_RAD

    sϵ₀, cϵ₀ = sincos(_OBLIQUITY_J2000_IAU2006)

    # Reference [1](eq. 5.25) relates the offsets with respect to the GCRS to the ones
    # referred to the IAU-1980 model by:
    #
    #   δx = δΔψ ⋅ sin(ϵ₀) + aux ⋅ δΔϵ
    #   δy = δΔϵ - aux ⋅ δΔψ ⋅ sin(ϵ₀)
    #
    # where `aux = Ψ_a ⋅ cos(ϵ₀) - χ_a`. Inverting this 2x2 system gives the expressions
    # below, whose determinant is `1 + aux²`.
    aux = Ψ_a * cϵ₀ - χ_a
    den = 1 + aux^2
    δΔϵ = (δy + aux * δx) / den
    δΔψ = (δx - aux * δy) / (sϵ₀ * den)

    return δΔϵ, δΔψ
end
