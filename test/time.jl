# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==========================================================================================
#
#   Tests related to Date and Time conversion.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# References
# ==========================================================================================
#
#   [1] http://aa.usno.navy.mil/data/docs/JulianDate.php
#
#   [2] https://www.ietf.org/timezones/data/leap-seconds.list
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# File: ./src/time.jl
# ==========================================================================================

# Function get_Δat
# ------------------------------------------------------------------------------------------

@testset "Function get_Δat"  begin
    # Leap seconds values obtained from [2].
    leap_secs = [
        2272060800 10 1 "Jan" 1972;
        2303683200 12 1 "Jan" 1973;
        2287785600 11 1 "Jul" 1972;
        2335219200 13 1 "Jan" 1974;
        2366755200 14 1 "Jan" 1975;
        2398291200 15 1 "Jan" 1976;
        2429913600 16 1 "Jan" 1977;
        2461449600 17 1 "Jan" 1978;
        2492985600 18 1 "Jan" 1979;
        2524521600 19 1 "Jan" 1980;
        2571782400 20 1 "Jul" 1981;
        2603318400 21 1 "Jul" 1982;
        2634854400 22 1 "Jul" 1983;
        2698012800 23 1 "Jul" 1985;
        2776982400 24 1 "Jan" 1988;
        2840140800 25 1 "Jan" 1990;
        2871676800 26 1 "Jan" 1991;
        2918937600 27 1 "Jul" 1992;
        2950473600 28 1 "Jul" 1993;
        2982009600 29 1 "Jul" 1994;
        3029443200 30 1 "Jan" 1996;
        3076704000 31 1 "Jul" 1997;
        3124137600 32 1 "Jan" 1999;
        3345062400 33 1 "Jan" 2006;
        3439756800 34 1 "Jan" 2009;
        3550089600 35 1 "Jul" 2012;
        3644697600 36 1 "Jul" 2015;
        3692217600 37 1 "Jan" 2017;
    ]

    for i in 1:size(leap_secs,1)
        ΔAT   = leap_secs[i,2]
        day   = leap_secs[i,3]
        month = begin
            if leap_secs[i,4] == "Jan"
                1
            elseif leap_secs[i,4] == "Jul"
                7
            else
                error("Invalid array `leap_secs`.")
            end
        end
        year  = leap_secs[i,5]

        @test get_Δat(date_to_jd(year,month,day,0,0,0)) == ΔAT

        # One second before the entry in `leap_secs`, we must have `ΔAT-1` leap seconds.
        # However, this is not true for the very first line.
        (i == 1) && continue
        @test get_Δat(date_to_jd(year,month,day,0,0,0)-1/86400) == ΔAT-1
    end
end

# Functions jd_ut1_to_utc and jd_utc_to_ut1
# ------------------------------------------------------------------------------------------

############################################################################################
#                                       Test Results
############################################################################################
#
# Scenario 01
# ==========================================================================================
#
# Example 3-7: Calculating Dynamical Time [1].
#
# The following date:
#
#   Mountain Standard Time Zone: May 14, 2004, 10:43
#
# is converted into the following one using ΔUT1 = -0.463326 s:
#
#   UT1: May 14, 2004, 16:42:59.5367
#
# Scenario 02
# ==========================================================================================
#
# Example 3-15: Performing IAU-76/FK5 reduction [1].
#
# The following UTC date:
#
#   UTC: April 6, 2004, 07:51:28.386009
#
# is converted into the following one using ΔUT1 = -0.4399619 s:
#
#   UT1: April 6, 2004, 07:51:27.946047
#
############################################################################################

@testset "Functions jd_ut1_to_utc and jd_utc_to_ut1" begin

    # Scenario 01
    # ======================================================================================

    ΔUT1 = -0.463326

    # jd_utc_to_ut1
    # --------------------------------------------------------------------------------------

    # At the mentioned date, Mountain Standard Time is 6h behind UTC.
    JD_UTC = date_to_jd(2004, 5, 14, 10+6, 43, 0)
    JD_UT1 = jd_utc_to_ut1(JD_UTC, ΔUT1)

    (year, month, day, hour, minute, second) = jd_to_date(JD_UT1)

    @test year   == 2004
    @test month  == 5
    @test day    == 14
    @test hour   == 16
    @test minute == 42
    @test second  ≈ 59.5367 atol = 1e-4

    # jd_ut1_to_utc
    # --------------------------------------------------------------------------------------

    JD_UT1 = date_to_jd(2004, 5, 14, 16, 42, 59.5367)
    JD_UTC = jd_ut1_to_utc(JD_UT1, ΔUT1)

    (year, month, day, hour, minute, second) = jd_to_date(JD_UTC)

    @test year   == 2004
    @test month  == 5
    @test day    == 14
    @test hour   == 10+6
    @test minute == 43
    @test second  ≈ 0.0000 atol = 1e-4

    # Scenario 02
    # ======================================================================================

    ΔUT1 = -0.4399619

    # jd_utc_to_ut1
    # --------------------------------------------------------------------------------------

    JD_UTC = date_to_jd(2004, 4, 6, 07, 51, 28.386009)
    JD_UT1 = jd_utc_to_ut1(JD_UTC, ΔUT1)

    (year, month, day, hour, minute, second) = jd_to_date(JD_UT1)

    @test year   == 2004
    @test month  == 4
    @test day    == 6
    @test hour   == 7
    @test minute == 51
    @test second  ≈ 27.946047 atol = 1e-4

    # jd_ut1_to_utc
    # --------------------------------------------------------------------------------------

    JD_UT1 = date_to_jd(2004, 4, 6, 07, 51, 27.946047)
    JD_UTC = jd_ut1_to_utc(JD_UT1, ΔUT1)

    (year, month, day, hour, minute, second) = jd_to_date(JD_UTC)

    @test year   == 2004
    @test month  == 4
    @test day    == 6
    @test hour   == 7
    @test minute == 51
    @test second  ≈ 28.386009 atol = 1e-4
end

# Functions jd_tt_to_utc and jd_utc_to_tt
# ------------------------------------------------------------------------------------------

############################################################################################
#                                 Test Results
############################################################################################
#
# Scenario 01
# ==========================================================================================
#
# Example 3-7: Calculating Dynamical Time [1].
#
# The following date:
#
#   Mountain Standard Time Zone: May 14, 2004, 10:43
#
# is converted into:
#
#   TT: May 14, 2004, 16:44:04.1840
#
# Scenario 02
# ==========================================================================================
#
# Example 3-15: Performing IAU-76/FK5 reduction [1].
#
# The following UTC date:
#
#   UTC: April 6, 2004, 07:51:28.386009
#
# is converted into:
#
#   JD [TT]: 2453101.828154745
#
############################################################################################

@testset "Functions jd_tt_to_utc and jd_utc_to_tt" begin

    # Scenario 01
    # ======================================================================================

    # jd_utc_to_tt
    # --------------------------------------------------------------------------------------

    # At the mentioned date, Mountain Standard Time is 6h behind UTC.
    JD_UTC = date_to_jd(2004, 5, 14, 10+6, 43, 0)
    JD_TT  = jd_utc_to_tt(JD_UTC)

    (year, month, day, hour, minute, second) = jd_to_date(JD_TT)

    @test year   == 2004
    @test month  == 5
    @test day    == 14
    @test hour   == 16
    @test minute == 44
    @test second  ≈ 04.1840 atol = 1e-4

    # jd_tt_to_utc
    # --------------------------------------------------------------------------------------

    JD_TT  = date_to_jd(2004, 5, 14, 16, 44, 04.1840)
    JD_UTC = jd_tt_to_utc(JD_TT)

    (year, month, day, hour, minute, second) = jd_to_date(JD_UTC)

    @test year   == 2004
    @test month  == 5
    @test day    == 14
    @test hour   == 16

    # TODO: Fix this rounding problem.
    if minute == 42
        @test minute == 42
        @test second  ≈ 60.0000 atol = 1e-4
    else
        @test minute == 43
        @test second  ≈ 0.0000 atol = 1e-4
    end

    # Scenario 02
    # ======================================================================================

    # jd_utc_to_tt
    # --------------------------------------------------------------------------------------

    # At the mentioned date, Mountain Standard Time is 6h behind UTC.
    JD_UTC = date_to_jd(2004, 4, 6, 07, 51, 28.386009)
    JD_TT  = jd_utc_to_tt(JD_UTC)

    @test JD_TT ≈ 2453101.828154745 atol = 1e-9

    # jd_tt_to_utc
    # --------------------------------------------------------------------------------------

    JD_TT  = 2453101.828154745
    JD_UTC = jd_tt_to_utc(JD_TT)

    (year, month, day, hour, minute, second) = jd_to_date(JD_UTC)

    @test year   == 2004
    @test month  == 4
    @test day    == 6
    @test hour   == 07
    @test minute == 51
    @test second  ≈ 28.386009 atol = 1e-4
end
