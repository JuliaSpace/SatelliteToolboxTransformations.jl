## Description #############################################################################
#
# Tests related to performance and memory allocations.
#
############################################################################################

@testset "Aqua.jl" begin
    Aqua.test_all(
        SatelliteToolboxTransformations;
        ambiguities = (recursive = false),
        deps_compat = (check_extras = false)
    )
end

@testset "JET Testing" begin
    rep = JET.test_package(
        SatelliteToolboxTransformations;
        toplevel_logger = nothing,
        target_modules = (@__MODULE__,)
    )
end

@testset "EOP Allocations" begin
    eop_iau1980  = read_iers_eop("./eop_IAU1980.txt",  Val(:IAU1980))
    eop_iau2000a = read_iers_eop("./eop_IAU2000A.txt", Val(:IAU2000A))

    test_functions = [eop_iau1980.x, eop_iau1980.y, eop_iau2000a.x, eop_iau2000a.y]

    for func in test_functions
        @test length(check_allocs(func, (Float64,))) == 0
    end

end

@testset "ECEF to ECEF Allocations" begin
    eop_iau1980  = read_iers_eop("./eop_IAU1980.txt",  Val(:IAU1980))
    eop_iau2000a = read_iers_eop("./eop_IAU2000A.txt", Val(:IAU2000A))

    frame_sets = (
        (ITRF(), PEF(),  eop_iau1980),
        (PEF(),  ITRF(), eop_iau1980),
        (ITRF(), TIRS(), eop_iau2000a),
        (TIRS(), ITRF(), eop_iau2000a),
    )

    for frame_set in frame_sets
         @test length(
            check_allocs(
                x -> begin
                    r_ecef_to_ecef(frame_set[1], frame_set[2], x, frame_set[3])
                end,
                (Float64,)
            )
        ) == 0
    end
end

@testset "ECEF to ECI Allocations" begin
    eop_iau1980  = read_iers_eop("./eop_IAU1980.txt",  Val(:IAU1980))
    eop_iau2000a = read_iers_eop("./eop_IAU2000A.txt", Val(:IAU2000A))

    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)

    frame_sets = (
        (ITRF(), GCRF(),   eop_iau1980),
        (ITRF(), J2000(),  eop_iau1980),
        (ITRF(), TOD(),    eop_iau1980),
        (ITRF(), MOD(),    eop_iau1980),
        (ITRF(), TEME(),   eop_iau1980),
        (PEF(),  GCRF(),   eop_iau1980),
        (PEF(),  J2000(),  eop_iau1980),
        (PEF(),  TOD(),    eop_iau1980),
        (PEF(),  MOD(),    eop_iau1980),
        (PEF(),  TEME(),   eop_iau1980),
        (ITRF(), CIRS(),   eop_iau2000a),
        (ITRF(), GCRF(),   eop_iau2000a),
        (TIRS(), CIRS(),   eop_iau2000a),
        (TIRS(), GCRF(),   eop_iau2000a),
        (ITRF(), ERS(),    eop_iau2000a),
        (ITRF(), MOD06(),  eop_iau2000a),
        (ITRF(), MJ2000(), eop_iau2000a),
        (TIRS(), ERS(),    eop_iau2000a),
        (TIRS(), MOD06(),  eop_iau2000a),
        (TIRS(), MJ2000(), eop_iau2000a),
    )

    for frame_set in frame_sets
        @test length(
            check_allocs(
                x -> begin
                    r_ecef_to_eci(frame_set[1], frame_set[2], x, frame_set[3])
                end,
                (Float64,)
            )
        ) == 0
    end

end

@testset "ECI to ECEF Allocations" begin
    eop_iau1980  = read_iers_eop("./eop_IAU1980.txt",  Val(:IAU1980))
    eop_iau2000a = read_iers_eop("./eop_IAU2000A.txt", Val(:IAU2000A))

    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)

    frame_sets = (
        (GCRF(),   ITRF(), eop_iau1980),
        (J2000(),  ITRF(), eop_iau1980),
        (TOD(),    ITRF(), eop_iau1980),
        (MOD(),    ITRF(), eop_iau1980),
        (TEME(),   ITRF(), eop_iau1980),
        (GCRF(),   PEF(),  eop_iau1980),
        (J2000(),  PEF(),  eop_iau1980),
        (TOD(),    PEF(),  eop_iau1980),
        (MOD(),    PEF(),  eop_iau1980),
        (TEME(),   PEF(),  eop_iau1980),
        (GCRF(),   TIRS(), eop_iau2000a),
        (GCRF(),   ITRF(), eop_iau2000a),
        (CIRS(),   TIRS(), eop_iau2000a),
        (CIRS(),   ITRF(), eop_iau2000a),
        (ERS(),    ITRF(), eop_iau2000a),
        (MOD06(),  ITRF(), eop_iau2000a),
        (MJ2000(), ITRF(), eop_iau2000a),
        (ERS(),    TIRS(), eop_iau2000a),
        (MOD06(),  TIRS(), eop_iau2000a),
        (MJ2000(), TIRS(), eop_iau2000a),
    )

    for frame_set in frame_sets
        @test length(
            check_allocs(
                x -> begin
                    r_ecef_to_eci(frame_set[1], frame_set[2], x, frame_set[3])
                end,
                (Float64,)
            )
        ) == 0
    end
end

@testset "ECI to ECI Allocations" begin

    eop_iau1980  = read_iers_eop("./eop_IAU1980.txt",  Val(:IAU1980))
    eop_iau2000a = read_iers_eop("./eop_IAU2000A.txt", Val(:IAU2000A))

    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)

    frame_sets = (
        (GCRF(),   J2000(),  eop_iau1980),
        (J2000(),  GCRF(),   eop_iau1980),
        (GCRF(),   MOD(),    eop_iau1980),
        (MOD(),    GCRF(),   eop_iau1980),
        (GCRF(),   TOD(),    eop_iau1980),
        (TOD(),    GCRF(),   eop_iau1980),
        (GCRF(),   TEME(),   eop_iau1980),
        (TEME(),   GCRF(),   eop_iau1980),
        (MOD(),    J2000(),  eop_iau1980),
        (J2000(),  MOD(),    eop_iau1980),
        (TOD(),    J2000(),  eop_iau1980),
        (J2000(),  TOD(),    eop_iau1980),
        (TEME(),   J2000(),  eop_iau1980),
        (J2000(),  TEME(),   eop_iau1980),
        (GCRF(),   CIRS(),   eop_iau2000a),
        (CIRS(),   GCRF(),   eop_iau2000a),
        (GCRF(),   MJ2000(), eop_iau2000a),
        (MJ2000(), GCRF(),   eop_iau2000a),
        (GCRF(),   MOD06(),  eop_iau2000a),
        (MOD06(),  GCRF(),   eop_iau2000a),
        (GCRF(),   ERS(),    eop_iau2000a),
        (ERS(),    GCRF(),   eop_iau2000a),
        (MJ2000(), MOD06(),  eop_iau2000a),
        (MOD06(),  MJ2000(), eop_iau2000a),
        (MJ2000(), ERS(),    eop_iau2000a),
        (ERS(),    MJ2000(), eop_iau2000a),
    )

    for frame_set in frame_sets
        @test length(
            check_allocs(
                x -> begin
                    r_ecef_to_eci(frame_set[1], frame_set[2], x, frame_set[3])
                end,
                (Float64,)
            )
        ) == 0
    end

end

@testset "ECI to ECI Allocations" begin

    eop_iau1980  = read_iers_eop("./eop_IAU1980.txt",  Val(:IAU1980))
    eop_iau2000a = read_iers_eop("./eop_IAU2000A.txt", Val(:IAU2000A))

    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)

    frame_sets = (
        (MOD(),   TOD(),   eop_iau1980),
        (TOD(),   MOD(),   eop_iau1980),
        (MOD(),   TEME(),  eop_iau1980),
        (TEME(),  MOD(),   eop_iau1980),
        (TOD(),   TEME(),  eop_iau1980),
        (TEME(),  TOD(),   eop_iau1980),
        (CIRS(),  CIRS(),  eop_iau2000a),
        (ERS(),   MOD06(), eop_iau2000a),
        (MOD06(), ERS(),   eop_iau2000a),
    )

    for frame_set in frame_sets
        @test length(
            check_allocs(
                x -> begin
                    r_ecef_to_eci(frame_set[1], frame_set[2], x, frame_set[3])
                end,
                (Float64,)
            )
        ) == 0
    end

end

@testset "Geodetic Geocentric Allocations" begin
    @test length(check_allocs(ecef_to_geocentric, (Vector{Float64}, ))) == 0
    @test length(check_allocs(geocentric_to_ecef, (Vector{Float64}, ))) == 0
    @test length(check_allocs(geodetic_to_ecef, (Vector{Float64}, ))) == 0
    @test length(check_allocs(ecef_to_geodetic, (Vector{Float64}, ))) == 0
    @test length(check_allocs(geodetic_to_geocentric, (Vector{Float64}, ))) == 0
    @test length(check_allocs(geocentric_to_geodetic, (Vector{Float64}, ))) == 0
end

@testset "Time Allocations" begin
    @test length(check_allocs(get_Δat, (Float64,))) == 0
    @test length(check_allocs(jd_utc_to_ut1, (Float64, Float64))) == 0
    @test length(check_allocs(jd_ut1_to_utc, (Float64, Float64))) == 0
    @test length(check_allocs(jd_utc_to_tt, (Float64,))) == 0
    @test length(check_allocs(jd_tt_to_utc, (Float64,))) == 0
end
