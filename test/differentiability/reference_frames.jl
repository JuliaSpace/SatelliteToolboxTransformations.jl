## Description #############################################################################
#
# Tests related to automatic differentiation for the Reference Frame Rotations.
#
############################################################################################

@testset "ECEF to ECEF Time Automatic Differentiation" begin

    eop_iau1980  = read_iers_eop("./eop_IAU1980.txt",  Val(:IAU1980))
    eop_iau2000a = read_iers_eop("./eop_IAU2000A.txt", Val(:IAU2000A))

    eop_iau1980 = fetch_iers_eop(Val(:IAU1980))
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)

    frame_sets = (
        (ITRF(), PEF(), eop_iau1980),
        (PEF(), ITRF(), eop_iau1980),
        (ITRF(), TIRS(), eop_iau2000a),
        (TIRS(), ITRF(), eop_iau2000a),
    )

    for backend in _BACKENDS
        if backend[1] == "Enzyme"
            continue
        end
        testset_name = "ECEF to ECEF Time " * string(backend[1])
        @testset "$testset_name" begin
            for frames in frame_sets
                f_fd, df_fd = value_and_derivative(
                    (x) -> Array(r_ecef_to_ecef(frames[1], frames[2], x, frames[3])),
                    AutoFiniteDiff(),
                    jd_utc
                )
        
                f_ad, df_ad = value_and_derivative(
                    (x) -> Array(r_ecef_to_ecef(frames[1], frames[2], x, frames[3])),
                    backend[2],
                    jd_utc
                )

                @test f_fd == f_ad
                @test df_fd ≈ df_ad rtol=1e-4
            end
        end
    end

    testset_name = "ECEF to ECEF Time Enzyme"
    @testset "$testset_name" begin
        for frames in frame_sets
            f_fd, df_fd = value_and_derivative(
                (x) -> Array(r_ecef_to_ecef(frames[1], frames[2], x, frames[3])),
                AutoFiniteDiff(),
                jd_utc
            )
    
            f_ad, df_ad = value_and_derivative(
                Const((x) -> Array(r_ecef_to_ecef(frames[1], frames[2], x, frames[3]))),
                AutoEnzyme(),
                jd_utc
            )

            @test f_fd ≈ f_ad rtol=1e-14
            @test df_fd ≈ df_ad rtol=1e-4
        end
    end
end

@testset "ECEF to ECI Time Automatic Differentiation" begin

    eop_iau1980  = read_iers_eop("./eop_IAU1980.txt",  Val(:IAU1980))
    eop_iau2000a = read_iers_eop("./eop_IAU2000A.txt", Val(:IAU2000A))

    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)

    frame_sets = (
        (ITRF(), GCRF(), eop_iau1980),
        (ITRF(), J2000(), eop_iau1980),
        (ITRF(), TOD(), eop_iau1980),
        (ITRF(), MOD(), eop_iau1980),
        (ITRF(), TEME(), eop_iau1980),
        (PEF(), GCRF(), eop_iau1980),
        (PEF(), J2000(), eop_iau1980),
        (PEF(), TOD(), eop_iau1980),
        (PEF(), MOD(), eop_iau1980),
        (PEF(), TEME(), eop_iau1980),
        (ITRF(), CIRS(), eop_iau2000a),
        (ITRF(), GCRF(), eop_iau2000a),
        (TIRS(), CIRS(), eop_iau2000a),
        (TIRS(), GCRF(), eop_iau2000a),
        (ITRF(), ERS(), eop_iau2000a),
        (ITRF(), MOD06(), eop_iau2000a),
        (ITRF(), MJ2000(), eop_iau2000a),
        (TIRS(), ERS(), eop_iau2000a),
        (TIRS(), MOD06(), eop_iau2000a),
        (TIRS(), MJ2000(), eop_iau2000a),
    )
    
    for backend in _BACKENDS
        if backend[1] == "Enzyme"
            continue
        end
        testset_name = "ECEF to ECI Time " * string(backend[1])
        @testset "$testset_name" begin
            for frames in frame_sets
                f_fd, df_fd = value_and_derivative(
                    (x) -> Array(r_ecef_to_eci(frames[1], frames[2], x, frames[3])),
                    AutoFiniteDiff(),
                    jd_utc,
                )

                f_ad, df_ad = value_and_derivative(
                    (x) -> Array(r_ecef_to_eci(frames[1], frames[2], x, frames[3])),
                    backend[2],
                    jd_utc
                )

                @test f_fd ≈ f_ad rtol=1e-14
                @test df_fd ≈ df_ad rtol=2e-1
            end
        end
    end

    testset_name = "ECEF to ECI Time Enzyme"
    @testset "$testset_name" begin
        for frames in frame_sets
            f_fd, df_fd = value_and_derivative(
                (x) -> Array(r_ecef_to_eci(frames[1], frames[2], x, frames[3])),
                AutoFiniteDiff(),
                jd_utc
            )
    
            f_ad, df_ad = value_and_derivative(
                Const((x) -> Array(r_ecef_to_eci(frames[1], frames[2], x, frames[3]))),
                AutoEnzyme(),
                jd_utc
            )

            @test f_fd ≈ f_ad rtol=1e-14
            @test df_fd ≈ df_ad rtol=2e-1
        end
    end
end

@testset "ECI to ECEF Time Automatic Differentiation" begin

    eop_iau1980  = read_iers_eop("./eop_IAU1980.txt",  Val(:IAU1980))
    eop_iau2000a = read_iers_eop("./eop_IAU2000A.txt", Val(:IAU2000A))

    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)

    frame_sets = (
        (GCRF(), ITRF(), eop_iau1980),
        (J2000(), ITRF(), eop_iau1980),
        (TOD(), ITRF(), eop_iau1980),
        (MOD(), ITRF(), eop_iau1980),
        (TEME(), ITRF(), eop_iau1980),
        (GCRF(), PEF(), eop_iau1980),
        (J2000(), PEF(), eop_iau1980),
        (TOD(), PEF(), eop_iau1980),
        (MOD(), PEF(), eop_iau1980),
        (TEME(), PEF(), eop_iau1980),
        (GCRF(), TIRS(), eop_iau2000a),
        (GCRF(), ITRF(), eop_iau2000a),
        (CIRS(), TIRS(), eop_iau2000a),
        (CIRS(), ITRF(), eop_iau2000a),
        (ERS(), ITRF(), eop_iau2000a),
        (MOD06(), ITRF(), eop_iau2000a),
        (MJ2000(), ITRF(), eop_iau2000a),
        (ERS(), TIRS(), eop_iau2000a),
        (MOD06(), TIRS(), eop_iau2000a),
        (MJ2000(), TIRS(), eop_iau2000a),
    )
    

    for backend in _BACKENDS
        if backend[1] == "Enzyme"
            continue
        end
        testset_name = "ECI to ECEF Time " * string(backend[1])
        @testset "$testset_name" begin
            for frames in frame_sets
                f_fd, df_fd = value_and_derivative(
                    (x) -> Array(r_eci_to_ecef(frames[1], frames[2], x, frames[3])),
                    AutoFiniteDiff(),
                    jd_utc,
                )

                f_ad, df_ad = value_and_derivative(
                    (x) -> Array(r_eci_to_ecef(frames[1], frames[2], x, frames[3])),
                    backend[2],
                    jd_utc
                )

                @test f_fd ≈ f_ad rtol=1e-14
                @test df_fd ≈ df_ad rtol=2e-1
            end
        end
    end

    testset_name = "ECI to ECEF Time Enzyme"
    @testset "$testset_name" begin
        for frames in frame_sets
            f_fd, df_fd = value_and_derivative(
                (x) -> Array(r_eci_to_ecef(frames[1], frames[2], x, frames[3])),
                AutoFiniteDiff(),
                jd_utc
            )
    
            f_ad, df_ad = value_and_derivative(
                Const((x) -> Array(r_eci_to_ecef(frames[1], frames[2], x, frames[3]))),
                AutoEnzyme(),
                jd_utc
            )

            @test f_fd ≈ f_ad rtol=1e-14
            @test df_fd ≈ df_ad rtol=2e-1
        end
    end
end

@testset "ECI to ECI Time Automatic Differentiation" begin

    eop_iau1980  = read_iers_eop("./eop_IAU1980.txt",  Val(:IAU1980))
    eop_iau2000a = read_iers_eop("./eop_IAU2000A.txt", Val(:IAU2000A))

    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)

    frame_sets = (
        (GCRF(), J2000(), eop_iau1980),
        (J2000(), GCRF(), eop_iau1980),
        (GCRF(), MOD(), eop_iau1980),
        (MOD(), GCRF(), eop_iau1980),
        (GCRF(), TOD(), eop_iau1980),
        (TOD(), GCRF(), eop_iau1980),
        (GCRF(), TEME(), eop_iau1980),
        (TEME(), GCRF(), eop_iau1980),
        (MOD(), J2000(), eop_iau1980),
        (J2000(), MOD(), eop_iau1980),
        (TOD(), J2000(), eop_iau1980),
        (J2000(), TOD(), eop_iau1980),
        (TEME(), J2000(), eop_iau1980),
        (J2000(), TEME(), eop_iau1980),
        (GCRF(), CIRS(), eop_iau2000a),
        (CIRS(), GCRF(), eop_iau2000a),
        (GCRF(), MJ2000(), eop_iau2000a),
        (MJ2000(), GCRF(), eop_iau2000a),
        (GCRF(), MOD06(), eop_iau2000a),
        (MOD06(), GCRF(), eop_iau2000a),
        (GCRF(), ERS(), eop_iau2000a),
        (ERS(), GCRF(), eop_iau2000a),
        (MJ2000(), MOD06(), eop_iau2000a),
        (MOD06(), MJ2000(), eop_iau2000a),
        (MJ2000(), ERS(), eop_iau2000a),
        (ERS(), MJ2000(), eop_iau2000a),
    )
    
    for backend in _BACKENDS
        if backend[1] == "Zygote" || backend[1] == "Enzyme"
            continue
        end
        testset_name = "ECI to ECI Time " * string(backend[1])
        @testset "$testset_name" begin
            for frames in frame_sets
                f_fd, df_fd = value_and_derivative(
                    (x) -> Array(r_eci_to_eci(frames[1], frames[2], x, frames[3])),
                    AutoFiniteDiff(),
                    jd_utc,
                )

                f_ad, df_ad = value_and_derivative(
                    (x) -> Array(r_eci_to_eci(frames[1], frames[2], x, frames[3])),
                    backend[2],
                    jd_utc
                )

                @test f_fd ≈ f_ad rtol=1e-14
                @test df_fd ≈ df_ad rtol=2e-1
            end
        end
    end

    testset_name = "ECI to ECI Time Zygote"
    @testset "$testset_name" begin
        for frames in frame_sets
            f_fd, df_fd = value_and_derivative(
                (x) -> Array(r_eci_to_eci(frames[1], frames[2], x, frames[3])),
                AutoFiniteDiff(),
                jd_utc,
            )

            try                
                f_ad, df_ad = value_and_derivative(
                    (x) -> Array(r_eci_to_eci(frames[1], frames[2], x, frames[3])),
                    AutoZygote(),
                    jd_utc
                )

                @test f_fd ≈ f_ad rtol=1e-14
                @test df_fd ≈ df_ad rtol=2e-1
            catch err
                @test err isa MethodError
                @test startswith(sprint(showerror, err), "MethodError: no method matching iterate(::Nothing)")
            end
        end
    end

    testset_name = "ECI to ECI Time Enzyme"
    @testset "$testset_name" begin
        for frames in frame_sets
            f_fd, df_fd = value_and_derivative(
                (x) -> Array(r_eci_to_eci(frames[1], frames[2], x, frames[3])),
                AutoFiniteDiff(),
                jd_utc
            )
    
            f_ad, df_ad = value_and_derivative(
                Const((x) -> Array(r_eci_to_eci(frames[1], frames[2], x, frames[3]))),
                AutoEnzyme(),
                jd_utc
            )

            @test f_fd ≈ f_ad rtol=1e-14
            @test df_fd ≈ df_ad rtol=2e-1
        end
    end
end

@testset "ECI to ECI Time Automatic Differentiation" begin

    eop_iau1980  = read_iers_eop("./eop_IAU1980.txt",  Val(:IAU1980))
    eop_iau2000a = read_iers_eop("./eop_IAU2000A.txt", Val(:IAU2000A))

    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    
    frame_sets = (
        (MOD(), TOD(), eop_iau1980),
        (TOD(), MOD(), eop_iau1980),
        (MOD(), TEME(), eop_iau1980),
        (TEME(), MOD(), eop_iau1980),
        (TOD(), TEME(), eop_iau1980),
        (TEME(), TOD(), eop_iau1980),
        (CIRS(), CIRS(), eop_iau2000a),
        (ERS(), MOD06(), eop_iau2000a),
        (MOD06(), ERS(), eop_iau2000a),
    )
    

    for backend in _BACKENDS
        if backend[1] == "Enzyme"
            continue
        end
        testset_name = "ECI to ECI Time " * string(backend[1])
        @testset "$testset_name" begin
            for frames in frame_sets
                f_fd, df_fd = value_and_derivative(
                    (x) -> Array(r_eci_to_eci(frames[1], x, frames[2], x, frames[3])),
                    AutoFiniteDiff(),
                    jd_utc,
                )

                f_ad, df_ad = value_and_derivative(
                    (x) -> Array(r_eci_to_eci(frames[1], x, frames[2], x, frames[3])),
                    backend[2],
                    jd_utc
                )

                @test f_fd ≈ f_ad rtol=1e-14
                @test df_fd ≈ df_ad atol=1e-4
            end
        end
    end

    testset_name = "ECI to ECI Time Enzyme"
    @testset "$testset_name" begin
        for frames in frame_sets
            f_fd, df_fd = value_and_derivative(
                (x) -> Array(r_eci_to_eci(frames[1], x, frames[2], x, frames[3])),
                AutoFiniteDiff(),
                jd_utc
            )
    
            f_ad, df_ad = value_and_derivative(
                Const((x) -> Array(r_eci_to_eci(frames[1], x, frames[2], x, frames[3]))),
                AutoEnzyme(),
                jd_utc
            )

            @test f_fd ≈ f_ad rtol=1e-14
            @test df_fd ≈ df_ad atol=1e-4
        end
    end
end

@testset "Geodetic Geocentric State Automatic Differentiation" begin
    
    ecef_pos = [7000e3; 0.0; 7000e3]

    f_fd, df_fd = value_and_jacobian(
        (x) -> collect(ecef_to_geocentric(x)),
        AutoFiniteDiff(),
        ecef_pos,
    )

    for backend in _BACKENDS
        testset_name = "ECEF to Geocentric " * string(backend[1])
        @testset "$testset_name" begin
            f_ad, df_ad = value_and_jacobian(
                (x) -> collect(ecef_to_geocentric(x)),
                backend[2],
                ecef_pos
            )

            @test f_fd ≈ f_ad rtol=1e-14
            @test df_fd ≈ df_ad rtol=2e-1
        end
    end

    geocentric_state = [deg2rad(45.0); deg2rad(0.0); 7000 * √2]

    f_fd, df_fd = value_and_jacobian(
        (x) -> collect(geocentric_to_ecef(x)),
        AutoFiniteDiff(),
        geocentric_state,
    )

    for backend in _BACKENDS
        testset_name = "Geocentric to ECEF " * string(backend[1])
        @testset "$testset_name" begin
            f_ad, df_ad = value_and_jacobian(
                (x) -> Array(geocentric_to_ecef(x)),
                backend[2],
                geocentric_state
            )

            @test f_fd ≈ f_ad rtol=1e-14
            @test df_fd ≈ df_ad rtol=2e-1
        end
    end

    ecef_pos = [7000e3; 0.0; 7000e3]

    f_fd, df_fd = value_and_jacobian(
        (x) -> collect(ecef_to_geodetic(x)),
        AutoFiniteDiff(),
        ecef_pos,
    )

    for backend in _BACKENDS
        testset_name = "ECEF to Geodetic " * string(backend[1])
        @testset "$testset_name" begin
            f_ad, df_ad = value_and_jacobian(
                (x) -> collect(ecef_to_geodetic(x)),
                backend[2],
                ecef_pos
            )

            @test f_fd ≈ f_ad rtol=1e-14
            @test df_fd ≈ df_ad rtol=2e-1
        end
    end

    geodetic_state = [deg2rad(45.0); deg2rad(0.0); 400.0]
    
    f_fd, df_fd = value_and_jacobian(
        (x) -> geodetic_to_ecef(x),
        AutoFiniteDiff(),
        geodetic_state,
    )

    for backend in _BACKENDS
        testset_name = "Geodetic to ECEF " * string(backend[1])
        @testset "$testset_name" begin
            f_ad, df_ad = value_and_jacobian(
                (x) -> Array(geodetic_to_ecef(x)),
                backend[2],
                geodetic_state
            )

            @test f_fd ≈ f_ad rtol=1e-14
            @test df_fd ≈ df_ad rtol=2e-1
        end
    end

    geocentric_state = [deg2rad(45.0); 7000 * √2]
    
    f_fd, df_fd = value_and_jacobian(
        (x) -> collect(geocentric_to_geodetic(x)),
        AutoFiniteDiff(),
        geocentric_state,
    )
    
    for backend in _BACKENDS
        testset_name = "Geocentric to Geodetic " * string(backend[1])
        @testset "$testset_name" begin
            f_ad, df_ad = value_and_jacobian(
                (x) -> collect(geocentric_to_geodetic(x)),
                backend[2],
                geocentric_state
            )

            @test f_fd ≈ f_ad rtol=1e-14
            @test df_fd ≈ df_ad rtol=2e-1
        end
    end

    geodetic_state = [deg2rad(45.0); 400.0]
    
    f_fd, df_fd = value_and_jacobian(
        (x) -> collect(geodetic_to_geocentric(x)),
        AutoFiniteDiff(),
        geodetic_state,
    )

    for backend in _BACKENDS
        testset_name = "Geodetic to Geocentric " * string(backend[1])
        @testset "$testset_name" begin
            f_ad, df_ad = value_and_jacobian(
                (x) -> collect(geodetic_to_geocentric(x)),
                backend[2],
                geodetic_state
            )

            @test f_fd ≈ f_ad rtol=1e-14
            @test df_fd ≈ df_ad rtol=2e-1
        end
    end
end

        