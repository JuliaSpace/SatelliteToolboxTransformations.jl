## Description #############################################################################
#
# Functions to compute the nutation according to IAU-76/FK5.
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

export nutation_fk5

############################################################################################
#                                        Constants                                         #
############################################################################################

############################################################################################
#
# == 1980 IAU Theory of Nutation Coefficients ==============================================
#
# Those coefficients can be found on:
#
#   Seidelmann, P. K. 1980 IAU theory of nutation - The final report of the IAU Working
#   Group on Nutation. Celestial Mechanics, vol. 27, p. 79-106.
#
# However, the .dat file that was used to create this matrix was obtained from
# this website:
#
#   http://hpiers.obspm.fr/eop-pc/models/nutations/nut.html
#
# Notice that the order of them is not equal to that presented in the original paper, but
# this have no impact when computing the nutation. Moreover, this is the same order that is
# presented in [1](p. 1043).
#
############################################################################################

const _IAU_1980_NUTATION_COEFFICIENTS = [
    # Notation used in [1, p. 226].
    #
    # an1  an2  an3  an4  an5        Ai            Bi         Ci            Di
    #                  Units:  [0.0001"]  [0.0001"/JC]  [0.0001"]  [0.0001"/JC]
     0    0    0    0    1  -171996.0       -174.2    92025.0           8.9;
     0    0    2   -2    2   -13187.0         -1.6     5736.0          -3.1;
     0    0    2    0    2    -2274.0         -0.2      977.0          -0.5;
     0    0    0    0    2     2062.0          0.2     -895.0           0.5;
     0   -1    0    0    0    -1426.0          3.4       54.0          -0.1;
     1    0    0    0    0      712.0          0.1       -7.0           0.0;
     0    1    2   -2    2     -517.0          1.2      224.0          -0.6;
     0    0    2    0    1     -386.0         -0.4      200.0           0.0;
     1    0    2    0    2     -301.0          0.0      129.0          -0.1;
     0   -1    2   -2    2      217.0         -0.5      -95.0           0.3;
    -1    0    0    2    0      158.0          0.0       -1.0           0.0;
     0    0    2   -2    1      129.0          0.1      -70.0           0.0;
    -1    0    2    0    2      123.0          0.0      -53.0           0.0;
     1    0    0    0    1       63.0          0.1      -33.0           0.0;
     0    0    0    2    0       63.0          0.0       -2.0           0.0;
    -1    0    2    2    2      -59.0          0.0       26.0           0.0;
    -1    0    0    0    1      -58.0         -0.1       32.0           0.0;
     1    0    2    0    1      -51.0          0.0       27.0           0.0;
    -2    0    0    2    0      -48.0          0.0        1.0           0.0;
    -2    0    2    0    1       46.0          0.0      -24.0           0.0;
     0    0    2    2    2      -38.0          0.0       16.0           0.0;
     2    0    2    0    2      -31.0          0.0       13.0           0.0;
     2    0    0    0    0       29.0          0.0       -1.0           0.0;
     1    0    2   -2    2       29.0          0.0      -12.0           0.0;
     0    0    2    0    0       26.0          0.0       -1.0           0.0;
     0    0    2   -2    0      -22.0          0.0        0.0           0.0;
    -1    0    2    0    1       21.0          0.0      -10.0           0.0;
     0    2    0    0    0       17.0         -0.1        0.0           0.0;
     0    2    2   -2    2      -16.0          0.1        7.0           0.0;
    -1    0    0    2    1       16.0          0.0       -8.0           0.0;
     0    1    0    0    1      -15.0          0.0        9.0           0.0;
     1    0    0   -2    1      -13.0          0.0        7.0           0.0;
     0   -1    0    0    1      -12.0          0.0        6.0           0.0;
     2    0   -2    0    0       11.0          0.0        0.0           0.0;
    -1    0    2    2    1      -10.0          0.0        5.0           0.0;
     1    0    2    2    2       -8.0          0.0        3.0           0.0;
     0   -1    2    0    2       -7.0          0.0        3.0           0.0;
     0    0    2    2    1       -7.0          0.0        3.0           0.0;
     1    1    0   -2    0       -7.0          0.0        0.0           0.0;
     0    1    2    0    2        7.0          0.0       -3.0           0.0;
    -2    0    0    2    1       -6.0          0.0        3.0           0.0;
     0    0    0    2    1       -6.0          0.0        3.0           0.0;
     2    0    2   -2    2        6.0          0.0       -3.0           0.0;
     1    0    0    2    0        6.0          0.0        0.0           0.0;
     1    0    2   -2    1        6.0          0.0       -3.0           0.0;
     0    0    0   -2    1       -5.0          0.0        3.0           0.0;
     0   -1    2   -2    1       -5.0          0.0        3.0           0.0;
     2    0    2    0    1       -5.0          0.0        3.0           0.0;
     1   -1    0    0    0        5.0          0.0        0.0           0.0;
     1    0    0   -1    0       -4.0          0.0        0.0           0.0;
     0    0    0    1    0       -4.0          0.0        0.0           0.0;
     0    1    0   -2    0       -4.0          0.0        0.0           0.0;
     1    0   -2    0    0        4.0          0.0        0.0           0.0;
     2    0    0   -2    1        4.0          0.0       -2.0           0.0;
     0    1    2   -2    1        4.0          0.0       -2.0           0.0;
     1    1    0    0    0       -3.0          0.0        0.0           0.0;
     1   -1    0   -1    0       -3.0          0.0        0.0           0.0;
    -1   -1    2    2    2       -3.0          0.0        1.0           0.0;
     0   -1    2    2    2       -3.0          0.0        1.0           0.0;
     1   -1    2    0    2       -3.0          0.0        1.0           0.0;
     3    0    2    0    2       -3.0          0.0        1.0           0.0;
    -2    0    2    0    2       -3.0          0.0        1.0           0.0;
     1    0    2    0    0        3.0          0.0        0.0           0.0;
    -1    0    2    4    2       -2.0          0.0        1.0           0.0;
     1    0    0    0    2       -2.0          0.0        1.0           0.0;
    -1    0    2   -2    1       -2.0          0.0        1.0           0.0;
     0   -2    2   -2    1       -2.0          0.0        1.0           0.0;
    -2    0    0    0    1       -2.0          0.0        1.0           0.0;
     2    0    0    0    1        2.0          0.0       -1.0           0.0;
     3    0    0    0    0        2.0          0.0        0.0           0.0;
     1    1    2    0    2        2.0          0.0       -1.0           0.0;
     0    0    2    1    2        2.0          0.0       -1.0           0.0;
     1    0    0    2    1       -1.0          0.0        0.0           0.0;
     1    0    2    2    1       -1.0          0.0        1.0           0.0;
     1    1    0   -2    1       -1.0          0.0        0.0           0.0;
     0    1    0    2    0       -1.0          0.0        0.0           0.0;
     0    1    2   -2    0       -1.0          0.0        0.0           0.0;
     0    1   -2    2    0       -1.0          0.0        0.0           0.0;
     1    0   -2    2    0       -1.0          0.0        0.0           0.0;
     1    0   -2   -2    0       -1.0          0.0        0.0           0.0;
     1    0    2   -2    0       -1.0          0.0        0.0           0.0;
     1    0    0   -4    0       -1.0          0.0        0.0           0.0;
     2    0    0   -4    0       -1.0          0.0        0.0           0.0;
     0    0    2    4    2       -1.0          0.0        0.0           0.0;
     0    0    2   -1    2       -1.0          0.0        0.0           0.0;
    -2    0    2    4    2       -1.0          0.0        1.0           0.0;
     2    0    2    2    2       -1.0          0.0        0.0           0.0;
     0   -1    2    0    1       -1.0          0.0        0.0           0.0;
     0    0   -2    0    1       -1.0          0.0        0.0           0.0;
     0    0    4   -2    2        1.0          0.0        0.0           0.0;
     0    1    0    0    2        1.0          0.0        0.0           0.0;
     1    1    2   -2    2        1.0          0.0       -1.0           0.0;
     3    0    2   -2    2        1.0          0.0        0.0           0.0;
    -2    0    2    2    2        1.0          0.0       -1.0           0.0;
    -1    0    0    0    2        1.0          0.0       -1.0           0.0;
     0    0   -2    2    1        1.0          0.0        0.0           0.0;
     0    1    2    0    1        1.0          0.0        0.0           0.0;
    -1    0    4    0    2        1.0          0.0        0.0           0.0;
     2    1    0   -2    0        1.0          0.0        0.0           0.0;
     2    0    0    2    0        1.0          0.0        0.0           0.0;
     2    0    2   -2    1        1.0          0.0       -1.0           0.0;
     2    0   -2    0    1        1.0          0.0        0.0           0.0;
     1   -1    0   -2    0        1.0          0.0        0.0           0.0;
    -1    0    0    1    1        1.0          0.0        0.0           0.0;
    -1   -1    0    2    1        1.0          0.0        0.0           0.0;
     0    1    0    1    0        1.0          0.0        0.0           0.0;
]

# The table above is transcribed with one term per row, which is the layout documented for the
# `nut_coefs_1980` argument of `nutation_fk5`. Julia stores it column-major, so reading the
# nine coefficients of a single term touches nine different cache lines. This transposed copy,
# built once when the package is loaded, makes each term contiguous.
#
# The same reasoning applies to the IAU-2006 series tables, see `_split_iau2006_table`.
const _IAU_1980_NUTATION_COEFFICIENTS_T = permutedims(_IAU_1980_NUTATION_COEFFICIENTS)

############################################################################################
#                                        Functions                                         #
############################################################################################

"""
    _nutation_fk5_series(
        ::Type{NT},
        coefs::AbstractMatrix,
        n_max::Integer,
        t_tt::Number,
        M_m::Number,
        M_s::Number,
        u_Mm::Number,
        D_s::Number,
        Ω_m::Number
    ) where NT -> NTuple{2, NT}

Accumulate the first `n_max` terms of the 1980 IAU nutation series.

# Arguments

- `::Type{NT}`: Type of the accumulators. The caller must provide it so that it does not
    depend on which table is passed in `coefs`.
- `coefs::AbstractMatrix`: Coefficient table holding **one term per column**, the rows being
    `an1`, `an2`, `an3`, `an4`, `an5`, `Ai`, `Bi`, `Ci`, and `Di`.
- `n_max::Integer`: Number of terms to accumulate.
- `t_tt::Number`: Julian centuries since J2000.0 [TT].
- `M_m::Number`: Mean anomaly of the Moon [rad].
- `M_s::Number`: Mean anomaly of the Sun [rad].
- `u_Mm::Number`: Mean argument of latitude of the Moon [rad].
- `D_s::Number`: Mean elongation of the Moon from the Sun [rad].
- `Ω_m::Number`: Mean longitude of the ascending node of the Moon [rad].

# Returns

- `NT`: Nutation in longitude [0.0001"].
- `NT`: Nutation in obliquity of the ecliptic [0.0001"].
"""
function _nutation_fk5_series(
    ::Type{NT},
    coefs::AbstractMatrix,
    n_max::Integer,
    t_tt::Number,
    M_m::Number,
    M_s::Number,
    u_Mm::Number,
    D_s::Number,
    Ω_m::Number,
) where {NT}
    ΔΨ_1980 = zero(NT)
    Δϵ_1980 = zero(NT)

    @inbounds for i in 1:n_max
        # Unpack values. Each term is one column, hence these nine reads are contiguous.
        an1 = coefs[1, i]
        an2 = coefs[2, i]
        an3 = coefs[3, i]
        an4 = coefs[4, i]
        an5 = coefs[5, i]
        Ai  = coefs[6, i]
        Bi  = coefs[7, i]
        Ci  = coefs[8, i]
        Di  = coefs[9, i]

        a_pi = an1 * M_m + an2 * M_s + an3 * u_Mm + an4 * D_s + an5 * Ω_m

        sin_a_pi, cos_a_pi = sincos(a_pi)

        ΔΨ_1980 += (Ai + Bi * t_tt) * sin_a_pi
        Δϵ_1980 += (Ci + Di * t_tt) * cos_a_pi
    end

    return ΔΨ_1980, Δϵ_1980
end

"""
    nutation_fk5(
        jd_tt::Number,
        n_max::Integer = 106,
        nut_coefs_1980::AbstractMatrix = _IAU_1980_NUTATION_COEFFICIENTS;
        kwargs...
    ) -> NTuple{3, Number}

Compute the nutation parameters at the Julian Day `jd_tt` [Terrestrial Time] using the 1980
IAU Theory of Nutation. The coefficients are `nut_coefs_1980` that must be a matrix in which
each line has the following syntax **[1]**(p. 1043):

    an1  an2  an3  an4  an5  Ai  Bi  Ci  Di

where the units of `Ai` and `Ci` are [0.0001"] and the units of `Bi` and `Di` are
[0.0001"/JC]. The user can also specify the number of coefficients `n_max` that will be used
when computing the nutation. If `n_max` is omitted, it defaults to 106.

# Keywords

- `verbose::Val`: If `Val(true)`, warn when `n_max` is outside the supported range and is
    replaced by the default value of 106.
    (**Default** = `Val(false)`)

# Returns

- `Number`: The mean obliquity of the ecliptic [rad].
- `Number`: The nutation in obliquity of the ecliptic [rad].
- `Number`: The nutation in longitude [rad].

# References

- **[1]**: Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm
    Press, Hawthorn, CA, USA.
"""
function nutation_fk5(
    jd_tt::Number,
    n_max::Integer = 106,
    nut_coefs_1980::AbstractMatrix = _IAU_1980_NUTATION_COEFFICIENTS;
    verbose::Val{verbosity} = Val(false),
) where {verbosity}
    # Check inputs. The effective number of terms is bound to a new variable so that its type
    # does not depend on the type of `n_max`.
    n_terms = if n_max > 106
        verbosity && @warn(
            "The maximum number of coefficients to compute nutation using IAU-76/FK5 theory is 106."
        )
        106
    elseif n_max <= 0
        verbosity &&
            @warn("n_max must greater than 0. The default value will be used (106).")
        106
    else
        Int(n_max)
    end

    # Validate the user-provided table before the bounded loop below. In particular, a
    # custom table may contain fewer than the 106 standard terms or fewer than nine columns.
    n_rows, n_cols = size(nut_coefs_1980)
    n_terms > n_rows && throw(
        ArgumentError(
            "nut_coefs_1980 must have at least n_max rows (got $n_rows, n_max = $n_terms).",
        ),
    )
    n_cols < 9 &&
        throw(ArgumentError("nut_coefs_1980 must have at least 9 columns (got $n_cols)."))
    Base.require_one_based_indexing(nut_coefs_1980)

    # Compute the Julian Centuries from `jd_tt`.
    t_tt = (jd_tt - JD_J2000) / 36525

    # == Mean Obliquity of the Ecliptic ====================================================

    # Compute the mean obliquity of the ecliptic [°].
    mϵ_1980 = @evalpoly(t_tt, 23.439291, -0.0130042, -1.64e-7, +5.04e-7)

    # Reduce to the interval [0, 360]° and convert to [rad].
    mϵ_1980 = deg2rad(mod(mϵ_1980, 360))

    # == Delaunay Parameters of the Sun and Moon ===========================================

    # Evaluate the Delaunay parameters associated with the Moon and the Sun
    # in the interval [0, 360]°.
    #
    # The parameters here were updated as stated in the errata [2].
    r = 360

    M_m = @evalpoly(t_tt, +134.96298139, +(1325r + 198.8673981), +0.0086972, +1.78e-5)
    M_m = deg2rad(mod(M_m, 360))

    M_s = @evalpoly(t_tt, +357.52772333, +(99r + 359.0503400), -0.0001603, -3.3e-6)
    M_s = deg2rad(mod(M_s, 360))

    u_Mm = @evalpoly(t_tt, +93.27191028, +(1342r + 82.0175381), -0.0036825, +3.1e-6)
    u_Mm = deg2rad(mod(u_Mm, 360))

    D_s = @evalpoly(t_tt, +297.85036306, +(1236r + 307.1114800), -0.0019142, +5.3e-6)
    D_s = deg2rad(mod(D_s, 360))

    Ω_m = @evalpoly(t_tt, +125.04452222, -(5r + 134.1362608), +0.0020708, +2.2e-6)
    Ω_m = deg2rad(mod(Ω_m, 360))

    # == Nutation in Longitude and Obliquity ===============================================

    # Compute the nutation in the longitude and in obliquity.
    #
    # NOTE: The accumulators must be initialized with the type that results from the
    # arithmetic inside the loop, and not with a hardcoded `0.0`. Otherwise, they would
    # change type on the first iteration whenever `jd_tt` or the coefficient table is not
    # `Float64` (e.g. `Float32`, `ForwardDiff.Dual`, or `Measurement`), which makes the
    # accumulators inferred as a union and boxes them inside this 106-term loop.
    #
    # The type is obtained here, from the table the user provided, so that it does not depend
    # on which of the two branches below is taken.
    NT = typeof(zero(eltype(nut_coefs_1980)) * zero(t_tt) * zero(M_m))

    # The default table has a pre-transposed copy, which makes the coefficients of each term
    # contiguous. A user-provided table is wrapped in a lazy `transpose` so that the loop only
    # needs the one-term-per-column layout.
    ΔΨ_1980, Δϵ_1980 = if nut_coefs_1980 === _IAU_1980_NUTATION_COEFFICIENTS
        _nutation_fk5_series(
            NT,
            _IAU_1980_NUTATION_COEFFICIENTS_T,
            n_terms,
            t_tt,
            M_m,
            M_s,
            u_Mm,
            D_s,
            Ω_m,
        )
    else
        _nutation_fk5_series(
            NT, transpose(nut_coefs_1980), n_terms, t_tt, M_m, M_s, u_Mm, D_s, Ω_m
        )
    end

    # The nutation coefficients in `nut_coefs_1980` lead to angles with unit 0.0001". Hence,
    # we must convert to [rad]. The factor is converted to the accumulator type so that it
    # does not widen the result.
    ΔΨ_1980 *= oftype(ΔΨ_1980, 1e-4 * _ARCSEC_TO_RAD)
    Δϵ_1980 *= oftype(Δϵ_1980, 1e-4 * _ARCSEC_TO_RAD)

    # Return the values.
    return mϵ_1980, Δϵ_1980, ΔΨ_1980
end

"""
    _equation_of_equinoxes_1982(
        jd_tt::Number,
        Δψ_1980::Number,
        mϵ_1980::Number
    ) -> Number

Compute the complete form of the 1982 equation of the equinoxes [rad].

The equation of the equinoxes is the difference between the Greenwich apparent sidereal time
and the Greenwich mean sidereal time. The two complementary terms that depend on the mean
longitude of the ascending node of the Moon are the ones introduced in **[1]**.

# Arguments

- `jd_tt::Number`: Julian Day [TT].
- `Δψ_1980::Number`: Nutation in longitude [rad], including the IERS EOP correction if the
    caller applies one.
- `mϵ_1980::Number`: Mean obliquity of the ecliptic [rad].

# Returns

- `Number`: Equation of the equinoxes [rad].

# References

- **[1]**: Gontier, A. M., Capitaine, N (1991). High-Accuracy Equation of Equinoxes and VLBI
    Astrometric Modelling. Radio Interferometry: Theory, Techniques and Applications, IAU
    Coll. 131, ASP Conference Series, Vol. 19.
"""
@inline function _equation_of_equinoxes_1982(
    jd_tt::Number, Δψ_1980::Number, mϵ_1980::Number
)
    # Compute the Julian Centuries from `jd_tt`.
    t_tt = (jd_tt - JD_J2000) / 36525

    # Evaluate the Delaunay parameter associated with the Moon in the interval [0, 360]°.
    #
    # The parameters here were updated as stated in the errata [2] of the nutation reference.
    r   = 360
    Ω_m = @evalpoly(t_tt, + 125.04452222, - (5r + 134.1362608), + 0.0020708, + 2.2e-6)
    Ω_m = deg2rad(mod(Ω_m, 360))

    # The complementary terms are given in [arcsec] [1], and the errata [2] confirms that the
    # coefficient of `sin(2Ω_m)` is also in [arcsec]. Hence, they must be converted to [rad].
    return Δψ_1980 * cos(mϵ_1980) +
           (0.002640 * sin(Ω_m) + 0.000063 * sin(2Ω_m)) * _ARCSEC_TO_RAD
end
