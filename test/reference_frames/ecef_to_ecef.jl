## Description #############################################################################
#
# Tests related to ECEF to ECEF transformations.
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

# == File: ./src/reference_frames/ecef_to_ecef.jl ==========================================

# -- Functions: r_ecef_to_ecef -------------------------------------------------------------

# == ITRF <=> PEF ==========================================================================

############################################################################################
#                                       IAU-76 / FK5                                       #
############################################################################################

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
#   v_itrf =    -3.225636520  i -    2.872451450  j +    5.531924446  k [km/s]
#
# one gets:
#
#   r_pef  = -1033.47503130   i + 7901.30558560   j + 6380.34453270   k [km]
#   v_pef  =    -3.2256327470 i -    2.8724425110 j +    5.5319312880 k [km/s]
#
############################################################################################

@testset "Function r_ecef_to_ecef ITRF <=> PEF" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)

    # == ITRF => PEF =======================================================================

    r_itrf = [-1033.4793830; 7901.2952754; 6380.3565958]
    v_itrf = [-3.225636520; -2.872451450; +5.531924446]

    # -- DCM -------------------------------------------------------------------------------

    D_pef_itrf = r_ecef_to_ecef(ITRF(), PEF(), jd_utc, eop_iau1980)

    r_pef = D_pef_itrf * r_itrf
    v_pef = D_pef_itrf * v_itrf

    @test r_pef[1] ≈ -1033.47503130 atol = 1e-4
    @test r_pef[2] ≈ +7901.30558560 atol = 1e-4
    @test r_pef[3] ≈ +6380.34453270 atol = 1e-4

    @test v_pef[1] ≈ -3.2256327470  atol = 1e-7
    @test v_pef[2] ≈ -2.8724425110  atol = 1e-7
    @test v_pef[3] ≈ +5.5319312880  atol = 1e-7

    # -- Quaternion ------------------------------------------------------------------------

    q_pef_itrf = r_ecef_to_ecef(Quaternion, ITRF(), PEF(), jd_utc, eop_iau1980)

    r_pef = vect(conj(q_pef_itrf) * r_itrf * q_pef_itrf)
    v_pef = vect(conj(q_pef_itrf) * v_itrf * q_pef_itrf)

    @test r_pef[1] ≈ -1033.47503130 atol = 1e-4
    @test r_pef[2] ≈ +7901.30558560 atol = 1e-4
    @test r_pef[3] ≈ +6380.34453270 atol = 1e-4

    @test v_pef[1] ≈ -3.2256327470  atol = 1e-7
    @test v_pef[2] ≈ -2.8724425110  atol = 1e-7
    @test v_pef[3] ≈ +5.5319312880  atol = 1e-7

    # == PEF => ITRF =======================================================================

    r_pef  = [-1033.47503130; 7901.30558560; 6380.34453270]
    v_pef  = [-3.2256327470; -2.8724425110; +5.5319312880]

    # -- DCM -------------------------------------------------------------------------------

    D_itrf_pef = r_ecef_to_ecef(PEF(), ITRF(), jd_utc, eop_iau1980)

    r_itrf = D_itrf_pef * r_pef
    v_itrf = D_itrf_pef * v_pef

    @test r_itrf[1] ≈ -1033.4793830 atol = 1e-4
    @test r_itrf[2] ≈ +7901.2952754 atol = 1e-4
    @test r_itrf[3] ≈ +6380.3565958 atol = 1e-4

    @test v_itrf[1] ≈ -3.225636520  atol = 1e-7
    @test v_itrf[2] ≈ -2.872451450  atol = 1e-7
    @test v_itrf[3] ≈ +5.531924446  atol = 1e-7

    # -- Quaternion ------------------------------------------------------------------------

    q_itrf_pef = r_ecef_to_ecef(Quaternion, PEF(), ITRF(), jd_utc, eop_iau1980)

    r_itrf = vect(conj(q_itrf_pef) * r_pef * q_itrf_pef)
    v_itrf = vect(conj(q_itrf_pef) * v_pef * q_itrf_pef)

    @test r_itrf[1] ≈ -1033.4793830 atol = 1e-4
    @test r_itrf[2] ≈ +7901.2952754 atol = 1e-4
    @test r_itrf[3] ≈ +6380.3565958 atol = 1e-4

    @test v_itrf[1] ≈ -3.225636520  atol = 1e-7
    @test v_itrf[2] ≈ -2.872451450  atol = 1e-7
    @test v_itrf[3] ≈ +5.531924446  atol = 1e-7
end

############################################################################################
#                                     IAU-2006 / 2010                                      #
############################################################################################

# == ITRF <=> TIRS =========================================================================

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
#   v_itrf =    -3.225636520  i -    2.872451450  j +    5.531924446  k [km/s]
#
# one gets the following:
#
#   r_tirs  = -1033.47503120   i + 7901.30558560   j + 6380.34453270   k [km]
#   v_tirs  =    -3.2256327470 i -    2.8724425110 j +    5.5319312880 k [km/s]
#
############################################################################################

@testset "Function r_ecef_to_ecef ITRF <=> TIRS" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)

    # == ITRF => TIRS ======================================================================

    r_itrf = [-1033.4793830; 7901.2952754; 6380.3565958]
    v_itrf = [-3.225636520; -2.872451450; +5.531924446]

    # -- DCM -------------------------------------------------------------------------------

    D_tirs_itrf = r_ecef_to_ecef(ITRF(), TIRS(), jd_utc, eop_iau2000a)

    r_tirs = D_tirs_itrf * r_itrf
    v_tirs = D_tirs_itrf * v_itrf

    @test r_tirs[1] ≈ -1033.47503120 atol = 1e-4
    @test r_tirs[2] ≈ +7901.30558560 atol = 1e-4
    @test r_tirs[3] ≈ +6380.34453270 atol = 1e-4

    @test v_tirs[1] ≈ -3.2256327470  atol = 1e-7
    @test v_tirs[2] ≈ -2.8724425110  atol = 1e-7
    @test v_tirs[3] ≈ +5.5319312880  atol = 1e-7

    # -- Quaternion ------------------------------------------------------------------------

    q_tirs_itrf = r_ecef_to_ecef(Quaternion, ITRF(), TIRS(), jd_utc, eop_iau2000a)

    r_tirs = vect(conj(q_tirs_itrf) * r_itrf * q_tirs_itrf)
    v_tirs = vect(conj(q_tirs_itrf) * v_itrf * q_tirs_itrf)

    @test r_tirs[1] ≈ -1033.47503120 atol = 1e-4
    @test r_tirs[2] ≈ +7901.30558560 atol = 1e-4
    @test r_tirs[3] ≈ +6380.34453270 atol = 1e-4

    @test v_tirs[1] ≈ -3.2256327470  atol = 1e-7
    @test v_tirs[2] ≈ -2.8724425110  atol = 1e-7
    @test v_tirs[3] ≈ +5.5319312880  atol = 1e-7

    # == TIRS => ITRF ======================================================================

    r_tirs  = [-1033.47503120; 7901.30558560; 6380.34453270]
    v_tirs  = [-3.2256327470; -2.8724425110; +5.5319312880]

    # -- DCM -------------------------------------------------------------------------------

    D_itrf_tirs = r_ecef_to_ecef(TIRS(), ITRF(), jd_utc, eop_iau2000a)

    r_itrf = D_itrf_tirs * r_tirs
    v_itrf = D_itrf_tirs * v_tirs

    @test r_itrf[1] ≈ -1033.4793830 atol = 1e-4
    @test r_itrf[2] ≈ +7901.2952754 atol = 1e-4
    @test r_itrf[3] ≈ +6380.3565958 atol = 1e-4

    @test v_itrf[1] ≈ -3.225636520  atol = 1e-7
    @test v_itrf[2] ≈ -2.872451450  atol = 1e-7
    @test v_itrf[3] ≈ +5.531924446  atol = 1e-7

    # -- Quaternion ------------------------------------------------------------------------

    q_itrf_tirs = r_ecef_to_ecef(Quaternion, TIRS(), ITRF(), jd_utc, eop_iau2000a)

    r_itrf = vect(conj(q_itrf_tirs) * r_tirs * q_itrf_tirs)
    v_itrf = vect(conj(q_itrf_tirs) * v_tirs * q_itrf_tirs)

    @test r_itrf[1] ≈ -1033.4793830 atol = 1e-4
    @test r_itrf[2] ≈ +7901.2952754 atol = 1e-4
    @test r_itrf[3] ≈ +6380.3565958 atol = 1e-4

    @test v_itrf[1] ≈ -3.225636520  atol = 1e-7
    @test v_itrf[2] ≈ -2.872451450  atol = 1e-7
    @test v_itrf[3] ≈ +5.531924446  atol = 1e-7
end
