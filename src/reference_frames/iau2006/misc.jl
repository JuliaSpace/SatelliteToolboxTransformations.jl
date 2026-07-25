## Description #############################################################################
#
# Miscellaneous functions for the functions of IAU-2006 theory.
#
############################################################################################

"""
    _iau2006_sum(
        coefs::Tuple, t_tt::Number, M_s::Number, M_m::Number, u_Mm::Number, D_s::Number,
        Ω_m::Number, λ_M☿::Number, λ_M♀::Number, λ_Me::Number, λ_M♂::Number, λ_M♃::Number,
        λ_M♄::Number, λ_M⛢::Number, λ_M♆::Number, p_λ::Number
    ) -> Number

Compute a polynomial sum of sinusoidal terms used by the IAU-2006 theory.

# Arguments

- `coefs::Tuple`: Tuple of coefficient matrices for the polynomial terms.
- `t_tt::Number`: Julian centuries since J2000.0 in Terrestrial Time (TT).
- `M_s::Number`: Mean anomaly of the Sun, in radians.
- `M_m::Number`: Mean anomaly of the Moon, in radians.
- `u_Mm::Number`: Mean argument of latitude of the Moon, in radians.
- `D_s::Number`: Mean elongation of the Moon from the Sun, in radians.
- `Ω_m::Number`: Mean longitude of the ascending node of the Moon, in radians.
- `λ_M☿::Number`: Mean heliocentric longitude of Mercury, in radians.
- `λ_M♀::Number`: Mean heliocentric longitude of Venus, in radians.
- `λ_Me::Number`: Mean heliocentric longitude of the Earth, in radians.
- `λ_M♂::Number`: Mean heliocentric longitude of Mars, in radians.
- `λ_M♃::Number`: Mean heliocentric longitude of Jupiter, in radians.
- `λ_M♄::Number`: Mean heliocentric longitude of Saturn, in radians.
- `λ_M⛢::Number`: Mean heliocentric longitude of Uranus, in radians.
- `λ_M♆::Number`: Mean heliocentric longitude of Neptune, in radians.
- `p_λ::Number`: General accumulated precession in longitude, in radians.

# Returns

- `Number`: The value of the polynomial sum.
"""
function _iau2006_sum(
    coefs::Tuple,
    t_tt::Number,
    M_s::Number,
    M_m::Number,
    u_Mm::Number,
    D_s::Number,
    Ω_m::Number,
    λ_M☿::Number,
    λ_M♀::Number,
    λ_Me::Number,
    λ_M♂::Number,
    λ_M♃::Number,
    λ_M♄::Number,
    λ_M⛢::Number,
    λ_M♆::Number,
    p_λ::Number
)
    # Result of the sum.
    r = 0.0

    # Auxiliary variable to compute the powers of t_tt.
    t_tt_power = one(t_tt)

    # Number of sums.
    num_sums = length(coefs)

    @inbounds for i in 1:num_sums
        ci = coefs[i]

        # Result of this sum.
        rp = zero(r)

        # Number of coefficients in this sum.
        num_coefs = size(ci, 2)

        # Notice that the matrices were transposed when created to improve the
        # performance due to memory alignment.
        for j = 1:num_coefs
            As     = ci[ 2, j]
            Ac     = ci[ 3, j]
            ap     = ci[ 4, j] * M_m  + ci[ 5, j] * M_s  + ci[ 6, j] * u_Mm +
                     ci[ 7, j] * D_s  + ci[ 8, j] * Ω_m  + ci[ 9, j] * λ_M☿ +
                     ci[10, j] * λ_M♀ + ci[11, j] * λ_Me + ci[12, j] * λ_M♂ +
                     ci[13, j] * λ_M♃ + ci[14, j] * λ_M♄ + ci[15, j] * λ_M⛢ +
                     ci[16, j] * λ_M♆ + ci[17, j] * p_λ
            sj, cj = sincos(ap)
            rp    += (As * sj + Ac * cj) / 1e6
        end

        # Accumulate in the output variable.
        r += rp * t_tt_power

        # Update the t_tt power for the next pass.
        t_tt_power *= t_tt
    end

    return r
end
