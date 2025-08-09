## Description #############################################################################
#
# Tests related to automatic differentiation for the EOP functions.
#
############################################################################################

@testset "Time Automatic Differentiation" begin

    eop_iau1980  = read_iers_eop("./eop_IAU1980.txt",  Val(:IAU1980))
    eop_iau2000a = read_iers_eop("./eop_IAU2000A.txt", Val(:IAU2000A))

    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)

    test_functions = [eop_iau1980.x, eop_iau1980.y, eop_iau2000a.x, eop_iau2000a.y]

    for backend in _BACKENDS
        if backend[1] == "Enzyme"
            # Enzyme has trouble recognizing the anonymous function call as constant so
            # those checks are separated.
            continue
        end
        testset_name = "EOP Functions " * string(backend[1])
        @testset "$testset_name" begin
            for f in test_functions
                f_fd, df_fd = value_and_derivative(
                    (x) -> f(x),
                    AutoFiniteDiff(),
                    jd_utc
                )

                f_ad, df_ad = value_and_derivative(
                    (x) -> f(x),
                    backend[2],
                    jd_utc
                )

                @test f_fd == f_ad
                @test df_fd ≈ df_ad rtol=1e-4
            end
        end
    end

    testset_name = "EOP Functions Enzyme"
    @testset "$testset_name" begin
        for f in test_functions
            f_fd, df_fd = value_and_derivative(
                (x) -> f(x),
                AutoFiniteDiff(),
                jd_utc
            )

            f_ad, df_ad = value_and_derivative(
                Const((x) -> f(x)),
                AutoEnzyme(),
                jd_utc
            )

            @test f_fd == f_ad
            @test df_fd ≈ df_ad rtol=1e-4
        end
    end
end
