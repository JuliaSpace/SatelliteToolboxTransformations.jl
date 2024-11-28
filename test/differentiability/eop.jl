## Description #############################################################################
#
# Tests related to automatic differentiation for the EOP functions.
#
############################################################################################
using Test
using FiniteDiff, ForwardDiff, Diffractor, Enzyme, Mooncake, PolyesterForwardDiff, Zygote

@testset "Time Automatic Differentiation" begin

    eop_iau1980  = read_iers_eop("test/eop_IAU1980.txt",  Val(:IAU1980))
    eop_iau2000a = read_iers_eop("test/eop_IAU2000A.txt", Val(:IAU2000A))

    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)

    r_itrf = [-1033.4793830; 7901.2952754; 6380.3565958]
    v_itrf = [-3.225636520; -2.872451450; +5.531924446]

    test_functions = [eop_iau1980.x, eop_iau1980.y, eop_iau2000a.x, eop_iau2000a.y]

    for backend in _BACKENDS
        if backend[1] == "Diffractor"
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
end