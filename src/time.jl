## Description #############################################################################
#
# Functions related time transformations.
#
## References ##############################################################################
#
# [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm Press,
#     Hawthorn, CA, USA.
#
# [2] https://support.microsoft.com/en-us/help/214019/method-to-determine-whether-a-year-is-a-leap-year
#
############################################################################################

export jd_ut1_to_utc, jd_utc_to_ut1
export jd_utc_to_tt,  jd_tt_to_utc
export get_Δat

############################################################################################
#                                        Constants                                         #
############################################################################################

# Tables containing the leap seconds between UTC and the International Atomic Time (TAI).
# Notice that only the dates in which an increment in the leap seconds occurred should be
# added to these tables.
#
# The instants and the values are kept in two separate, packed vectors so that the lookup in
# `get_Δat` can use a binary search over contiguous memory.

# Julian Day in which each leap second was introduced. It **must** be sorted in ascending
# order, since `get_Δat` performs a binary search on it.
const _ΔAT_JD = [
    2441499.500000
    2441683.500000
    2442048.500000
    2442413.500000
    2442778.500000
    2443144.500000
    2443509.500000
    2443874.500000
    2444239.500000
    2444786.500000
    2445151.500000
    2445516.500000
    2446247.500000
    2447161.500000
    2447892.500000
    2448257.500000
    2448804.500000
    2449169.500000
    2449534.500000
    2450083.500000
    2450630.500000
    2451179.500000
    2453736.500000
    2454832.500000
    2456109.500000
    2457204.500000
    2457754.500000
]

# Accumulated leap seconds [s] valid from the corresponding instant in `_ΔAT_JD` onwards.
const _ΔAT_VALUE = [
    11.0
    12.0
    13.0
    14.0
    15.0
    16.0
    17.0
    18.0
    19.0
    20.0
    21.0
    22.0
    23.0
    24.0
    25.0
    26.0
    27.0
    28.0
    29.0
    30.0
    31.0
    32.0
    33.0
    34.0
    35.0
    36.0
    37.0
]

"""
    get_Δat(JD::Number) -> Number

Get the accumulated leap seconds (ΔAT) [s] between UTC and International Atomic Time (TAI)
in the given `JD`. This function searches for ΔAT in the table `_ΔAT_JD` / `_ΔAT_VALUE`.

# Remarks

If `JD` is before `_ΔAT_JD[begin]` (1972-07-01), then 10 will be returned. **Notice that this
can lead to errors.**

If `JD` is after `_ΔAT_JD[end]`, then `_ΔAT_VALUE[end]` will be returned, because it is not
possible yet to predict when leap seconds will be added.
"""
function get_Δat(JD::Number)
    T = float(typeof(JD))

    # `searchsortedlast` returns the index of the last instant that is not after `JD`, or 0
    # if `JD` precedes the entire table.
    k = searchsortedlast(_ΔAT_JD, JD)

    # In this case, `JD` is before the first entry in the table.
    k == 0 && return T(10)

    return T(@inbounds _ΔAT_VALUE[k])
end

############################################################################################
#                                        Functions                                         #
############################################################################################

"""
    jd_utc_to_ut1(JD_UTC::Number, ΔUT1::Number) -> Float64

Convert the Julian Day in UTC `JD_UTC` to the Julian Day in UT1 using the accumulated
difference `ΔUT1`, which is provided by IERS EOP Data.
"""
jd_utc_to_ut1(JD_UTC::Number, ΔUT1::Number) = JD_UTC + ΔUT1 / 86400

"""
    jd_ut1_to_utc(JD_UT1::Number, ΔUT1::Number) -> Float64

Convert the Julian Day in UT1 `JD_UT1` to the Julian Day in UTC using the accumulated
difference `ΔUT1`, which is provided by IERS EOP Data.
"""
jd_ut1_to_utc(JD_UT1::Number, ΔUT1::Number) = JD_UT1 - ΔUT1 / 86400

"""
    jd_utc_to_ut1(JD_UTC::Number, eop::Union{EopIau1980, EopIau2000A}) -> Float64

Convert the Julian Day in UTC `JD_UTC` to the Julian Day in UT1 using the accumulated
difference given by the EOP Data `eop` (see [`fetch_iers_eop`](@ref)). Notice that the
accumulated difference will be interpolated.
"""
function jd_utc_to_ut1(JD_UTC::Number, eop::Union{EopIau1980, EopIau2000A})
    return jd_utc_to_ut1(JD_UTC, eop.Δut1_utc(JD_UTC))
end

"""
    jd_ut1_to_utc(JD_UT1::Number, eop::Union{EopIau1980, EopIau2000A}) -> Float64

Convert the Julian Day in UT1 `JD_UT1` to the Julian Day in UTC using the accumulated
difference given by the EOP Data `eop` (see [`fetch_iers_eop`](@ref)). Notice that the
accumulated difference will be interpolated and the inverse is solved iteratively; the
result is therefore valid even though the EOP interpolation is tabulated against UTC.
"""
function jd_ut1_to_utc(JD_UT1::Number, eop::Union{EopIau1980, EopIau2000A})
    # ΔUT1 is tabulated as a function of UTC, so evaluating it at JD_UT1 is not a valid
    # inverse. Fixed-point iteration is sufficient because the correction changes by only
    # milliseconds over an EOP sample interval, making the map a strong contraction: the
    # first pass already lands within ~1e-8 s of the fixed point, and the second one reaches
    # it exactly in floating point.
    JD_UTC = JD_UT1
    for _ = 1:2
        JD_UTC = jd_ut1_to_utc(JD_UT1, eop.Δut1_utc(JD_UTC))
    end
    return JD_UTC
end

"""
    jd_utc_to_tt(JD_UTC::Number[, ΔAT::Number]) -> Float64

Convert the Julian Day in UTC `JD_UTC` to the Julian Day in TT (Terrestrial Time) using the
accumulated difference `ΔAT` between UTC and the International Atomic Time (TAI). If no
value is provided, then the leap seconds will be obtained from the table `_ΔAT_JD` /
`_ΔAT_VALUE`. **Notice that, in this case, if a date previous to 1972-07-01 is provided,
then a fixed value of 10 will be used, leading to wrong computations.**
"""
jd_utc_to_tt(JD_UTC::Number, ΔAT::Number) = JD_UTC + (ΔAT + 32.184) / 86400

function jd_utc_to_tt(JD_UTC::Number)
    ΔAT = get_Δat(JD_UTC)
    return jd_utc_to_tt(JD_UTC, ΔAT)
end

"""
    jd_tt_to_utc(JD_TT::Number, ΔAT::Number) -> Float64

Convert the Julian Day in TT `JD_TT` (Terrestrial Time) to the Julian Day in UTC
(Coordinated Universal Time) using the accumulated difference `ΔAT` between UTC and the
International Atomic Time (TAI). If no value is provided, then the leap seconds will be
obtained from the table `_ΔAT_JD` / `_ΔAT_VALUE`. **Notice that, in this case, if a date
previous to 1972-07-01 is provided, then a fixed value of 10 will be used, leading to wrong
computations.**
"""
jd_tt_to_utc(JD_TT::Number, ΔAT::Number) = JD_TT - (ΔAT + 32.184) / 86400

function jd_tt_to_utc(JD_TT::Number)
    # ΔAT is a function of UTC, not TT. `get_Δat` is a step function, so the first estimate
    # can only be wrong when it falls on the opposite side of a leap boundary from the true
    # UTC instant. A single re-evaluation using that estimate is therefore enough to select
    # the offset on the correct side of the boundary.
    JD_UTC = jd_tt_to_utc(JD_TT, get_Δat(JD_TT))
    return jd_tt_to_utc(JD_TT, get_Δat(JD_UTC))
end
