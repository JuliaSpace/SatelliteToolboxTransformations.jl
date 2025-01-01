## Description #############################################################################
#
# Tests related to ECI to ECI transformations using satellite state vector.
#
## References ##############################################################################
#
# [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm Press,
#     Hawthorn, CA, USA.
#
############################################################################################

# Get the current EOP Data.
#
# TODO: The EOP data obtained from IERS website does not match the values in the examples in
# [1]. However, this should be enough, because 1) the individual functions at the low level
# are tested using the same values of [1], and 2) the difference is smaller than 30 cm.

eop_iau1980  = read_iers_eop("../eop_IAU1980.txt",  Val(:IAU1980))
eop_iau2000a = read_iers_eop("../eop_IAU2000A.txt", Val(:IAU2000A))

# == File: ./src/transformations/sv_eci_to_eci.jl ==========================================

############################################################################################
#                                       IAU-76 / FK5                                       #
############################################################################################

# -- Functions: sv_eci_to_eci --------------------------------------------------------------

# The rotations functions were already heavily tested on `eci_to_eci.jl` file. Hence, here
# we will do only some minor testing involving the following transformations:
#
#   GCRF <=> J2000 (FK5)
#   MOD  <=> TOD   (FK5)
#   GCRF <=> CIRS  (IAU2006)

# == GCRF <=> J2000 ========================================================================

#############################################################################################
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
#   r_gcrf = 5102.50895790   i + 6123.01140070   j + 6378.13692820   k [km]
#   v_gcrf =   -4.7432201570 i +    0.7905364970 j +    5.5337557270 k [km/s]
#
# one gets:
#
#   r_j2000 = 5102.50960000   i + 6123.01152000   j + 6378.13630000   k [km]
#   v_j2000 =   -4.7432196000 i +    0.7905366000 j +    5.5337561900 k [km/s]
#
############################################################################################

@testset "Function sv_eci_to_eci GCRF <=> J2000" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)

    # == GCRF => J2000 =====================================================================

    r_gcrf   = [5102.50895790; 6123.01140070; 6378.13692820]
    v_gcrf   = [-4.7432201570; 0.7905364970; 5.5337557270]
    sv_gcrf  = OrbitStateVector(jd_utc, r_gcrf, v_gcrf)
    sv_j2000 = sv_eci_to_eci(sv_gcrf, GCRF(), J2000(), eop_iau1980)

    @test sv_j2000.t === jd_utc

    @test sv_j2000.r[1] ≈ +5102.50960000 atol = 1e-4
    @test sv_j2000.r[2] ≈ +6123.01152000 atol = 1e-4
    @test sv_j2000.r[3] ≈ +6378.13630000 atol = 1e-4

    @test sv_j2000.v[1] ≈ -4.7432196000  atol = 1e-7
    @test sv_j2000.v[2] ≈ +0.7905366000  atol = 1e-7
    @test sv_j2000.v[3] ≈ +5.5337561900  atol = 1e-7

    # == J2000 => GCRF =====================================================================

    r_j2000  = [5102.50960000; 6123.01152000; 6378.13630000]
    v_j2000  = [-4.7432196000; 0.7905366000; 5.5337561900]
    sv_j2000 = OrbitStateVector(jd_utc, r_j2000, v_j2000)
    sv_gcrf  = sv_eci_to_eci(sv_j2000, J2000(), GCRF(), eop_iau1980)

    @test sv_gcrf.t === jd_utc

    @test sv_gcrf.r[1] ≈ +5102.50895790 atol = 1e-4
    @test sv_gcrf.r[2] ≈ +6123.01140070 atol = 1e-4
    @test sv_gcrf.r[3] ≈ +6378.13692820 atol = 1e-4

    @test sv_gcrf.v[1] ≈ -4.7432201570  atol = 1e-7
    @test sv_gcrf.v[2] ≈ +0.7905364970  atol = 1e-7
    @test sv_gcrf.v[3] ≈ +5.5337557270  atol = 1e-7

end

# == MOD <=> TOD ===========================================================================

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
#   r_mod = 5094.02837450   i + 6127.87081640   j + 6380.24851640   k [km]
#   v_mod =   -4.7462630520 i +    0.7860140450 j +    5.5317905620 k [km/s]
#
# one gets:
#
#   r_tod = 5094.51620300   i + 6127.36527840   j + 6380.34453270   k [km]
#   v_tod =   -4.7460883850 i +    0.7860783240 j +    5.5319312880 k [km/s]
#
############################################################################################

@testset "Function sv_eci_to_eci MOD <=> TOD" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)

    # == MOD => TOD ========================================================================

    r_mod  = [5094.02837450; 6127.87081640; 6380.24851640]
    v_mod  = [-4.7462630520; 0.7860140450; 5.5317905620]
    sv_mod = OrbitStateVector(jd_utc, r_mod, v_mod)
    sv_tod = sv_eci_to_eci(sv_mod, MOD(), TOD(), eop_iau1980)

    @test sv_tod.t === jd_utc

    @test sv_tod.r[1] ≈ +5094.51620300 atol = 1e-4
    @test sv_tod.r[2] ≈ +6127.36527840 atol = 1e-4
    @test sv_tod.r[3] ≈ +6380.34453270 atol = 1e-4

    @test sv_tod.v[1] ≈ -4.7460883850  atol = 1e-7
    @test sv_tod.v[2] ≈ +0.7860783240  atol = 1e-7
    @test sv_tod.v[3] ≈ +5.5319312880  atol = 1e-7

    # == TOD => MOD ========================================================================

    r_tod  = [5094.51620300; 6127.36527840; 6380.34453270]
    v_tod  = [-4.7460883850; 0.7860783240; 5.5319312880]
    sv_tod = OrbitStateVector(jd_utc, r_tod, v_tod)
    sv_mod = sv_eci_to_eci(sv_tod, TOD(), MOD(), eop_iau1980)

    @test sv_mod.t === jd_utc

    @test sv_mod.r[1] ≈ +5094.02837450 atol = 1e-4
    @test sv_mod.r[2] ≈ +6127.87081640 atol = 1e-4
    @test sv_mod.r[3] ≈ +6380.24851640 atol = 1e-4

    @test sv_mod.v[1] ≈ -4.7462630520  atol = 1e-7
    @test sv_mod.v[2] ≈ +0.7860140450  atol = 1e-7
    @test sv_mod.v[3] ≈ +5.5317905620  atol = 1e-7
end

############################################################################################
#                                     IAU-2006 / 2010                                      #
############################################################################################

# == GCRF <=> CIRS =========================================================================

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
# NOTE: It seems that the results in the Example 3-14 is computed **without**
# the `dX` and `dY` corrections, whereas in the Table 3-6 they are computed
# **with** the corrections.
#
#   UTC    = April 6, 2004, 07:51:28.386009
#   r_cirs = -5100.01840470   i + 6122.78636480   j + 6380.34453270   k [km]
#   v_cirs =    -4.7453803300 i -    0.7903414530 j +    5.5319312880 k [km/s]
#
# one gets the following (this is the result in Table 3-6):
#
#   r_gcrf = 5102.50895290  i + 6123.01139910 j + 6378.13693380 k [km]
#   v_gcrf =  -4.7432201610 i + 0.7905364950  j + 5.5337557240  k [km/s]
#
############################################################################################

@testset "Function sv_eci_to_eci GCRF <=> CIRS" begin
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)

    # == GCRF => CIRS ======================================================================

    r_gcrf  = [5102.50895290; 6123.01139910; 6378.13693380]
    v_gcrf  = [-4.7432201610; 0.7905364950; 5.5337557240]
    sv_gcrf = OrbitStateVector(jd_utc, r_gcrf, v_gcrf)
    sv_cirs = sv_eci_to_eci(sv_gcrf, GCRF(), CIRS(), eop_iau2000a)

    @test sv_cirs.t === jd_utc

    @test sv_cirs.r[1] ≈ +5100.01840470 atol = 1e-4
    @test sv_cirs.r[2] ≈ +6122.78636480 atol = 1e-4
    @test sv_cirs.r[3] ≈ +6380.34453270 atol = 1e-4

    @test sv_cirs.v[1] ≈ -4.7453803300  atol = 1e-7
    @test sv_cirs.v[2] ≈ +0.7903414530  atol = 1e-7
    @test sv_cirs.v[3] ≈ +5.5319312880  atol = 1e-7

    # == CIRS => GCRF ======================================================================

    r_cirs  = [+5100.01840470; +6122.78636480; +6380.34453270]
    v_cirs  = [-4.7453803300; +0.7903414530; +5.5319312880]
    sv_cirs = OrbitStateVector(jd_utc, r_cirs, v_cirs)
    sv_gcrf = sv_eci_to_eci(sv_cirs, CIRS(), GCRF(), eop_iau2000a)

    @test sv_gcrf.t === jd_utc

    @test sv_gcrf.r[1] ≈ +5102.50895290 atol = 1e-4
    @test sv_gcrf.r[2] ≈ +6123.01139910 atol = 1e-4
    @test sv_gcrf.r[3] ≈ +6378.13693380 atol = 1e-4

    @test sv_gcrf.v[1] ≈ -4.7432201610  atol = 1e-7
    @test sv_gcrf.v[2] ≈ +0.7905364950  atol = 1e-7
    @test sv_gcrf.v[3] ≈ +5.5337557240  atol = 1e-7
end

############################################################################################
#                                     Additional Tests                                     #
############################################################################################

# Those tests compare the results using `sv_eci_to_eci` with the results obtained using
# `r_eci_to_eci`. Notice that the latter has already been extensively tested.

@testset "Comparing `sv_eci_to_eci` with `r_eci_to_eci`" begin
    eop_iau1980  = read_iers_eop("../eop_IAU1980.txt",  Val(:IAU1980))
    eop_iau2000a = read_iers_eop("../eop_IAU2000A.txt", Val(:IAU2000A))

    jd_utc = date_to_jd(2024, 4, 19)
    r_i    = [7000.0, 7500.0, 7600.0] * 1000
    v_i    = [   5.0,    6.0,    7.0] * 1000
    sv_i   = OrbitStateVector(jd_utc, r_i, v_i)

    for (T_ECIo, T_ECIf, eop) in (
        (GCRF(),   J2000(),  eop_iau1980),
        (J2000(),  GCRF(),   eop_iau1980),
        (GCRF(),   MOD(),    eop_iau1980),
        (GCRF(),   TOD(),    eop_iau1980),
        (GCRF(),   TEME(),   eop_iau1980),
        (MOD(),    GCRF(),   eop_iau1980),
        (TOD(),    GCRF(),   eop_iau1980),
        (TEME(),   GCRF(),   eop_iau1980),
        (J2000(),  MOD(),    eop_iau1980),
        (J2000(),  TOD(),    eop_iau1980),
        (J2000(),  TEME(),   eop_iau1980),
        (MOD(),    J2000(),  eop_iau1980),
        (TOD(),    J2000(),  eop_iau1980),
        (TEME(),   J2000(),  eop_iau1980),
        (J2000(),  MOD(),    nothing),
        (J2000(),  TOD(),    nothing),
        (J2000(),  TEME(),   nothing),
        (MOD(),    J2000(),  nothing),
        (TOD(),    J2000(),  nothing),
        (TEME(),   J2000(),  nothing),
        (GCRF(),   CIRS(),   eop_iau2000a),
        (CIRS(),   GCRF(),   eop_iau2000a),
        (GCRF(),   CIRS(),   nothing),
        (CIRS(),   GCRF(),   nothing),
        (GCRF(),   MJ2000(), eop_iau2000a),
        (MJ2000(), GCRF(),   eop_iau2000a),
        (GCRF(),   MJ2000(), nothing),
        (MJ2000(), GCRF(),   nothing),
        (GCRF(),   MOD06(),  eop_iau2000a),
        (GCRF(),   ERS(),    eop_iau2000a),
        (ERS(),    GCRF(),   eop_iau2000a),
        (MOD06(),  GCRF(),   eop_iau2000a),
        (MJ2000(), MOD06(),  eop_iau2000a),
        (MJ2000(), ERS(),    eop_iau2000a),
        (ERS(),    MJ2000(), eop_iau2000a),
        (MOD06(),  MJ2000(), eop_iau2000a),
        (GCRF(),   MOD06(),  nothing),
        (GCRF(),   ERS(),    nothing),
        (ERS(),    GCRF(),   nothing),
        (MOD06(),  GCRF(),   nothing),
        (MJ2000(), MOD06(),  nothing),
        (MJ2000(), ERS(),    nothing),
        (ERS(),    MJ2000(), nothing),
        (MOD06(),  MJ2000(), nothing),
    )
        D = if !isnothing(eop)
            r_eci_to_eci(T_ECIo, T_ECIf, jd_utc, eop)
        else
            r_eci_to_eci(T_ECIo, T_ECIf, jd_utc)
        end

        r_if  = D * r_i
        v_if  = D * v_i
        sv_if = if !isnothing(eop)
            sv_eci_to_eci(sv_i, T_ECIo, T_ECIf, eop)
        else
            sv_eci_to_eci(sv_i, T_ECIo, T_ECIf)
        end

        @test sv_if.t === jd_utc
        @test sv_if.r ≈   r_if
        @test sv_if.v ≈   v_if
    end

    for (T_ECIo, T_ECIf, eop) in (
        (MOD(),    TOD(),    eop_iau1980),
        (MOD(),    TEME(),   eop_iau1980),
        (TOD(),    MOD(),    eop_iau1980),
        (TOD(),    TEME(),   eop_iau1980),
        (TEME(),   MOD(),    eop_iau1980),
        (TEME(),   TOD(),    eop_iau1980),
        (MOD(),    TOD(),    nothing),
        (MOD(),    TEME(),   nothing),
        (TOD(),    MOD(),    nothing),
        (TOD(),    TEME(),   nothing),
        (TEME(),   MOD(),    nothing),
        (TEME(),   TOD(),    nothing),
        (CIRS(),   CIRS(),   eop_iau2000a),
        (CIRS(),   CIRS(),   nothing),
        (ERS(),    MOD06(),  eop_iau2000a),
        (MOD06(),  ERS(),    eop_iau2000a),
        (ERS(),    MOD06(),  nothing),
        (MOD06(),  ERS(),    nothing),
    )
        D = if !isnothing(eop)
            r_eci_to_eci(T_ECIo, jd_utc, T_ECIf, jd_utc, eop)
        else
            r_eci_to_eci(T_ECIo, jd_utc, T_ECIf, jd_utc)
        end

        r_if  = D * r_i
        v_if  = D * v_i
        sv_if = if !isnothing(eop)
            sv_eci_to_eci(sv_i, T_ECIo, T_ECIf, eop)
        else
            sv_eci_to_eci(sv_i, T_ECIo, T_ECIf)
        end

        @test sv_if.t === jd_utc
        @test sv_if.r ≈   r_if
        @test sv_if.v ≈   v_if
    end
end
