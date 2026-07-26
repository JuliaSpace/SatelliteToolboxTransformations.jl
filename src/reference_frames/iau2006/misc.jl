## Description #############################################################################
#
# Miscellaneous functions for the functions of IAU-2006 theory.
#
############################################################################################

"""
    Iau2006Series{T}

Pre-processed form of one of the IAU-2006 series tables, holding the terms in the layout
consumed by [`_iau2006_sum`](@ref).

The IERS tables are transcribed in `constants/*.jl` with one term per row and seventeen
columns: a running term index, the sine and cosine amplitudes, and the fourteen multipliers
of the fundamental arguments (five luni-solar followed by nine planetary). This structure
stores the same data with the term index dropped and the terms split by whether they involve
the planetary arguments.

# Fields

- `luni_solar::Matrix{T}`: Terms whose nine planetary multipliers are all zero, one term per
    column, with rows `As`, `Ac`, and the five luni-solar multipliers.
- `mixed::Matrix{T}`: The remaining terms, one term per column, with rows `As`, `Ac`, and all
    fourteen multipliers.
"""
struct Iau2006Series{T}
    luni_solar::Matrix{T}
    mixed::Matrix{T}
end

"""
    _split_iau2006_table(coefs::AbstractMatrix) -> Iau2006Series

Pre-process the raw IAU-2006 series table `coefs` into an [`Iau2006Series`](@ref).

`coefs` must have 17 rows, i.e. it must be the transposed transcription of an IERS table so
that each column holds one term (see [`Iau2006Series`](@ref) for the row meaning).

This is called once per table when the package is loaded, and it addresses two problems with
the raw tables:

1. The transcriptions are written as `Float64[...]'`, which yields a **lazy** `Adjoint` over
   a column-major parent. No data is ever reordered, so reading the 17 coefficients of one
   term touches 16 different cache lines. Indexing here materializes the result, making each
   term contiguous.
2. In most tables the majority of the terms have all nine planetary multipliers equal to zero
   (e.g. 650 of the 1306 terms of `_IAU_2006_CIP_X0`, and every term of `_IAU_2006_CIP_X2`).
   Splitting them out lets [`_iau2006_sum`](@ref) skip nine multiply-adds per such term.
"""
function _split_iau2006_table(coefs::AbstractMatrix)
    size(coefs, 1) != 17 && throw(ArgumentError(
        "The IAU-2006 series table must have 17 rows, but it has $(size(coefs, 1))."
    ))

    # A term is purely luni-solar when all of its nine planetary multipliers (rows 9 to 17)
    # are zero.
    is_luni_solar = [all(iszero, @view coefs[9:17, j]) for j in axes(coefs, 2)]

    # Rows 2 and 3 are the amplitudes, rows 4 to 8 the luni-solar multipliers, and rows 9 to
    # 17 the planetary ones. Row 1 (the term index) is never used and is dropped here.
    luni_solar = coefs[2:8,  is_luni_solar]
    mixed      = coefs[2:17, .!is_luni_solar]

    return Iau2006Series(luni_solar, mixed)
end

"""
    _iau2006_sum(
        coefs::Tuple, t_tt::Number, M_s::Number, M_m::Number, u_Mm::Number, D_s::Number,
        Ω_m::Number, λ_M☿::Number, λ_M♀::Number, λ_Me::Number, λ_M♂::Number, λ_M♃::Number,
        λ_M♄::Number, λ_M⛢::Number, λ_M♆::Number, p_λ::Number
    ) -> Number

Compute a polynomial sum of sinusoidal terms used by the IAU-2006 theory.

# Arguments

- `coefs::Tuple`: Tuple of [`Iau2006Series`](@ref), one per power of `t_tt`, in increasing
    order of the power.
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
    # Type of the accumulators. It must be obtained by promotion instead of being hardcoded
    # to `Float64`, otherwise the accumulators would change type on the first iteration when
    # the inputs are not `Float64` (e.g. `Float32`, `ForwardDiff.Dual`, or `Measurement`),
    # which makes them inferred as a union and boxes them inside these long loops.
    NT = promote_type(
        eltype(first(coefs).luni_solar),
        typeof(t_tt), typeof(M_s), typeof(M_m), typeof(u_Mm), typeof(D_s), typeof(Ω_m),
        typeof(λ_M☿), typeof(λ_M♀), typeof(λ_Me), typeof(λ_M♂), typeof(λ_M♃),
        typeof(λ_M♄), typeof(λ_M⛢), typeof(λ_M♆), typeof(p_λ)
    )

    # Result of the sum.
    r = zero(NT)

    # Auxiliary variable to compute the powers of t_tt.
    t_tt_power = one(t_tt)

    @inbounds for i in eachindex(coefs)
        ls = coefs[i].luni_solar
        mx = coefs[i].mixed

        # Result of this sum.
        rp = zero(NT)

        # Terms that depend only on the luni-solar arguments. These dominate most tables, and
        # handling them separately avoids nine multiply-adds by zero for each one.
        for j in axes(ls, 2)
            ap = ls[3, j] * M_m + ls[4, j] * M_s  + ls[5, j] * u_Mm +
                 ls[6, j] * D_s + ls[7, j] * Ω_m
            sj, cj = sincos(ap)
            rp += ls[1, j] * sj + ls[2, j] * cj
        end

        # Terms that also depend on the planetary arguments.
        for j in axes(mx, 2)
            ap = mx[ 3, j] * M_m  + mx[ 4, j] * M_s  + mx[ 5, j] * u_Mm +
                 mx[ 6, j] * D_s  + mx[ 7, j] * Ω_m  + mx[ 8, j] * λ_M☿ +
                 mx[ 9, j] * λ_M♀ + mx[10, j] * λ_Me + mx[11, j] * λ_M♂ +
                 mx[12, j] * λ_M♃ + mx[13, j] * λ_M♄ + mx[14, j] * λ_M⛢ +
                 mx[15, j] * λ_M♆ + mx[16, j] * p_λ
            sj, cj = sincos(ap)
            rp += mx[1, j] * sj + mx[2, j] * cj
        end

        # Accumulate in the output variable. The amplitudes in the IERS tables are given in
        # units of 1e-6 arcsec, so the scaling is applied once per sub-sum here instead of
        # once per term inside the loops above.
        r += rp * t_tt_power / 1e6

        # Update the t_tt power for the next pass.
        t_tt_power *= t_tt
    end

    return r
end
