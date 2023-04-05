# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==========================================================================================
#
#   Tests related to reading and parsing the EOP.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# File: ./src/eop/read.jl
# ==========================================================================================

# Functions read_iers_eop
# ------------------------------------------------------------------------------------------

@testset "Read EOP for IAU-76/FK5 theory" begin
    eop_iau1980 = read_iers_eop("../eop_IAU1980.txt")

    eop_date_beg = date_to_jd(2004, 4, 1)
    eop_date_end = date_to_jd(2004, 4, 30)

    @test eop_iau1980.lod.itp.knots[begin][begin]            ≈ eop_date_beg
    @test eop_iau1980.lod.itp.knots[begin][end]              ≈ eop_date_end
    @test eop_iau1980.x.itp.knots[begin][begin]              ≈ eop_date_beg
    @test eop_iau1980.x.itp.knots[begin][end]                ≈ eop_date_end
    @test eop_iau1980.y.itp.knots[begin][begin]              ≈ eop_date_beg
    @test eop_iau1980.y.itp.knots[begin][end]                ≈ eop_date_end
    @test eop_iau1980.Δut1_utc.itp.knots[begin][begin]       ≈ eop_date_beg
    @test eop_iau1980.Δut1_utc.itp.knots[begin][end]         ≈ eop_date_end
    @test eop_iau1980.δΔψ.itp.knots[begin][begin]            ≈ eop_date_beg
    @test eop_iau1980.δΔψ.itp.knots[begin][end]              ≈ eop_date_end
    @test eop_iau1980.δΔϵ.itp.knots[begin][begin]            ≈ eop_date_beg
    @test eop_iau1980.δΔϵ.itp.knots[begin][end]              ≈ eop_date_end
    @test eop_iau1980.lod_error.itp.knots[begin][begin]      ≈ eop_date_beg
    @test eop_iau1980.lod_error.itp.knots[begin][end]        ≈ eop_date_end
    @test eop_iau1980.x_error.itp.knots[begin][begin]        ≈ eop_date_beg
    @test eop_iau1980.x_error.itp.knots[begin][end]          ≈ eop_date_end
    @test eop_iau1980.y_error.itp.knots[begin][begin]        ≈ eop_date_beg
    @test eop_iau1980.y_error.itp.knots[begin][end]          ≈ eop_date_end
    @test eop_iau1980.Δut1_utc_error.itp.knots[begin][begin] ≈ eop_date_beg
    @test eop_iau1980.Δut1_utc_error.itp.knots[begin][end]   ≈ eop_date_end
    @test eop_iau1980.δΔψ_error.itp.knots[begin][begin]      ≈ eop_date_beg
    @test eop_iau1980.δΔψ_error.itp.knots[begin][end]        ≈ eop_date_end
    @test eop_iau1980.δΔϵ_error.itp.knots[begin][begin]      ≈ eop_date_beg
    @test eop_iau1980.δΔϵ_error.itp.knots[begin][end]        ≈ eop_date_end


    @test eop_iau1980.lod.itp.coefs[begin]            ≈ +0.7489
    @test eop_iau1980.lod.itp.coefs[end]              ≈ +0.6107
    @test eop_iau1980.x.itp.coefs[begin]              ≈ -0.140238
    @test eop_iau1980.x.itp.coefs[end]                ≈ -0.123711
    @test eop_iau1980.y.itp.coefs[begin]              ≈ +0.320846
    @test eop_iau1980.y.itp.coefs[end]                ≈ +0.401294
    @test eop_iau1980.Δut1_utc.itp.coefs[begin]       ≈ -0.4336147
    @test eop_iau1980.Δut1_utc.itp.coefs[end]         ≈ -0.4526761
    @test eop_iau1980.δΔψ.itp.coefs[begin]            ≈ -51.461
    @test eop_iau1980.δΔψ.itp.coefs[end]              ≈ -50.344
    @test eop_iau1980.δΔϵ.itp.coefs[begin]            ≈ -4.481
    @test eop_iau1980.δΔϵ.itp.coefs[end]              ≈ -5.381
    @test eop_iau1980.lod_error.itp.coefs[begin]      ≈ +0.0020
    @test eop_iau1980.lod_error.itp.coefs[end]        ≈ +0.0023
    @test eop_iau1980.x_error.itp.coefs[begin]        ≈ +0.000084
    @test eop_iau1980.x_error.itp.coefs[end]          ≈ +0.000069
    @test eop_iau1980.y_error.itp.coefs[begin]        ≈ +0.000063
    @test eop_iau1980.y_error.itp.coefs[end]          ≈ +0.000054
    @test eop_iau1980.Δut1_utc_error.itp.coefs[begin] ≈ +0.0000030
    @test eop_iau1980.Δut1_utc_error.itp.coefs[end]   ≈ +0.0000021
    @test eop_iau1980.δΔψ_error.itp.coefs[begin]      ≈ +0.254
    @test eop_iau1980.δΔψ_error.itp.coefs[end]        ≈ +0.330
    @test eop_iau1980.δΔϵ_error.itp.coefs[begin]      ≈ +0.108
    @test eop_iau1980.δΔϵ_error.itp.coefs[end]        ≈ +0.126
end
