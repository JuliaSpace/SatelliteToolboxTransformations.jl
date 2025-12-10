## Description #############################################################################
#
# Tests related to automatic differentiation for the Time Conversions.
#
############################################################################################

@testset "Leap Second Automatic Differentiation" begin

    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)

    f_fd, df_fd = value_and_derivative(
        get_Δat,
        AutoFiniteDiff(),
        jd_utc
    )

    for backend in _BACKENDS
        if backend[1] == "Zygote"
            continue
        end
        @eval @testset $("Leap Second Lookup " * string(backend[1])) begin
            f_ad, df_ad = value_and_derivative(
                get_Δat,
                $backend[2],
                $jd_utc
            )

            @test $f_fd == f_ad
            @test $df_fd == df_ad
        end
    end

    @testset "Leap Second Lookup Zygote" begin
        try
            f_ad, df_ad = value_and_derivative(
                get_Δat,
                AutoZygote(),
                jd_utc
            )
        catch err
            @test err isa MethodError
            @test startswith(sprint(showerror, err), "MethodError: no method matching iterate(::Nothing)")
        end
    end

    test_functions = [jd_utc_to_ut1, jd_ut1_to_utc]
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    ΔUT1 = -0.463326

    eop_iau1980  = read_iers_eop("./eop_IAU1980.txt",  Val(:IAU1980))
    eop_iau2000a = read_iers_eop("./eop_IAU2000A.txt", Val(:IAU2000A))

    for backend in _BACKENDS
        testset_name = "Time Conversions UTC <=> UT1 " * string(backend[1])
        @testset "$testset_name" begin
            for func in test_functions
                f_fd, df_fd = value_and_derivative(
                    (x) -> func(x, ΔUT1),
                    AutoFiniteDiff(),
                    jd_utc
                )

                f_fd2, df_fd2 = value_and_derivative(
                    (x) -> func(jd_utc, x),
                    AutoFiniteDiff(),
                    ΔUT1
                )

                f_fd3, df_fd3 = value_and_derivative(
                    (x) -> func(x, eop_iau1980),
                    AutoFiniteDiff(),
                    jd_utc
                )

                f_fd4, df_fd4 = value_and_derivative(
                    (x) -> func(x, eop_iau2000a),
                    AutoFiniteDiff(),
                    jd_utc
                )

                f_ad, df_ad = value_and_derivative(
                    (x) -> func(x, ΔUT1),
                    backend[2],
                    jd_utc
                )

                @test f_fd ≈ f_ad rtol=1e-10
                @test df_fd ≈ df_ad atol=1e-4

                f_ad2, df_ad2 = value_and_derivative(
                    (x) -> func(jd_utc, x),
                    backend[2],
                    ΔUT1
                )

                @test f_fd2 ≈ f_ad2 rtol=1e-10
                @test df_fd2 ≈ df_ad2 atol=1e-4

                f_ad3, df_ad3 = value_and_derivative(
                    (x) -> func(x, eop_iau1980),
                    backend[2],
                    jd_utc
                )

                @test f_fd3 ≈ f_ad3 rtol=1e-10
                @test df_fd3 ≈ df_ad3 atol=1e-4

                f_ad4, df_ad4 = value_and_derivative(
                    (x) -> func(x, eop_iau2000a),
                    backend[2],
                    jd_utc
                )

                @test f_fd4 ≈ f_ad4 rtol=1e-10
                @test df_fd4 ≈ df_ad4 atol=1e-4
            end
        end
    end


    test_functions = [jd_utc_to_tt, jd_tt_to_utc]
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    ΔUT1 = -0.463326

    for backend in _BACKENDS
        testset_name = "Time Conversions UTC <=> TT " * string(backend[1])
        @testset "$testset_name" begin
            for func in test_functions
                f_fd, df_fd = value_and_derivative(
                    func,
                    AutoFiniteDiff(),
                    jd_utc
                )

                f_ad, df_ad = value_and_derivative(
                    func,
                    backend[2],
                    jd_utc
                )

                @test f_fd == f_ad
                @test df_fd ≈ df_ad rtol=1e-4
            end
        end
    end
end
