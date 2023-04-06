# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==========================================================================================
#
#   Tests related to ECI to ECEF transformations.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# References
# ==========================================================================================
#
#   [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications.
#       Microcosm Press, Hawthorn, CA, USA.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Get the current EOP Data.
#
# TODO: The EOP data obtained from IERS website does not match the values in the examples in
# [1]. However, this should be enough, because 1) the individual functions at the low level
# are tested using the same values of [1], and 2) the difference is smaller than 30 cm.

eop_iau1980  = read_iers_eop("../eop_IAU1980.txt",  Val(:IAU1980))
eop_iau2000a = read_iers_eop("../eop_IAU2000A.txt", Val(:IAU2000A))

# File: ./src/transformations/eci_to_ecef.jl
# ==========================================================================================

# Functions: r_eci_to_ecef
# ------------------------------------------------------------------------------------------

############################################################################################
#                                        IAU-76/FK5
############################################################################################

# GCRF to ITRF
# ========================================================================================

############################################################################################
#                                       Test Results
############################################################################################
#
# Scenario 01
# ==========================================================================================
#
# Example 3-15: Performing IAU-76/FK5 reduction.
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_gcrf = 5102.50895790  i + 6123.01140070   j + 6378.13692820   k [km]
#
# one gets:
#
#   r_itrf = -1033.4793830    i + 7901.2952754    j + 6380.3565958    k [km]
#
############################################################################################

@testset "Function r_eci_to_ecef GCRF => ITRF" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_gcrf = [5102.50895790; 6123.01140070; 6378.13692820]

    D_itrf_gcrf = r_eci_to_ecef(GCRF(), ITRF(), jd_utc, eop_iau1980)
    r_itrf = D_itrf_gcrf * r_gcrf

    @test r_itrf[1] ≈ -1033.4793830 atol = 3e-4
    @test r_itrf[2] ≈ +7901.2952754 atol = 3e-4
    @test r_itrf[3] ≈ +6380.3565958 atol = 3e-4

    q_itrf_gcrf = r_eci_to_ecef(Quaternion, GCRF(), ITRF(), jd_utc, eop_iau1980)
    r_itrf = vect(q_itrf_gcrf \ r_gcrf * q_itrf_gcrf)

    @test r_itrf[1] ≈ -1033.4793830 atol = 3e-4
    @test r_itrf[2] ≈ +7901.2952754 atol = 3e-4
    @test r_itrf[3] ≈ +6380.3565958 atol = 3e-4
end

# J2000 to ITRF
# ==========================================================================================

############################################################################################
#                                       Test Results
############################################################################################
#
# Scenario 01
# ==========================================================================================
#
# Example 3-15: Performing IAU-76/FK5 reduction.
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_j2000 = 5102.50960000  i + 6123.01152000   j + 6378.13630000   k [km]
#
# one gets:
#
#   r_itrf = -1033.4793830    i + 7901.2952754    j + 6380.3565958    k [km]
#
############################################################################################

@testset "Function r_eci_to_ecef J2000 => ITRF" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_j2000 = [5102.50960000; 6123.01152000; 6378.13630000]

    D_itrf_j2000 = r_eci_to_ecef(J2000(), ITRF(), jd_utc, eop_iau1980)
    r_itrf = D_itrf_j2000 * r_j2000

    @test r_itrf[1] ≈ -1033.4793830 atol = 3e-4
    @test r_itrf[2] ≈ +7901.2952754 atol = 3e-4
    @test r_itrf[3] ≈ +6380.3565958 atol = 3e-4

    q_itrf_j2000 = r_eci_to_ecef(Quaternion, J2000(), ITRF(), jd_utc, eop_iau1980)
    r_itrf = vect(q_itrf_j2000 \ r_j2000 * q_itrf_j2000)

    @test r_itrf[1] ≈ -1033.4793830 atol = 3e-4
    @test r_itrf[2] ≈ +7901.2952754 atol = 3e-4
    @test r_itrf[3] ≈ +6380.3565958 atol = 3e-4
end

# TOD to ITRF
# ==========================================================================================

############################################################################################
#                                       Test Results
############################################################################################
#
# Scenario 01
# ==========================================================================================
#
# Example 3-15: Performing IAU-76/FK5 reduction.
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_tod = 5094.51620300   i + 6127.36527840   j + 6380.34453270   k [km]
#
# one gets:
#
#   r_itrf = -1033.4793830    i + 7901.2952754    j + 6380.3565958    k [km]
#
############################################################################################

@testset "Function r_eci_to_ecef TOD => ITRF" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_tod = [5094.51620300; 6127.36527840; 6380.34453270]

    D_itrf_tod = r_eci_to_ecef(TOD(), ITRF(), jd_utc, eop_iau1980)
    r_itrf = D_itrf_tod * r_tod

    @test r_itrf[1] ≈ -1033.4793830 atol = 3e-4
    @test r_itrf[2] ≈ +7901.2952754 atol = 3e-4
    @test r_itrf[3] ≈ +6380.3565958 atol = 3e-4

    q_itrf_tod = r_eci_to_ecef(Quaternion, TOD(), ITRF(), jd_utc, eop_iau1980)
    r_itrf = vect(q_itrf_tod \ r_tod * q_itrf_tod)

    @test r_itrf[1] ≈ -1033.4793830 atol = 3e-4
    @test r_itrf[2] ≈ +7901.2952754 atol = 3e-4
    @test r_itrf[3] ≈ +6380.3565958 atol = 3e-4
end

# MOD to ITRF
# ==========================================================================================

############################################################################################
#                                       Test Results
############################################################################################
#
# Scenario 01
# ==========================================================================================
#
# Example 3-15: Performing IAU-76/FK5 reduction.
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_mod = 5094.02837450   i + 6127.87081640   j + 6380.24851640   k [km]
#
# one gets:
#
#   r_itrf = -1033.4793830    i + 7901.2952754    j + 6380.3565958    k [km]
#
############################################################################################

@testset "Function r_eci_to_ecef MOD => ITRF" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_mod  = [5094.02837450; 6127.87081640; 6380.24851640]

    D_itrf_mod = r_eci_to_ecef(MOD(), ITRF(), jd_utc, eop_iau1980)
    r_itrf = D_itrf_mod * r_mod

    @test r_itrf[1] ≈ -1033.4793830 atol = 3e-4
    @test r_itrf[2] ≈ +7901.2952754 atol = 3e-4
    @test r_itrf[3] ≈ +6380.3565958 atol = 3e-4

    q_itrf_mod = r_eci_to_ecef(Quaternion, MOD(), ITRF(), jd_utc, eop_iau1980)
    r_itrf = vect(q_itrf_mod \ r_mod * q_itrf_mod)

    @test r_itrf[1] ≈ -1033.4793830 atol = 3e-4
    @test r_itrf[2] ≈ +7901.2952754 atol = 3e-4
    @test r_itrf[3] ≈ +6380.3565958 atol = 3e-4
end

# TEME to ITRF
# ==========================================================================================

############################################################################################
#                                       Test Results
############################################################################################
#
# Scenario 01
# ==========================================================================================
#
# Example 3-15: Performing IAU-76/FK5 reduction.
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_teme = 5094.18016210   i + 6127.64465950   j + 6380.34453270   k [km]
#
# one gets:
#
#   r_itrf = -1033.4793830    i + 7901.2952754    j + 6380.3565958    k [km]
#
############################################################################################

@testset "Function r_eci_to_ecef TEME => ITRF" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_teme = [5094.18016210; 6127.64465950; 6380.34453270]

    D_itrf_teme = r_eci_to_ecef(TEME(), ITRF(), jd_utc, eop_iau1980)
    r_itrf = D_itrf_teme * r_teme

    @test r_itrf[1] ≈ -1033.4793830 atol = 3e-4
    @test r_itrf[2] ≈ +7901.2952754 atol = 3e-4
    @test r_itrf[3] ≈ +6380.3565958 atol = 3e-4

    q_itrf_teme = r_eci_to_ecef(Quaternion, TEME(), ITRF(), jd_utc, eop_iau1980)
    r_itrf = vect(q_itrf_teme \ r_teme * q_itrf_teme)

    @test r_itrf[1] ≈ -1033.4793830 atol = 3e-4
    @test r_itrf[2] ≈ +7901.2952754 atol = 3e-4
    @test r_itrf[3] ≈ +6380.3565958 atol = 3e-4
end

# GCRF to PEF
# ==========================================================================================

############################################################################################
#                                       Test Results
############################################################################################
#
# Scenario 01
# ==========================================================================================
#
# Example 3-15: Performing IAU-76/FK5 reduction.
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_gcrf = 5102.50895790  i + 6123.01140070   j + 6378.13692820   k [km]
#
# one gets:
#
#   r_pef  = -1033.47503130   i + 7901.30558560   j + 6380.34453270   k [km]
#
############################################################################################

@testset "Function r_eci_to_ecef GCRF => PEF" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_gcrf = [5102.50895790; 6123.01140070; 6378.13692820]

    D_pef_gcrf = r_eci_to_ecef(GCRF(), PEF(), jd_utc, eop_iau1980)
    r_pef = D_pef_gcrf * r_gcrf

    @test r_pef[1] ≈ -1033.47503130 atol = 3e-4
    @test r_pef[2] ≈ +7901.30558560 atol = 3e-4
    @test r_pef[3] ≈ +6380.34453270 atol = 3e-4

    q_pef_gcrf = r_eci_to_ecef(Quaternion, GCRF(), PEF(), jd_utc, eop_iau1980)
    r_pef = vect(q_pef_gcrf \ r_gcrf * q_pef_gcrf)

    @test r_pef[1] ≈ -1033.47503130 atol = 3e-4
    @test r_pef[2] ≈ +7901.30558560 atol = 3e-4
    @test r_pef[3] ≈ +6380.34453270 atol = 3e-4
end

# J2000 to PEF
# ==========================================================================================

############################################################################################
#                                       Test Results
############################################################################################
#
# Scenario 01
# ==========================================================================================
#
# Example 3-15: Performing IAU-76/FK5 reduction.
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_j2000 = 5102.50960000  i + 6123.01152000   j + 6378.13630000   k [km]
#
# one gets:
#
#   r_pef  = -1033.47503130   i + 7901.30558560   j + 6380.34453270   k [km]
#
############################################################################################

@testset "Function r_eci_to_ecef J2000 => PEF" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_j2000 = [5102.50960000; 6123.01152000; 6378.13630000]

    D_pef_j2000 = r_eci_to_ecef(J2000(), PEF(), jd_utc, eop_iau1980)
    r_pef = D_pef_j2000 * r_j2000

    @test r_pef[1] ≈ -1033.47503130 atol = 3e-4
    @test r_pef[2] ≈ +7901.30558560 atol = 3e-4
    @test r_pef[3] ≈ +6380.34453270 atol = 3e-4

    q_pef_j2000 = r_eci_to_ecef(Quaternion, J2000(), PEF(), jd_utc, eop_iau1980)
    r_pef = vect(q_pef_j2000 \ r_j2000 * q_pef_j2000)

    @test r_pef[1] ≈ -1033.47503130 atol = 3e-4
    @test r_pef[2] ≈ +7901.30558560 atol = 3e-4
    @test r_pef[3] ≈ +6380.34453270 atol = 3e-4
end

# TOD to PEF
# ==========================================================================================

############################################################################################
#                                       Test Results
############################################################################################
#
# Scenario 01
# ==========================================================================================
#
# Example 3-15: Performing IAU-76/FK5 reduction.
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_tod = 5094.51620300   i + 6127.36527840   j + 6380.34453270   k [km]
#
# one gets:
#
#   r_pef  = -1033.47503130   i + 7901.30558560   j + 6380.34453270   k [km]
#
# If not EOP correction is used, then we get the same result by using:
#
#   r_tod = 5094.51478040   i + 6127.36646120   j + 6380.34453270   k [km]
#
# Notice, however, that this result is obtained by using the correct UT1.
#
############################################################################################

@testset "Function r_eci_to_ecef TOD => PEF" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_tod  = [5094.51620300; 6127.36527840; 6380.34453270]

    D_pef_tod = r_eci_to_ecef(TOD(), PEF(), jd_utc, eop_iau1980)
    r_pef = D_pef_tod * r_tod

    @test r_pef[1] ≈ -1033.47503130 atol = 3e-4
    @test r_pef[2] ≈ +7901.30558560 atol = 3e-4
    @test r_pef[3] ≈ +6380.34453270 atol = 3e-4

    q_pef_tod = r_eci_to_ecef(Quaternion, TOD(), PEF(), jd_utc, eop_iau1980)
    r_pef = vect(q_pef_tod \ r_tod * q_pef_tod)

    @test r_pef[1] ≈ -1033.47503130 atol = 3e-4
    @test r_pef[2] ≈ +7901.30558560 atol = 3e-4
    @test r_pef[3] ≈ +6380.34453270 atol = 3e-4

    # No EOP corrections
    # ======================================================================================

    # Notice that if we use jd_ut1, then the correction to TT will be wrong. However, this
    # will lead to a much smaller error than assuming that UTC = UT1.

    jd_ut1 = date_to_jd(2004,4,6,7,51,28.386009) - 0.4399619/86400
    r_tod  = [5094.51478040; 6127.36646120; 6380.34453270]

    D_pef_tod = r_eci_to_ecef(TOD(), PEF(), jd_ut1)
    r_pef = D_pef_tod * r_tod

    @test r_pef[1] ≈ -1033.47503130 atol = 1e-7
    @test r_pef[2] ≈ +7901.30558560 atol = 1e-7
    @test r_pef[3] ≈ +6380.34453270 atol = 1e-7

    q_pef_tod = r_eci_to_ecef(Quaternion, TOD(), PEF(), jd_ut1)
    r_pef = vect(q_pef_tod \ r_tod * q_pef_tod)

    @test r_pef[1] ≈ -1033.47503130 atol = 1e-7
    @test r_pef[2] ≈ +7901.30558560 atol = 1e-7
    @test r_pef[3] ≈ +6380.34453270 atol = 1e-7
end

# PEF to MOD
# ==========================================================================================

############################################################################################
#                                       Test Results
############################################################################################
#
# Scenario 01
# ==========================================================================================
#
# Example 3-15: Performing IAU-76/FK5 reduction.
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_mod = 5094.02837450   i + 6127.87081640   j + 6380.24851640   k [km]
#
# one gets:
#
#   r_pef  = -1033.47503130   i + 7901.30558560   j + 6380.34453270   k [km]
#
# If not EOP correction is used, then we get the same result by using:
#
#   r_mod = 5094.02901670   i + 6127.87093630   j + 6380.24788850   k [km]
#
# Notice, however, that this result is obtained by using the correct UT1.
#
############################################################################################

@testset "Function r_eci_to_ecef MOD => PEF" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_mod  = [5094.02837450; 6127.87081640; 6380.24851640]

    D_pef_mod = r_eci_to_ecef(MOD(), PEF(), jd_utc, eop_iau1980)
    r_pef = D_pef_mod * r_mod

    @test r_pef[1] ≈ -1033.47503130 atol = 3e-4
    @test r_pef[2] ≈ +7901.30558560 atol = 3e-4
    @test r_pef[3] ≈ +6380.34453270 atol = 3e-4

    q_pef_mod = r_eci_to_ecef(Quaternion, MOD(), PEF(), jd_utc, eop_iau1980)
    r_pef = vect(q_pef_mod \ r_mod * q_pef_mod)

    @test r_pef[1] ≈ -1033.47503130 atol = 3e-4
    @test r_pef[2] ≈ +7901.30558560 atol = 3e-4
    @test r_pef[3] ≈ +6380.34453270 atol = 3e-4

    # No EOP corrections
    # ======================================================================================

    # Notice that if we use jd_ut1, then the correction to TT will be wrong. However, this
    # will lead to a much smaller error than assuming that UTC = UT1.

    jd_ut1 = date_to_jd(2004,4,6,7,51,28.386009) - 0.4399619/86400
    r_mod  = [5094.02901670; 6127.87093630; 6380.24788850]

    D_pef_mod = r_eci_to_ecef(MOD(), PEF(), jd_ut1)
    r_pef = D_pef_mod * r_mod

    @test r_pef[1] ≈ -1033.47503130 atol = 8e-6
    @test r_pef[2] ≈ +7901.30558560 atol = 8e-6
    @test r_pef[3] ≈ +6380.34453270 atol = 8e-6

    q_pef_mod = r_eci_to_ecef(Quaternion, MOD(), PEF(), jd_ut1)
    r_pef = vect(q_pef_mod \ r_mod * q_pef_mod)

    @test r_pef[1] ≈ -1033.47503130 atol = 8e-6
    @test r_pef[2] ≈ +7901.30558560 atol = 8e-6
    @test r_pef[3] ≈ +6380.34453270 atol = 8e-6
end

# TEME to PEF
# ==========================================================================================

############################################################################################
#                                       Test Results
############################################################################################
#
# Scenario 01
# ==========================================================================================
#
# Example 3-15: Performing IAU-76/FK5 reduction.
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_teme = 5094.18016210   i + 6127.64465950   j + 6380.34453270   k [km]
#
# one gets:
#
#   r_pef  = -1033.47503130   i + 7901.30558560   j + 6380.34453270   k [km]
#
############################################################################################

@testset "Function r_eci_to_ecef TEME => PEF" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_teme = [5094.18016210; 6127.64465950; 6380.34453270]

    D_pef_teme = r_eci_to_ecef(TEME(), PEF(), jd_utc, eop_iau1980)
    r_pef = D_pef_teme * r_teme

    @test r_pef[1] ≈ -1033.47503130 atol = 3e-4
    @test r_pef[2] ≈ +7901.30558560 atol = 3e-4
    @test r_pef[3] ≈ +6380.34453270 atol = 3e-4

    q_pef_teme = r_eci_to_ecef(Quaternion, TEME(), PEF(), jd_utc, eop_iau1980)
    r_pef = vect(q_pef_teme \ r_teme * q_pef_teme)

    @test r_pef[1] ≈ -1033.47503130 atol = 3e-4
    @test r_pef[2] ≈ +7901.30558560 atol = 3e-4
    @test r_pef[3] ≈ +6380.34453270 atol = 3e-4
end

############################################################################################
#                                 IAU-2006/2010 CIO-based
############################################################################################

# GCRF => TIRS
# ==========================================================================================

############################################################################################
#                                       Test Results
############################################################################################
#
# Scenario 01
# ==========================================================================================
#
# Example 3-14: Performing an IAU-2000 reduction [1, p. 220]
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_gcrf = 5102.50895290  i + 6123.01139910 j + 6378.13693380 k [km]
#
# one gets:
#
#   r_tirs = -1033.47503120   i + 7901.30558560   j + 6380.34453270   k [km]
#
############################################################################################

@testset "Function r_eci_to_ecef GCRF => TIRS" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_gcrf = [5102.50895290; 6123.01139910; 6378.13693380]

    D_tirs_gcrf = r_eci_to_ecef(GCRF(), TIRS(), jd_utc, eop_iau2000a)
    r_tirs = D_tirs_gcrf * r_gcrf

    @test r_tirs[1] ≈ -1033.47503120 atol = 3e-4
    @test r_tirs[2] ≈ +7901.30558560 atol = 3e-4
    @test r_tirs[3] ≈ +6380.34453270 atol = 3e-4

    q_tirs_gcrf = r_eci_to_ecef(Quaternion, GCRF(), TIRS(), jd_utc, eop_iau2000a)
    r_tirs = vect(q_tirs_gcrf \ r_gcrf * q_tirs_gcrf)

    @test r_tirs[1] ≈ -1033.47503120 atol = 3e-4
    @test r_tirs[2] ≈ +7901.30558560 atol = 3e-4
    @test r_tirs[3] ≈ +6380.34453270 atol = 3e-4
end

# GCRF => ITRF
# ==========================================================================================

############################################################################################
#                                       Test Results
############################################################################################
#
# Scenario 01
# ==========================================================================================
#
# Example 3-14: Performing an IAU-2000 reduction [1, p. 220]
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_gcrf = 5102.50895290  i + 6123.01139910 j + 6378.13693380 k [km]
#
# one gets:
#
#   r_itrf = -1033.4793830    i + 7901.2952754    j + 6380.3565958    k [km]
#
############################################################################################

@testset "Function r_eci_to_ecef GCRF => ITRF" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_gcrf = [5102.50895290; 6123.01139910; 6378.13693380]

    D_itrf_gcrf = r_eci_to_ecef(GCRF(), ITRF(), jd_utc, eop_iau2000a)
    r_itrf = D_itrf_gcrf * r_gcrf

    @test r_itrf[1] ≈ -1033.4793830 atol = 3e-4
    @test r_itrf[2] ≈ +7901.2952754 atol = 3e-4
    @test r_itrf[3] ≈ +6380.3565958 atol = 3e-4

    q_itrf_gcrf = r_eci_to_ecef(Quaternion, GCRF(), ITRF(), jd_utc, eop_iau2000a)
    r_itrf = vect(q_itrf_gcrf \ r_gcrf * q_itrf_gcrf)

    @test r_itrf[1] ≈ -1033.4793830 atol = 3e-4
    @test r_itrf[2] ≈ +7901.2952754 atol = 3e-4
    @test r_itrf[3] ≈ +6380.3565958 atol = 3e-4
end

# CIRS => TIRS
# ==========================================================================================

############################################################################################
#                                       Test Results
############################################################################################
#
# Scenario 01
# ==========================================================================================
#
# Example 3-14: Performing an IAU-2000 reduction [1, p. 220]
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_cirs = -5100.01840470   i + 6122.78636480   j + 6380.34453270   k [km]
#
# one gets:
#
#   r_tirs = -1033.47503120   i + 7901.30558560   j + 6380.34453270   k [km]
#
############################################################################################

@testset "Function r_eci_to_ecef CIRS => TIRS" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_cirs = [+5100.01840470; +6122.78636480; +6380.34453270]

    D_tirs_cirs = r_eci_to_ecef(CIRS(), TIRS(), jd_utc, eop_iau2000a)
    r_tirs = D_tirs_cirs * r_cirs

    @test r_tirs[1] ≈ -1033.47503120 atol = 3e-4
    @test r_tirs[2] ≈ +7901.30558560 atol = 3e-4
    @test r_tirs[3] ≈ +6380.34453270 atol = 3e-4

    q_tirs_cirs = r_eci_to_ecef(Quaternion, CIRS(), TIRS(), jd_utc, eop_iau2000a)
    r_tirs = vect(q_tirs_cirs \ r_cirs * q_tirs_cirs)

    @test r_tirs[1] ≈ -1033.47503120 atol = 3e-4
    @test r_tirs[2] ≈ +7901.30558560 atol = 3e-4
    @test r_tirs[3] ≈ +6380.34453270 atol = 3e-4

    # NOTE: We do not have the values without the EOP corrections. Hence, we will perform
    # the conversion from UTC to UT1 manually to test the functions.
    jd_ut1 = jd_utc_to_ut1(jd_utc, eop_iau2000a.Δut1_utc(jd_utc))

    D_tirs_cirs = r_eci_to_ecef(CIRS(), TIRS(), jd_ut1)
    r_tirs = D_tirs_cirs * r_cirs

    @test r_tirs[1] ≈ -1033.47503120 atol = 3e-4
    @test r_tirs[2] ≈ +7901.30558560 atol = 3e-4
    @test r_tirs[3] ≈ +6380.34453270 atol = 3e-4

    q_tirs_cirs = r_eci_to_ecef(Quaternion, CIRS(), TIRS(), jd_ut1)
    r_tirs = vect(q_tirs_cirs \ r_cirs * q_tirs_cirs)

    @test r_tirs[1] ≈ -1033.47503120 atol = 3e-4
    @test r_tirs[2] ≈ +7901.30558560 atol = 3e-4
    @test r_tirs[3] ≈ +6380.34453270 atol = 3e-4
end

# CIRS => ITRF
# ==========================================================================================

############################################################################################
#                                       Test Results
############################################################################################
#
# Scenario 01
# ==========================================================================================
#
# Example 3-14: Performing an IAU-2000 reduction [1, p. 220]
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_cirs = -5100.01840470   i + 6122.78636480   j + 6380.34453270   k [km]
#
# one gets:
#
#   r_itrf = -1033.4793830    i + 7901.2952754    j + 6380.3565958    k [km]
#
############################################################################################

@testset "Function r_eci_to_ecef CIRS => ITRF" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_cirs = [+5100.01840470; +6122.78636480; +6380.34453270]

    D_itrf_cirs = r_eci_to_ecef(CIRS(), ITRF(), jd_utc, eop_iau2000a)
    r_itrf = D_itrf_cirs * r_cirs

    @test r_itrf[1] ≈ -1033.4793830 atol = 3e-4
    @test r_itrf[2] ≈ +7901.2952754 atol = 3e-4
    @test r_itrf[3] ≈ +6380.3565958 atol = 3e-4

    q_itrf_cirs = r_eci_to_ecef(Quaternion, CIRS(), ITRF(), jd_utc, eop_iau2000a)
    r_itrf = vect(q_itrf_cirs \ r_cirs * q_itrf_cirs)

    @test r_itrf[1] ≈ -1033.4793830 atol = 3e-4
    @test r_itrf[2] ≈ +7901.2952754 atol = 3e-4
    @test r_itrf[3] ≈ +6380.3565958 atol = 3e-4
end

############################################################################################
#                               IAU-2006/2010 equinox-based
############################################################################################

# ERS => ITRF
# ==========================================================================================

############################################################################################
#                                       Test Results
############################################################################################
#
# Scenario 01
# ==========================================================================================
#
# Example 3-14: Performing an IAU-2000 reduction [1, p. 220]
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_ers  = +5094.51462800   i + 6127.36658790   j + 6380.34453270   k [km]
#
# one gets:
#
#   r_itrf = -1033.4793830    i + 7901.2952754    j + 6380.3565958    k [km]
#
############################################################################################

@testset "Function r_eci_to_ecef ERS => ITRF" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_ers = [+5094.51462800; +6127.36658790; +6380.34453270]

    D_itrf_ers = r_eci_to_ecef(ERS(), ITRF(), jd_utc, eop_iau2000a)
    r_itrf = D_itrf_ers * r_ers

    @test r_itrf[1] ≈ -1033.4793830 atol = 5e-4
    @test r_itrf[2] ≈ +7901.2952754 atol = 5e-4
    @test r_itrf[3] ≈ +6380.3565958 atol = 5e-4

    q_itrf_ers = r_eci_to_ecef(Quaternion, ERS(), ITRF(), jd_utc, eop_iau2000a)
    r_itrf = vect(q_itrf_ers \ r_ers * q_itrf_ers)

    @test r_itrf[1] ≈ -1033.4793830 atol = 5e-4
    @test r_itrf[2] ≈ +7901.2952754 atol = 5e-4
    @test r_itrf[3] ≈ +6380.3565958 atol = 5e-4
end

# MOD => ITRF
# ==========================================================================================

############################################################################################
#                                       Test Results
############################################################################################
#
# Scenario 01
# ==========================================================================================
#
# Example 3-14: Performing an IAU-2000 reduction [1, p. 220]
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_mod  = +5094.02896110   i + 6127.87113500   j + 6380.24774200   k [km]
#
# one gets:
#
#   r_itrf = -1033.4793830    i + 7901.2952754    j + 6380.3565958    k [km]
#
############################################################################################

@testset "Function r_eci_to_ecef MOD => ITRF" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_mod = [+5094.02896110; +6127.87113500; +6380.24774200]

    D_itrf_mod = r_eci_to_ecef(MOD06(), ITRF(), jd_utc, eop_iau2000a)
    r_itrf = D_itrf_mod * r_mod

    @test r_itrf[1] ≈ -1033.4793830 atol = 5e-4
    @test r_itrf[2] ≈ +7901.2952754 atol = 5e-4
    @test r_itrf[3] ≈ +6380.3565958 atol = 5e-4

    q_itrf_mod = r_eci_to_ecef(Quaternion, MOD06(), ITRF(), jd_utc, eop_iau2000a)
    r_itrf = vect(q_itrf_mod \ r_mod * q_itrf_mod)

    @test r_itrf[1] ≈ -1033.4793830 atol = 5e-4
    @test r_itrf[2] ≈ +7901.2952754 atol = 5e-4
    @test r_itrf[3] ≈ +6380.3565958 atol = 5e-4
end

# MJ2000 => ITRF
# ==========================================================================================

############################################################################################
#                                       Test Results
############################################################################################
#
# Scenario 01
# ==========================================================================================
#
# Example 3-14: Performing an IAU-2000 reduction [1, p. 220]
#
# According to this example and Table 3-6, using:
#
#   UTC     = April 6, 2004, 07:51:28.386009
#   r_j2000 = 5102.50960000  i + 6123.01152000   j + 6378.13630000   k [km]
#
# one gets:
#
#   r_itrf = -1033.4793830    i + 7901.2952754    j + 6380.3565958    k [km]
#
# Notice that the transformation we are testing here does not convert to the
# original J2000. However, this result is close enough for a test comparison.
#
############################################################################################

@testset "Function r_eci_to_ecef MJ2000 => ITRF" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_mj2000 = [5102.50960000; 6123.01152000; 6378.13630000]

    D_itrf_mj2000 = r_eci_to_ecef(MJ2000(), ITRF(), jd_utc, eop_iau2000a)
    r_itrf = D_itrf_mj2000 * r_mj2000

    @test r_itrf[1] ≈ -1033.4793830 atol = 5e-4
    @test r_itrf[2] ≈ +7901.2952754 atol = 5e-4
    @test r_itrf[3] ≈ +6380.3565958 atol = 5e-4

    q_itrf_mj2000 = r_eci_to_ecef(Quaternion, MJ2000(), ITRF(), jd_utc, eop_iau2000a)
    r_itrf = vect(q_itrf_mj2000 \ r_mj2000 * q_itrf_mj2000)

    @test r_itrf[1] ≈ -1033.4793830 atol = 5e-4
    @test r_itrf[2] ≈ +7901.2952754 atol = 5e-4
    @test r_itrf[3] ≈ +6380.3565958 atol = 5e-4
end

# ERS => TIRS
# ==========================================================================================

############################################################################################
#                                       Test Results
############################################################################################
#
# Scenario 01
# ==========================================================================================
#
# Example 3-14: Performing an IAU-2000 reduction [1, p. 220]
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_ers  = +5094.51462800   i + 6127.36658790   j + 6380.34453270   k [km]
#
# one gets:
#
#   r_tirs = -1033.47503120   i + 7901.30558560   j + 6380.34453270   k [km]
#
############################################################################################

@testset "Function r_eci_to_ecef ERS => TIRS" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_ers = [+5094.51462800; +6127.36658790; +6380.34453270]

    D_tirs_ers = r_eci_to_ecef(ERS(), TIRS(), jd_utc, eop_iau2000a)
    r_tirs = D_tirs_ers * r_ers

    @test r_tirs[1] ≈ -1033.47503120 atol = 5e-4
    @test r_tirs[2] ≈ +7901.30558560 atol = 5e-4
    @test r_tirs[3] ≈ +6380.34453270 atol = 5e-4

    q_tirs_ers = r_eci_to_ecef(Quaternion, ERS(), TIRS(), jd_utc, eop_iau2000a)
    r_tirs = vect(q_tirs_ers \ r_ers * q_tirs_ers)

    @test r_tirs[1] ≈ -1033.47503120 atol = 5e-4
    @test r_tirs[2] ≈ +7901.30558560 atol = 5e-4
    @test r_tirs[3] ≈ +6380.34453270 atol = 5e-4

    # NOTE: We do not have the values without the EOP corrections. Hence, we will perform
    # the conversion from UTC to UT1 manually to test the functions.
    jd_ut1 = jd_utc_to_ut1(jd_utc, eop_iau2000a.Δut1_utc(jd_utc))

    D_tirs_ers = r_eci_to_ecef(ERS(), TIRS(), jd_ut1)
    r_tirs = D_tirs_ers * r_ers

    @test r_tirs[1] ≈ -1033.47503120 atol = 5e-4
    @test r_tirs[2] ≈ +7901.30558560 atol = 5e-4
    @test r_tirs[3] ≈ +6380.34453270 atol = 5e-4

    q_tirs_ers = r_eci_to_ecef(Quaternion, ERS(), TIRS(), jd_ut1)
    r_tirs = vect(q_tirs_ers \ r_ers * q_tirs_ers)

    @test r_tirs[1] ≈ -1033.47503120 atol = 5e-4
    @test r_tirs[2] ≈ +7901.30558560 atol = 5e-4
    @test r_tirs[3] ≈ +6380.34453270 atol = 5e-4
end

# MOD => TIRS
# ==========================================================================================

############################################################################################
#                                       Test Results
############################################################################################
#
# Scenario 01
# ==========================================================================================
#
# Example 3-14: Performing an IAU-2000 reduction [1, p. 220]
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_mod  = +5094.02896110   i + 6127.87113500   j + 6380.24774200   k [km]
#
# one gets:
#
#   r_tirs = -1033.47503120   i + 7901.30558560   j + 6380.34453270   k [km]
#
############################################################################################

@testset "Function r_eci_to_ecef MOD => TIRS" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_mod = [+5094.02896110; +6127.87113500; +6380.24774200]

    D_tirs_mod = r_eci_to_ecef(MOD06(), TIRS(), jd_utc, eop_iau2000a)
    r_tirs = D_tirs_mod * r_mod

    @test r_tirs[1] ≈ -1033.47503120 atol = 5e-4
    @test r_tirs[2] ≈ +7901.30558560 atol = 5e-4
    @test r_tirs[3] ≈ +6380.34453270 atol = 5e-4

    q_tirs_mod = r_eci_to_ecef(Quaternion, MOD06(), TIRS(), jd_utc, eop_iau2000a)
    r_tirs = vect(q_tirs_mod \ r_mod * q_tirs_mod)

    @test r_tirs[1] ≈ -1033.47503120 atol = 5e-4
    @test r_tirs[2] ≈ +7901.30558560 atol = 5e-4
    @test r_tirs[3] ≈ +6380.34453270 atol = 5e-4

    # NOTE: We do not have the values without the EOP corrections. Hence, we will perform
    # the conversion from UTC to UT1 manually to test the functions.
    jd_ut1 = jd_utc_to_ut1(jd_utc, eop_iau2000a.Δut1_utc(jd_utc))

    D_tirs_mod = r_eci_to_ecef(MOD06(), TIRS(), jd_ut1)
    r_tirs = D_tirs_mod * r_mod

    @test r_tirs[1] ≈ -1033.47503120 atol = 5e-4
    @test r_tirs[2] ≈ +7901.30558560 atol = 5e-4
    @test r_tirs[3] ≈ +6380.34453270 atol = 5e-4

    q_tirs_mod = r_eci_to_ecef(Quaternion, MOD06(), TIRS(), jd_ut1)
    r_tirs = vect(q_tirs_mod \ r_mod * q_tirs_mod)

    @test r_tirs[1] ≈ -1033.47503120 atol = 5e-4
    @test r_tirs[2] ≈ +7901.30558560 atol = 5e-4
    @test r_tirs[3] ≈ +6380.34453270 atol = 5e-4
end

# MJ2000 => TIRS
# ==========================================================================================

############################################################################################
#                                       Test Results
############################################################################################
#
# Scenario 01
# ==========================================================================================
#
# Example 3-14: Performing an IAU-2000 reduction [1, p. 220]
#
# According to this example and Table 3-6, using:
#
#   UTC     = April 6, 2004, 07:51:28.386009
#   r_j2000 = 5102.50960000  i + 6123.01152000   j + 6378.13630000   k [km]
#
# one gets:
#
#   r_tirs = -1033.47503120   i + 7901.30558560   j + 6380.34453270   k [km]
#
# Notice that the transformation we are testing here does not convert to the original J2000.
# However, this result is close enough for a test comparison.
#
############################################################################################

@testset "Function r_eci_to_ecef MJ2000 => TIRS" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_mj2000 = [5102.50960000; 6123.01152000; 6378.13630000]

    D_tirs_mj2000 = r_eci_to_ecef(MJ2000(), TIRS(), jd_utc, eop_iau2000a)
    r_tirs = D_tirs_mj2000 * r_mj2000

    @test r_tirs[1] ≈ -1033.47503120 atol = 5e-4
    @test r_tirs[2] ≈ +7901.30558560 atol = 5e-4
    @test r_tirs[3] ≈ +6380.34453270 atol = 5e-4

    q_tirs_mj2000 = r_eci_to_ecef(Quaternion, MJ2000(), TIRS(), jd_utc, eop_iau2000a)
    r_tirs = vect(q_tirs_mj2000 \ r_mj2000 * q_tirs_mj2000)

    @test r_tirs[1] ≈ -1033.47503120 atol = 5e-4
    @test r_tirs[2] ≈ +7901.30558560 atol = 5e-4
    @test r_tirs[3] ≈ +6380.34453270 atol = 5e-4

    # NOTE: We do not have the values without the EOP corrections. Hence, we will perform
    # the conversion from UTC to UT1 manually to test the functions.
    jd_ut1 = jd_utc_to_ut1(jd_utc, eop_iau2000a.Δut1_utc(jd_utc))

    D_tirs_mj2000 = r_eci_to_ecef(MJ2000(), TIRS(), jd_ut1)
    r_tirs = D_tirs_mj2000 * r_mj2000

    @test r_tirs[1] ≈ -1033.47503120 atol = 5e-4
    @test r_tirs[2] ≈ +7901.30558560 atol = 5e-4
    @test r_tirs[3] ≈ +6380.34453270 atol = 5e-4

    q_tirs_mj2000 = r_eci_to_ecef(Quaternion, MJ2000(), TIRS(), jd_ut1)
    r_tirs = vect(q_tirs_mj2000 \ r_mj2000 * q_tirs_mj2000)

    @test r_tirs[1] ≈ -1033.47503120 atol = 5e-4
    @test r_tirs[2] ≈ +7901.30558560 atol = 5e-4
    @test r_tirs[3] ≈ +6380.34453270 atol = 5e-4
end
