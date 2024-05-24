## Description #############################################################################
#
# Tests related to ECEF to ECI transformations.
#
## References ##############################################################################
#
# [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm Press,
#     Hawthorn, CA, USA.
#
############################################################################################

# Get the current EOP.
#
# TODO: The EOP obtained from IERS website does not match the values in the examples in [1].
# However, this should be enough, because 1) the individual functions at the low level are
# tested using the same values of [1], and 2) the difference is smaller than 30 cm.

eop_iau1980  = read_iers_eop("../eop_IAU1980.txt",  Val(:IAU1980))
eop_iau2000a = read_iers_eop("../eop_IAU2000A.txt", Val(:IAU2000A))

# == File: ./src/reference_frames/ecef_to_eci.jl ===========================================

# -- Functions: r_ecef_to_eci --------------------------------------------------------------

############################################################################################
#                                       IAU-76 / FK5                                       #
############################################################################################

# == ITRF to GCRF ==========================================================================

############################################################################################
#                                       Test Results                                       #
############################################################################################
#
# == Scenario 01 ===========================================================================
#
# Example 3-15: Performing IAU-76/FK5 reduction.
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_itrf = -1033.4793830    i + 7901.2952754    j + 6380.3565958    k [km]
#
# one gets:
#
#   r_gcrf = 5102.50895790  i + 6123.01140070   j + 6378.13692820   k [km]
#
############################################################################################

@testset "Function r_ecef_to_eci ITRF => GCRF" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_itrf = [-1033.4793830; 7901.2952754; 6380.3565958]

    D_gcrf_itrf = r_ecef_to_eci(ITRF(), GCRF(), jd_utc, eop_iau1980)
    r_gcrf = D_gcrf_itrf * r_itrf

    @test r_gcrf[1] ≈ +5102.50895790 atol = 3e-4
    @test r_gcrf[2] ≈ +6123.01140070 atol = 3e-4
    @test r_gcrf[3] ≈ +6378.13692820 atol = 3e-4

    q_gcrf_itrf = r_ecef_to_eci(Quaternion, ITRF(), GCRF(), jd_utc, eop_iau1980)
    r_gcrf = vect(q_gcrf_itrf \ r_itrf * q_gcrf_itrf)

    @test r_gcrf[1] ≈ +5102.50895790 atol = 3e-4
    @test r_gcrf[2] ≈ +6123.01140070 atol = 3e-4
    @test r_gcrf[3] ≈ +6378.13692820 atol = 3e-4
end

# == ITRF to J2000 =========================================================================

############################################################################################
#                                       Test Results                                       #
############################################################################################
#
# == Scenario 01 ===========================================================================
#
# Example 3-15: Performing IAU-76/FK5 reduction.
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_itrf = -1033.4793830    i + 7901.2952754    j + 6380.3565958    k [km]
#
# one gets:
#
#   r_j2000 = 5102.50960000  i + 6123.01152000   j + 6378.13630000   k [km]
#
############################################################################################

@testset "Function r_ecef_to_eci ITRF => J2000" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_itrf = [-1033.4793830; 7901.2952754; 6380.3565958]

    D_j2000_itrf = r_ecef_to_eci(ITRF(), J2000(), jd_utc, eop_iau1980)
    r_j2000 = D_j2000_itrf * r_itrf

    @test r_j2000[1] ≈ +5102.50960000 atol = 3e-4
    @test r_j2000[2] ≈ +6123.01152000 atol = 3e-4
    @test r_j2000[3] ≈ +6378.13630000 atol = 3e-4

    q_j2000_itrf = r_ecef_to_eci(Quaternion, ITRF(), J2000(), jd_utc, eop_iau1980)
    r_j2000 = vect(q_j2000_itrf \ r_itrf * q_j2000_itrf)

    @test r_j2000[1] ≈ +5102.50960000 atol = 3e-4
    @test r_j2000[2] ≈ +6123.01152000 atol = 3e-4
    @test r_j2000[3] ≈ +6378.13630000 atol = 3e-4
end

# == ITRF to TOD ===========================================================================

############################################################################################
#                                       Test Results                                       #
############################################################################################
#
# == Scenario 01 ===========================================================================
#
# Example 3-15: Performing IAU-76/FK5 reduction.
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_itrf = -1033.4793830    i + 7901.2952754    j + 6380.3565958    k [km]
#
# one gets:
#
#   r_tod = 5094.51620300   i + 6127.36527840   j + 6380.34453270   k [km]
#
############################################################################################

@testset "Function r_ecef_to_eci ITRF => TOD" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_itrf = [-1033.4793830; 7901.2952754; 6380.3565958]

    D_tod_itrf = r_ecef_to_eci(ITRF(), TOD(), jd_utc, eop_iau1980)
    r_tod = D_tod_itrf * r_itrf

    @test r_tod[1] ≈ +5094.51620300 atol = 3e-4
    @test r_tod[2] ≈ +6127.36527840 atol = 3e-4
    @test r_tod[3] ≈ +6380.34453270 atol = 3e-4

    q_tod_itrf = r_ecef_to_eci(Quaternion, ITRF(), TOD(), jd_utc, eop_iau1980)
    r_tod = vect(q_tod_itrf \ r_itrf * q_tod_itrf)

    @test r_tod[1] ≈ +5094.51620300 atol = 3e-4
    @test r_tod[2] ≈ +6127.36527840 atol = 3e-4
    @test r_tod[3] ≈ +6380.34453270 atol = 3e-4
end

# == ITRF to MOD ===========================================================================

############################################################################################
#                                       Test Results                                       #
############################################################################################
#
# == Scenario 01 ===========================================================================
#
# Example 3-15: Performing IAU-76/FK5 reduction.
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_itrf = -1033.4793830    i + 7901.2952754    j + 6380.3565958    k [km]
#
# one gets:
#
#   r_mod = 5094.02837450   i + 6127.87081640   j + 6380.24851640   k [km]
#
############################################################################################

@testset "Function r_ecef_to_eci ITRF => MOD" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_itrf = [-1033.4793830; 7901.2952754; 6380.3565958]

    D_mod_itrf = r_ecef_to_eci(ITRF(), MOD(), jd_utc, eop_iau1980)
    r_mod = D_mod_itrf * r_itrf

    @test r_mod[1] ≈ +5094.02837450 atol = 3e-4
    @test r_mod[2] ≈ +6127.87081640 atol = 3e-4
    @test r_mod[3] ≈ +6380.24851640 atol = 3e-4

    q_mod_itrf = r_ecef_to_eci(Quaternion, ITRF(), MOD(), jd_utc, eop_iau1980)
    r_mod = vect(q_mod_itrf \ r_itrf * q_mod_itrf)

    @test r_mod[1] ≈ +5094.02837450 atol = 3e-4
    @test r_mod[2] ≈ +6127.87081640 atol = 3e-4
    @test r_mod[3] ≈ +6380.24851640 atol = 3e-4
end

# == ITRF to TEME ==========================================================================

############################################################################################
#                                       Test Results                                       #
############################################################################################
#
# == Scenario 01 ===========================================================================
#
# Example 3-15: Performing IAU-76/FK5 reduction.
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_itrf = -1033.4793830   i + 7901.2952754    j + 6380.3565958    k [km]
#
# one gets:
#
#   r_teme = 5094.18016210   i + 6127.64465950   j + 6380.34453270   k [km]
#
############################################################################################

@testset "Function r_ecef_to_eci ITRF => TEME" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_itrf = [-1033.4793830; 7901.2952754; 6380.3565958]

    D_teme_itrf = r_ecef_to_eci(ITRF(), TEME(), jd_utc, eop_iau1980)
    r_teme = D_teme_itrf * r_itrf

    @test r_teme[1] ≈ +5094.18016210 atol = 3e-4
    @test r_teme[2] ≈ +6127.64465950 atol = 3e-4
    @test r_teme[3] ≈ +6380.34453270 atol = 3e-4

    q_teme_itrf = r_ecef_to_eci(Quaternion, ITRF(), TEME(), jd_utc, eop_iau1980)
    r_teme = vect(q_teme_itrf \ r_itrf * q_teme_itrf)

    @test r_teme[1] ≈ +5094.18016210 atol = 3e-4
    @test r_teme[2] ≈ +6127.64465950 atol = 3e-4
    @test r_teme[3] ≈ +6380.34453270 atol = 3e-4
end

# == PEF to GCRF ===========================================================================

############################################################################################
#                                       Test Results                                       #
############################################################################################
#
# == Scenario 01 ===========================================================================
#
# Example 3-15: Performing IAU-76/FK5 reduction.
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_pef  = -1033.47503130   i + 7901.30558560   j + 6380.34453270   k [km]
#
# one gets:
#
#   r_gcrf = 5102.50895790  i + 6123.01140070   j + 6378.13692820   k [km]
#
############################################################################################

@testset "Function r_ecef_to_eci PEF => GCRF" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_pef  = [-1033.47503130; 7901.30558560; 6380.34453270]

    D_gcrf_pef = r_ecef_to_eci(PEF(), GCRF(), jd_utc, eop_iau1980)
    r_gcrf = D_gcrf_pef * r_pef

    @test r_gcrf[1] ≈ +5102.50895790 atol = 3e-4
    @test r_gcrf[2] ≈ +6123.01140070 atol = 3e-4
    @test r_gcrf[3] ≈ +6378.13692820 atol = 3e-4

    q_gcrf_pef = r_ecef_to_eci(Quaternion, PEF(), GCRF(), jd_utc, eop_iau1980)
    r_gcrf = vect(q_gcrf_pef \ r_pef * q_gcrf_pef)

    @test r_gcrf[1] ≈ +5102.50895790 atol = 3e-4
    @test r_gcrf[2] ≈ +6123.01140070 atol = 3e-4
    @test r_gcrf[3] ≈ +6378.13692820 atol = 3e-4
end

# == PEF to J2000 ==========================================================================

############################################################################################
#                                       Test Results                                       #
############################################################################################
#
# == Scenario 01 ===========================================================================
#
# Example 3-15: Performing IAU-76/FK5 reduction.
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_pef  = -1033.47503130   i + 7901.30558560   j + 6380.34453270   k [km]
#
# one gets:
#
#   r_j2000 = 5102.50960000  i + 6123.01152000   j + 6378.13630000   k [km]
#
############################################################################################

@testset "Function r_ecef_to_eci PEF => J2000" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_pef  = [-1033.47503130; 7901.30558560; 6380.34453270]

    D_j2000_pef = r_ecef_to_eci(PEF(), J2000(), jd_utc, eop_iau1980)
    r_j2000 = D_j2000_pef * r_pef

    @test r_j2000[1] ≈ +5102.50960000 atol = 3e-4
    @test r_j2000[2] ≈ +6123.01152000 atol = 3e-4
    @test r_j2000[3] ≈ +6378.13630000 atol = 3e-4

    q_j2000_pef = r_ecef_to_eci(Quaternion, PEF(), J2000(), jd_utc, eop_iau1980)
    r_j2000 = vect(q_j2000_pef \ r_pef * q_j2000_pef)

    @test r_j2000[1] ≈ +5102.50960000 atol = 3e-4
    @test r_j2000[2] ≈ +6123.01152000 atol = 3e-4
    @test r_j2000[3] ≈ +6378.13630000 atol = 3e-4
end

# == PEF to TOD ============================================================================

############################################################################################
#                                       Test Results                                       #
############################################################################################
#
# == Scenario 01 ===========================================================================
#
# Example 3-15: Performing IAU-76/FK5 reduction.
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_pef  = -1033.47503130   i + 7901.30558560   j + 6380.34453270   k [km]
#
# one gets:
#
#   r_tod = 5094.51620300   i + 6127.36527840   j + 6380.34453270   k [km]
#
# If not EOP correction is used, then we get:
#
#   r_tod = 5094.51478040   i + 6127.36646120   j + 6380.34453270   k [km]
#
# Notice, however, that this result is obtained by using the correct UT1.
#
############################################################################################

@testset "Function r_ecef_to_eci PEF => TOD" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_pef  = [-1033.47503130; 7901.30558560; 6380.34453270]

    D_tod_pef = r_ecef_to_eci(PEF(), TOD(), jd_utc, eop_iau1980)
    r_tod = D_tod_pef * r_pef

    @test r_tod[1] ≈ +5094.51620300 atol = 3e-4
    @test r_tod[2] ≈ +6127.36527840 atol = 3e-4
    @test r_tod[3] ≈ +6380.34453270 atol = 3e-4

    q_tod_pef = r_ecef_to_eci(Quaternion, PEF(), TOD(), jd_utc, eop_iau1980)
    r_tod = vect(q_tod_pef \ r_pef * q_tod_pef)

    @test r_tod[1] ≈ +5094.51620300 atol = 3e-4
    @test r_tod[2] ≈ +6127.36527840 atol = 3e-4
    @test r_tod[3] ≈ +6380.34453270 atol = 3e-4

    # == No EOP corrections ================================================================

    # Notice that if we use jd_ut1, then the correction to TT will be wrong.
    # However, this will lead to a much smaller error than assuming that UTC =
    # UT1.

    jd_ut1 = date_to_jd(2004,4,6,7,51,28.386009) - 0.4399619/86400

    D_tod_pef = r_ecef_to_eci(PEF(), TOD(), jd_ut1)
    r_tod = D_tod_pef * r_pef

    @test r_tod[1] ≈ +5094.51478040 atol = 1e-7
    @test r_tod[2] ≈ +6127.36646120 atol = 1e-7
    @test r_tod[3] ≈ +6380.34453270 atol = 1e-7

    q_tod_pef = r_ecef_to_eci(Quaternion, PEF(), TOD(), jd_ut1)
    r_tod = vect(q_tod_pef \ r_pef * q_tod_pef)

    @test r_tod[1] ≈ +5094.51478040 atol = 1e-7
    @test r_tod[2] ≈ +6127.36646120 atol = 1e-7
    @test r_tod[3] ≈ +6380.34453270 atol = 1e-7
end

# == PEF to MOD ============================================================================

############################################################################################
#                                       Test Results                                       #
############################################################################################
#
# == Scenario 01 ===========================================================================
#
# Example 3-15: Performing IAU-76/FK5 reduction.
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_pef  = -1033.47503130   i + 7901.30558560   j + 6380.34453270   k [km]
#
# one gets:
#
#   r_mod = 5094.02837450   i + 6127.87081640   j + 6380.24851640   k [km]
#
# If not EOP correction is used, then we get:
#
#   r_mod = 5094.02901670   i + 6127.87093630   j + 6380.24788850   k [km]
#
# Notice, however, that this result is obtained by using the correct UT1.
#
############################################################################################

@testset "Function r_ecef_to_eci PEF => MOD" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_pef  = [-1033.47503130; 7901.30558560; 6380.34453270]

    D_mod_pef = r_ecef_to_eci(PEF(), MOD(), jd_utc, eop_iau1980)
    r_mod = D_mod_pef * r_pef

    @test r_mod[1] ≈ +5094.02837450 atol = 3e-4
    @test r_mod[2] ≈ +6127.87081640 atol = 3e-4
    @test r_mod[3] ≈ +6380.24851640 atol = 3e-4

    q_mod_pef = r_ecef_to_eci(Quaternion, PEF(), MOD(), jd_utc, eop_iau1980)
    r_mod = vect(q_mod_pef \ r_pef * q_mod_pef)

    @test r_mod[1] ≈ +5094.02837450 atol = 3e-4
    @test r_mod[2] ≈ +6127.87081640 atol = 3e-4
    @test r_mod[3] ≈ +6380.24851640 atol = 3e-4

    # == No EOP corrections ================================================================

    # Notice that if we use jd_ut1, then the correction to TT will be wrong.
    # However, this will lead to a much smaller error than assuming that UTC =
    # UT1.

    jd_ut1 = date_to_jd(2004,4,6,7,51,28.386009) - 0.4399619/86400

    D_mod_pef = r_ecef_to_eci(PEF(), MOD(), jd_ut1)
    r_mod = D_mod_pef * r_pef

    @test r_mod[1] ≈ +5094.02901670 atol = 8e-6
    @test r_mod[2] ≈ +6127.87093630 atol = 8e-6
    @test r_mod[3] ≈ +6380.24788850 atol = 8e-6

    q_mod_pef = r_ecef_to_eci(Quaternion, PEF(), MOD(), jd_ut1)
    r_mod = vect(q_mod_pef \ r_pef * q_mod_pef)

    @test r_mod[1] ≈ +5094.02901670 atol = 8e-6
    @test r_mod[2] ≈ +6127.87093630 atol = 8e-6
    @test r_mod[3] ≈ +6380.24788850 atol = 8e-6
end

# == PEF to TEME ===========================================================================

############################################################################################
#                                       Test Results                                       #
############################################################################################
#
# == Scenario 01 ===========================================================================
#
# Example 3-15: Performing IAU-76/FK5 reduction.
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_pef  = -1033.47503130   i + 7901.30558560   j + 6380.34453270   k [km]
#
# one gets:
#
#   r_teme = 5094.18016210   i + 6127.64465950   j + 6380.34453270   k [km]
#
############################################################################################

@testset "Function r_ecef_to_eci PEF => TEME" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_pef  = [-1033.47503130; 7901.30558560; 6380.34453270]

    D_teme_pef = r_ecef_to_eci(PEF(), TEME(), jd_utc, eop_iau1980)
    r_teme = D_teme_pef * r_pef

    @test r_teme[1] ≈ +5094.18016210 atol = 3e-4
    @test r_teme[2] ≈ +6127.64465950 atol = 3e-4
    @test r_teme[3] ≈ +6380.34453270 atol = 3e-4

    q_teme_pef = r_ecef_to_eci(Quaternion, PEF(), TEME(), jd_utc, eop_iau1980)
    r_teme = vect(q_teme_pef \ r_pef * q_teme_pef)

    @test r_teme[1] ≈ +5094.18016210 atol = 3e-4
    @test r_teme[2] ≈ +6127.64465950 atol = 3e-4
    @test r_teme[3] ≈ +6380.34453270 atol = 3e-4

    # NOTE: We do not have the values without the EOP corrections. Hence, we will perform
    # the conversion from UTC to UT1 manually to test the functions.
    jd_ut1 = jd_utc_to_ut1(jd_utc, eop_iau2000a.Δut1_utc(jd_utc))

    D_teme_pef = r_ecef_to_eci(PEF(), TEME(), jd_ut1)
    r_teme = D_teme_pef * r_pef

    @test r_teme[1] ≈ +5094.18016210 atol = 3e-4
    @test r_teme[2] ≈ +6127.64465950 atol = 3e-4
    @test r_teme[3] ≈ +6380.34453270 atol = 3e-4

    q_teme_pef = r_ecef_to_eci(Quaternion, PEF(), TEME(), jd_ut1)
    r_teme = vect(q_teme_pef \ r_pef * q_teme_pef)

    @test r_teme[1] ≈ +5094.18016210 atol = 3e-4
    @test r_teme[2] ≈ +6127.64465950 atol = 3e-4
    @test r_teme[3] ≈ +6380.34453270 atol = 3e-4
end

############################################################################################
#                                IAU-2006 / 2010 CIO-based                                 #
############################################################################################

# == ITRF => CIRS ==========================================================================

############################################################################################
#                                       Test Results                                       #
############################################################################################
#
# == Scenario 01 ===========================================================================
#
# Example 3-14: Performing an IAU-2000 reduction [1, p. 220]
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_itrf = -1033.4793830    i + 7901.2952754    j + 6380.3565958    k [km]
#
# one gets:
#
#   r_cirs = -5100.01840470   i + 6122.78636480   j + 6380.34453270   k [km]
#
############################################################################################

@testset "Function r_ecef_to_eci ITRF => CIRS" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_itrf = [-1033.4793830; 7901.2952754; 6380.3565958]

    D_cirs_itrf = r_ecef_to_eci(ITRF(), CIRS(), jd_utc, eop_iau2000a)
    r_cirs = D_cirs_itrf * r_itrf

    @test r_cirs[1] ≈ +5100.01840470 atol = 3e-4
    @test r_cirs[2] ≈ +6122.78636480 atol = 3e-4
    @test r_cirs[3] ≈ +6380.34453270 atol = 3e-4

    q_cirs_itrf = r_ecef_to_eci(Quaternion, ITRF(), CIRS(), jd_utc, eop_iau2000a)
    r_cirs = vect(q_cirs_itrf \r_itrf * q_cirs_itrf)

    @test r_cirs[1] ≈ +5100.01840470 atol = 3e-4
    @test r_cirs[2] ≈ +6122.78636480 atol = 3e-4
    @test r_cirs[3] ≈ +6380.34453270 atol = 3e-4
end

# == ITRF => GCRF ==========================================================================

############################################################################################
#                                       Test Results                                       #
############################################################################################
#
# == Scenario 01 ===========================================================================
#
# Example 3-14: Performing an IAU-2000 reduction [1, p. 220]
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_itrf = -1033.4793830    i + 7901.2952754    j + 6380.3565958    k [km]
#
# one gets:
#
#   r_gcrf = 5102.50895290  i + 6123.01139910 j + 6378.13693380 k [km]
#
############################################################################################

@testset "Function r_ecef_to_eci ITRF => GCRF" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_itrf = [-1033.4793830; 7901.2952754; 6380.3565958]

    D_gcrf_itrf = r_ecef_to_eci(ITRF(), GCRF(), jd_utc, eop_iau2000a)
    r_gcrf = D_gcrf_itrf * r_itrf

    @test r_gcrf[1] ≈ +5102.50895290 atol = 3e-4
    @test r_gcrf[2] ≈ +6123.01139910 atol = 3e-4
    @test r_gcrf[3] ≈ +6378.13693380 atol = 3e-4

    q_gcrf_itrf = r_ecef_to_eci(Quaternion, ITRF(), GCRF(), jd_utc, eop_iau2000a)
    r_gcrf = vect(q_gcrf_itrf \ r_itrf * q_gcrf_itrf)

    @test r_gcrf[1] ≈ +5102.50895290 atol = 3e-4
    @test r_gcrf[2] ≈ +6123.01139910 atol = 3e-4
    @test r_gcrf[3] ≈ +6378.13693380 atol = 3e-4
end

# == TIRS => CIRS ==========================================================================

############################################################################################
#                                       Test Results                                       #
############################################################################################
#
# == Scenario 01 ===========================================================================
#
# Example 3-14: Performing an IAU-2000 reduction [1, p. 220]
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_tirs = -1033.47503120   i + 7901.30558560   j + 6380.34453270   k [km]
#
# one gets:
#
#   r_cirs = -5100.01840470   i + 6122.78636480   j + 6380.34453270   k [km]
#
############################################################################################

@testset "Function r_ecef_to_eci TIRS => CIRS" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_tirs = [-1033.47503120; 7901.30558560; 6380.34453270]

    D_cirs_tirs = r_ecef_to_eci(TIRS(), CIRS(), jd_utc, eop_iau2000a)
    r_cirs = D_cirs_tirs * r_tirs

    @test r_cirs[1] ≈ +5100.01840470 atol = 3e-4
    @test r_cirs[2] ≈ +6122.78636480 atol = 3e-4
    @test r_cirs[3] ≈ +6380.34453270 atol = 3e-4

    q_cirs_tirs = r_ecef_to_eci(Quaternion, TIRS(), CIRS(), jd_utc, eop_iau2000a)
    r_cirs = vect(q_cirs_tirs \ r_tirs * q_cirs_tirs)

    @test r_cirs[1] ≈ +5100.01840470 atol = 3e-4
    @test r_cirs[2] ≈ +6122.78636480 atol = 3e-4
    @test r_cirs[3] ≈ +6380.34453270 atol = 3e-4

    # NOTE: We do not have the values without the EOP corrections. Hence, we will perform
    # the conversion from UTC to UT1 manually to test the functions.
    jd_ut1 = jd_utc_to_ut1(jd_utc, eop_iau2000a.Δut1_utc(jd_utc))

    D_cirs_tirs = r_ecef_to_eci(TIRS(), CIRS(), jd_ut1)
    r_cirs = D_cirs_tirs * r_tirs

    @test r_cirs[1] ≈ +5100.01840470 atol = 3e-4
    @test r_cirs[2] ≈ +6122.78636480 atol = 3e-4
    @test r_cirs[3] ≈ +6380.34453270 atol = 3e-4

    q_cirs_tirs = r_ecef_to_eci(Quaternion, TIRS(), CIRS(), jd_ut1)
    r_cirs = vect(q_cirs_tirs \ r_tirs * q_cirs_tirs)

    @test r_cirs[1] ≈ +5100.01840470 atol = 3e-4
    @test r_cirs[2] ≈ +6122.78636480 atol = 3e-4
    @test r_cirs[3] ≈ +6380.34453270 atol = 3e-4
end

# == TIRS => GCRF ==========================================================================

############################################################################################
#                                       Test Results                                       #
############################################################################################
#
# == Scenario 01 ===========================================================================
#
# Example 3-14: Performing an IAU-2000 reduction [1, p. 220]
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_tirs = -1033.47503120   i + 7901.30558560   j + 6380.34453270   k [km]
#
# one gets:
#
#   r_gcrf = 5102.50895290  i + 6123.01139910 j + 6378.13693380 k [km]
#
############################################################################################

@testset "Function r_ecef_to_eci TIRS => GCRF" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_tirs = [-1033.47503120; 7901.30558560; 6380.34453270]

    D_gcrf_tirs = r_ecef_to_eci(TIRS(), GCRF(), jd_utc, eop_iau2000a)
    r_gcrf = D_gcrf_tirs * r_tirs

    @test r_gcrf[1] ≈ +5102.50895290 atol = 3e-4
    @test r_gcrf[2] ≈ +6123.01139910 atol = 3e-4
    @test r_gcrf[3] ≈ +6378.13693380 atol = 3e-4

    q_gcrf_tirs = r_ecef_to_eci(Quaternion, TIRS(), GCRF(), jd_utc, eop_iau2000a)
    r_gcrf = vect(q_gcrf_tirs \ r_tirs * q_gcrf_tirs)

    @test r_gcrf[1] ≈ +5102.50895290 atol = 3e-4
    @test r_gcrf[2] ≈ +6123.01139910 atol = 3e-4
    @test r_gcrf[3] ≈ +6378.13693380 atol = 3e-4
end

############################################################################################
#                              IAU-2006 / 2010 Equinox-based                               #
############################################################################################

# == ITRF => ERS ===========================================================================

############################################################################################
#                                       Test Results                                       #
############################################################################################
#
# == Scenario 01 ===========================================================================
#
# Example 3-14: Performing an IAU-2000 reduction [1, p. 220]
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_itrf = -1033.4793830    i + 7901.2952754    j + 6380.3565958    k [km]
#
# one gets:
#
#   r_ers  = +5094.51462800   i + 6127.36658790   j + 6380.34453270   k [km]
#
############################################################################################

@testset "Function r_ecef_to_eci ITRF => ERS" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_itrf = [-1033.4793830; 7901.2952754; 6380.3565958]

    D_ers_itrf = r_ecef_to_eci(ITRF(), ERS(), jd_utc, eop_iau2000a)
    r_ers = D_ers_itrf * r_itrf

    @test r_ers[1] ≈ +5094.51462800 atol = 5e-4
    @test r_ers[2] ≈ +6127.36658790 atol = 5e-4
    @test r_ers[3] ≈ +6380.34453270 atol = 5e-4

    q_ers_itrf = r_ecef_to_eci(Quaternion, ITRF(), ERS(), jd_utc, eop_iau2000a)
    r_ers = vect(q_ers_itrf \ r_itrf * q_ers_itrf)

    @test r_ers[1] ≈ +5094.51462800 atol = 5e-4
    @test r_ers[2] ≈ +6127.36658790 atol = 5e-4
    @test r_ers[3] ≈ +6380.34453270 atol = 5e-4
end

# == ITRF => MOD ===========================================================================

#############################################################################################
#                                       Test Results                                       #
############################################################################################
#
# == Scenario 01 ===========================================================================
#
# Example 3-14: Performing an IAU-2000 reduction [1, p. 220]
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_itrf = -1033.4793830    i + 7901.2952754    j + 6380.3565958    k [km]
#
# one gets:
#
#   r_mod  = +5094.02896110   i + 6127.87113500   j + 6380.24774200   k [km]
#
############################################################################################

@testset "Function r_ecef_to_eci ITRF => MOD" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_itrf = [-1033.4793830; 7901.2952754; 6380.3565958]

    D_mod_itrf = r_ecef_to_eci(ITRF(), MOD06(), jd_utc, eop_iau2000a)
    r_mod = D_mod_itrf * r_itrf

    @test r_mod[1] ≈ +5094.02896110 atol = 5e-4
    @test r_mod[2] ≈ +6127.87113500 atol = 5e-4
    @test r_mod[3] ≈ +6380.24774200 atol = 5e-4

    q_mod_itrf = r_ecef_to_eci(Quaternion, ITRF(), MOD06(), jd_utc, eop_iau2000a)
    r_mod = vect(q_mod_itrf \ r_itrf * q_mod_itrf)

    @test r_mod[1] ≈ +5094.02896110 atol = 5e-4
    @test r_mod[2] ≈ +6127.87113500 atol = 5e-4
    @test r_mod[3] ≈ +6380.24774200 atol = 5e-4
end

# == ITRF => MJ2000 ========================================================================

############################################################################################
#                                       Test Results                                       #
############################################################################################
#
# == Scenario 01 ===========================================================================
#
# Example 3-14: Performing an IAU-2000 reduction [1, p. 220]
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_itrf = -1033.4793830    i + 7901.2952754    j + 6380.3565958    k [km]
#
# one gets:
#
#   r_j2000 = 5102.50960000  i + 6123.01152000   j + 6378.13630000   k [km]
#
# Notice that the transformation we are testing here does not convert to the original J2000.
# However, this result is close enough for a test comparison.
#
############################################################################################

@testset "Function r_ecef_to_eci ITRF => MJ2000" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_itrf = [-1033.4793830; 7901.2952754; 6380.3565958]

    D_mj2000_itrf = r_ecef_to_eci(ITRF(), MJ2000(), jd_utc, eop_iau2000a)
    r_mj2000 = D_mj2000_itrf * r_itrf

    @test r_mj2000[1] ≈ +5102.50960000 atol = 5e-4
    @test r_mj2000[2] ≈ +6123.01152000 atol = 5e-4
    @test r_mj2000[3] ≈ +6378.13630000 atol = 5e-4

    q_mj2000_itrf = r_ecef_to_eci(Quaternion, ITRF(), MJ2000(), jd_utc, eop_iau2000a)
    r_mj2000 = vect(q_mj2000_itrf \ r_itrf * q_mj2000_itrf)

    @test r_mj2000[1] ≈ +5102.50960000 atol = 5e-4
    @test r_mj2000[2] ≈ +6123.01152000 atol = 5e-4
    @test r_mj2000[3] ≈ +6378.13630000 atol = 5e-4
end

# == TIRS => ERS ===========================================================================

############################################################################################
#                                       Test Results                                       #
############################################################################################
#
# == Scenario 01 ===========================================================================
#
# Example 3-14: Performing an IAU-2000 reduction [1, p. 220]
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_tirs = -1033.47503120   i + 7901.30558560   j + 6380.34453270   k [km]
#
# one gets:
#
#   r_ers  = +5094.51462800   i + 6127.36658790   j + 6380.34453270   k [km]
#
############################################################################################

@testset "Function r_ecef_to_eci TIRS => ERS" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_tirs = [-1033.47503120; 7901.30558560; 6380.34453270]

    D_ers_tirs = r_ecef_to_eci(TIRS(), ERS(), jd_utc, eop_iau2000a)
    r_ers = D_ers_tirs * r_tirs

    @test r_ers[1] ≈ +5094.51462800 atol = 5e-4
    @test r_ers[2] ≈ +6127.36658790 atol = 5e-4
    @test r_ers[3] ≈ +6380.34453270 atol = 5e-4

    q_ers_tirs = r_ecef_to_eci(Quaternion, TIRS(), ERS(), jd_utc, eop_iau2000a)
    r_ers = vect(q_ers_tirs \ r_tirs * q_ers_tirs)

    @test r_ers[1] ≈ +5094.51462800 atol = 5e-4
    @test r_ers[2] ≈ +6127.36658790 atol = 5e-4
    @test r_ers[3] ≈ +6380.34453270 atol = 5e-4

    # NOTE: We do not have the values without the EOP corrections. Hence, we will perform
    # the conversion from UTC to UT1 manually to test the functions.
    jd_ut1 = jd_utc_to_ut1(jd_utc, eop_iau2000a.Δut1_utc(jd_utc))

    D_ers_tirs = r_ecef_to_eci(TIRS(), ERS(), jd_ut1)
    r_ers = D_ers_tirs * r_tirs

    @test r_ers[1] ≈ +5094.51462800 atol = 5e-4
    @test r_ers[2] ≈ +6127.36658790 atol = 5e-4
    @test r_ers[3] ≈ +6380.34453270 atol = 5e-4

    q_ers_tirs = r_ecef_to_eci(Quaternion, TIRS(), ERS(), jd_ut1)
    r_ers = vect(q_ers_tirs \ r_tirs * q_ers_tirs)

    @test r_ers[1] ≈ +5094.51462800 atol = 5e-4
    @test r_ers[2] ≈ +6127.36658790 atol = 5e-4
    @test r_ers[3] ≈ +6380.34453270 atol = 5e-4
end

# == TIRS => ERS ===========================================================================

############################################################################################
#                                       Test Results                                       #
############################################################################################
#
# == Scenario 01 ===========================================================================
#
# Example 3-14: Performing an IAU-2000 reduction [1, p. 220]
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_tirs = -1033.47503120   i + 7901.30558560   j + 6380.34453270   k [km]
#
# one gets:
#
#   r_ers  = +5094.51462800   i + 6127.36658790   j + 6380.34453270   k [km]
#
############################################################################################

@testset "Function r_ecef_to_eci TIRS => ERS" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_tirs = [-1033.47503120; 7901.30558560; 6380.34453270]

    D_ers_tirs = r_ecef_to_eci(TIRS(), ERS(), jd_utc, eop_iau2000a)
    r_ers = D_ers_tirs * r_tirs

    @test r_ers[1] ≈ +5094.51462800 atol = 5e-4
    @test r_ers[2] ≈ +6127.36658790 atol = 5e-4
    @test r_ers[3] ≈ +6380.34453270 atol = 5e-4

    q_ers_tirs = r_ecef_to_eci(Quaternion, TIRS(), ERS(), jd_utc, eop_iau2000a)
    r_ers = vect(q_ers_tirs \ r_tirs * q_ers_tirs)

    @test r_ers[1] ≈ +5094.51462800 atol = 5e-4
    @test r_ers[2] ≈ +6127.36658790 atol = 5e-4
    @test r_ers[3] ≈ +6380.34453270 atol = 5e-4

    # NOTE: We do not have the values without the EOP corrections. Hence, we will perform
    # the conversion from UTC to UT1 manually to test the functions.
    jd_ut1 = jd_utc_to_ut1(jd_utc, eop_iau2000a.Δut1_utc(jd_utc))

    D_ers_tirs = r_ecef_to_eci(TIRS(), ERS(), jd_ut1)
    r_ers = D_ers_tirs * r_tirs

    @test r_ers[1] ≈ +5094.51462800 atol = 5e-4
    @test r_ers[2] ≈ +6127.36658790 atol = 5e-4
    @test r_ers[3] ≈ +6380.34453270 atol = 5e-4

    q_ers_tirs = r_ecef_to_eci(Quaternion, TIRS(), ERS(), jd_ut1)
    r_ers = vect(q_ers_tirs \ r_tirs * q_ers_tirs)

    @test r_ers[1] ≈ +5094.51462800 atol = 5e-4
    @test r_ers[2] ≈ +6127.36658790 atol = 5e-4
    @test r_ers[3] ≈ +6380.34453270 atol = 5e-4
end

# == TIRS => MOD ===========================================================================

############################################################################################
#                                       Test Results                                       #
############################################################################################
#
# == Scenario 01 ===========================================================================
#
# Example 3-14: Performing an IAU-2000 reduction [1, p. 220]
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_tirs = -1033.47503120   i + 7901.30558560   j + 6380.34453270   k [km]
#
# one gets:
#
#   r_mod  = +5094.02896110   i + 6127.87113500   j + 6380.24774200   k [km]
#
############################################################################################

@testset "Function r_ecef_to_eci TIRS => MOD" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_tirs = [-1033.47503120; 7901.30558560; 6380.34453270]

    D_mod_tirs = r_ecef_to_eci(TIRS(), MOD06(), jd_utc, eop_iau2000a)
    r_mod = D_mod_tirs * r_tirs

    @test r_mod[1] ≈ +5094.02896110 atol = 5e-4
    @test r_mod[2] ≈ +6127.87113500 atol = 5e-4
    @test r_mod[3] ≈ +6380.24774200 atol = 5e-4

    q_mod_tirs = r_ecef_to_eci(Quaternion, TIRS(), MOD06(), jd_utc, eop_iau2000a)
    r_mod = vect(q_mod_tirs \ r_tirs * q_mod_tirs)

    @test r_mod[1] ≈ +5094.02896110 atol = 5e-4
    @test r_mod[2] ≈ +6127.87113500 atol = 5e-4
    @test r_mod[3] ≈ +6380.24774200 atol = 5e-4

    # NOTE: We do not have the values without the EOP corrections. Hence, we will perform
    # the conversion from UTC to UT1 manually to test the functions.
    jd_ut1 = jd_utc_to_ut1(jd_utc, eop_iau2000a.Δut1_utc(jd_utc))

    D_mod_tirs = r_ecef_to_eci(TIRS(), MOD06(), jd_ut1)
    r_mod = D_mod_tirs * r_tirs

    @test r_mod[1] ≈ +5094.02896110 atol = 5e-4
    @test r_mod[2] ≈ +6127.87113500 atol = 5e-4
    @test r_mod[3] ≈ +6380.24774200 atol = 5e-4

    q_mod_tirs = r_ecef_to_eci(Quaternion, TIRS(), MOD06(), jd_ut1)
    r_mod = vect(q_mod_tirs \ r_tirs * q_mod_tirs)

    @test r_mod[1] ≈ +5094.02896110 atol = 5e-4
    @test r_mod[2] ≈ +6127.87113500 atol = 5e-4
    @test r_mod[3] ≈ +6380.24774200 atol = 5e-4
end

# == TIRS => MJ2000 ========================================================================

############################################################################################
#                                       Test Results                                       #
############################################################################################
#
# == Scenario 01 ===========================================================================
#
# Example 3-14: Performing an IAU-2000 reduction [1, p. 220]
#
# According to this example and Table 3-6, using:
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_tirs = -1033.47503120   i + 7901.30558560   j + 6380.34453270   k [km]
#
# one gets:
#
#   r_j2000 = 5102.50960000  i + 6123.01152000   j + 6378.13630000   k [km]
#
# Notice that the transformation we are testing here does not convert to the original J2000.
# However, this result is close enough for a test comparison.
#
############################################################################################

@testset "Function r_ecef_to_eci TIRS => MJ2000" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    r_tirs = [-1033.47503120; 7901.30558560; 6380.34453270]

    D_mj2000_tirs = r_ecef_to_eci(TIRS(), MJ2000(), jd_utc, eop_iau2000a)
    r_mj2000 = D_mj2000_tirs * r_tirs

    @test r_mj2000[1] ≈ +5102.50960000 atol = 5e-4
    @test r_mj2000[2] ≈ +6123.01152000 atol = 5e-4
    @test r_mj2000[3] ≈ +6378.13630000 atol = 5e-4

    q_mj2000_tirs = r_ecef_to_eci(Quaternion, TIRS(), MJ2000(), jd_utc, eop_iau2000a)
    r_mj2000 = vect(q_mj2000_tirs \ r_tirs * q_mj2000_tirs)

    @test r_mj2000[1] ≈ +5102.50960000 atol = 5e-4
    @test r_mj2000[2] ≈ +6123.01152000 atol = 5e-4
    @test r_mj2000[3] ≈ +6378.13630000 atol = 5e-4

    # NOTE: We do not have the values without the EOP corrections. Hence, we will perform
    # the conversion from UTC to UT1 manually to test the functions.
    jd_ut1 = jd_utc_to_ut1(jd_utc, eop_iau2000a.Δut1_utc(jd_utc))

    D_mj2000_tirs = r_ecef_to_eci(TIRS(), MJ2000(), jd_ut1)
    r_mj2000 = D_mj2000_tirs * r_tirs

    @test r_mj2000[1] ≈ +5102.50960000 atol = 5e-4
    @test r_mj2000[2] ≈ +6123.01152000 atol = 5e-4
    @test r_mj2000[3] ≈ +6378.13630000 atol = 5e-4

    q_mj2000_tirs = r_ecef_to_eci(Quaternion, TIRS(), MJ2000(), jd_ut1)
    r_mj2000 = vect(q_mj2000_tirs \ r_tirs * q_mj2000_tirs)

    @test r_mj2000[1] ≈ +5102.50960000 atol = 5e-4
    @test r_mj2000[2] ≈ +6123.01152000 atol = 5e-4
    @test r_mj2000[3] ≈ +6378.13630000 atol = 5e-4
end
