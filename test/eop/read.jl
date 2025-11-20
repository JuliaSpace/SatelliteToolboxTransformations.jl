## Description #############################################################################
#
# Tests related to reading and parsing the EOP.
#
############################################################################################

# == File: ./src/eop/read.jl ===============================================================

# -- Function: read_iers_eop ---------------------------------------------------------------

@testset "Read and Parse EOP for IAU-76 / FK5 Theory (Old Format)" begin
    eop_iau1980 = read_iers_eop("../eop_IAU1980_old.txt") # outdated version of file

    eop_date_beg = date_to_jd(2004, 4, 1)
    eop_date_end = date_to_jd(2004, 4, 30)

    @test eop_iau1980.x.t[begin]              ≈ eop_date_beg
    @test eop_iau1980.x.t[end]                ≈ eop_date_end
    @test eop_iau1980.y.t[begin]              ≈ eop_date_beg
    @test eop_iau1980.y.t[end]                ≈ eop_date_end
    @test eop_iau1980.Δut1_utc.t[begin]       ≈ eop_date_beg
    @test eop_iau1980.Δut1_utc.t[end]         ≈ eop_date_end
    @test eop_iau1980.lod.t[begin]            ≈ eop_date_beg
    @test eop_iau1980.lod.t[end]              ≈ eop_date_end
    @test eop_iau1980.δΔψ.t[begin]            ≈ eop_date_beg
    @test eop_iau1980.δΔψ.t[end]              ≈ eop_date_end
    @test eop_iau1980.δΔϵ.t[begin]            ≈ eop_date_beg
    @test eop_iau1980.δΔϵ.t[end]              ≈ eop_date_end
    @test eop_iau1980.x_error.t[begin]        ≈ eop_date_beg
    @test eop_iau1980.x_error.t[end]          ≈ eop_date_end
    @test eop_iau1980.y_error.t[begin]        ≈ eop_date_beg
    @test eop_iau1980.y_error.t[end]          ≈ eop_date_end
    @test eop_iau1980.Δut1_utc_error.t[begin] ≈ eop_date_beg
    @test eop_iau1980.Δut1_utc_error.t[end]   ≈ eop_date_end
    @test eop_iau1980.lod_error.t[begin]      ≈ eop_date_beg
    @test eop_iau1980.lod_error.t[end]        ≈ eop_date_end
    @test eop_iau1980.δΔψ_error.t[begin]      ≈ eop_date_beg
    @test eop_iau1980.δΔψ_error.t[end]        ≈ eop_date_end
    @test eop_iau1980.δΔϵ_error.t[begin]      ≈ eop_date_beg
    @test eop_iau1980.δΔϵ_error.t[end]        ≈ eop_date_end

    @test eop_iau1980.x.u[begin]              ≈ -0.140238
    @test eop_iau1980.x.u[end]                ≈ -0.123711
    @test eop_iau1980.y.u[begin]              ≈ +0.320846
    @test eop_iau1980.y.u[end]                ≈ +0.401294
    @test eop_iau1980.Δut1_utc.u[begin]       ≈ -0.4336147
    @test eop_iau1980.Δut1_utc.u[end]         ≈ -0.4526761
    @test eop_iau1980.lod.u[begin]            ≈ +0.7489
    @test eop_iau1980.lod.u[end]              ≈ +0.6107
    @test eop_iau1980.δΔψ.u[begin]            ≈ -51.461
    @test eop_iau1980.δΔψ.u[end]              ≈ -50.344
    @test eop_iau1980.δΔϵ.u[begin]            ≈ -4.481
    @test eop_iau1980.δΔϵ.u[end]              ≈ -5.381
    @test eop_iau1980.x_error.u[begin]        ≈ +0.000084
    @test eop_iau1980.x_error.u[end]          ≈ +0.000069
    @test eop_iau1980.y_error.u[begin]        ≈ +0.000063
    @test eop_iau1980.y_error.u[end]          ≈ +0.000054
    @test eop_iau1980.Δut1_utc_error.u[begin] ≈ +0.0000030
    @test eop_iau1980.Δut1_utc_error.u[end]   ≈ +0.0000021
    @test eop_iau1980.lod_error.u[begin]      ≈ +0.0020
    @test eop_iau1980.lod_error.u[end]        ≈ +0.0023
    @test eop_iau1980.δΔψ_error.u[begin]      ≈ +0.254
    @test eop_iau1980.δΔψ_error.u[end]        ≈ +0.330
    @test eop_iau1980.δΔϵ_error.u[begin]      ≈ +0.108
    @test eop_iau1980.δΔϵ_error.u[end]        ≈ +0.126
end

@testset "Read and Parse EOP for IAU-76 / FK5 Theory" begin
    eop_iau1980 = read_iers_eop("../eop_IAU1980.txt")

    eop_date_beg = date_to_jd(2004, 4, 1)
    eop_date_end = date_to_jd(2004, 4, 30)

    @test eop_iau1980.x.t[begin]              ≈ eop_date_beg
    @test eop_iau1980.x.t[end]                ≈ eop_date_end
    @test eop_iau1980.y.t[begin]              ≈ eop_date_beg
    @test eop_iau1980.y.t[end]                ≈ eop_date_end
    @test eop_iau1980.Δut1_utc.t[begin]       ≈ eop_date_beg
    @test eop_iau1980.Δut1_utc.t[end]         ≈ eop_date_end
    @test eop_iau1980.lod.t[begin]            ≈ eop_date_beg
    @test eop_iau1980.lod.t[end]              ≈ eop_date_end
    @test eop_iau1980.δΔψ.t[begin]            ≈ eop_date_beg
    @test eop_iau1980.δΔψ.t[end]              ≈ eop_date_end
    @test eop_iau1980.δΔϵ.t[begin]            ≈ eop_date_beg
    @test eop_iau1980.δΔϵ.t[end]              ≈ eop_date_end
    @test eop_iau1980.x_error.t[begin]        ≈ eop_date_beg
    @test eop_iau1980.x_error.t[end]          ≈ eop_date_end
    @test eop_iau1980.y_error.t[begin]        ≈ eop_date_beg
    @test eop_iau1980.y_error.t[end]          ≈ eop_date_end
    @test eop_iau1980.Δut1_utc_error.t[begin] ≈ eop_date_beg
    @test eop_iau1980.Δut1_utc_error.t[end]   ≈ eop_date_end
    @test eop_iau1980.lod_error.t[begin]      ≈ eop_date_beg
    @test eop_iau1980.lod_error.t[end]        ≈ eop_date_end
    @test eop_iau1980.δΔψ_error.t[begin]      ≈ eop_date_beg
    @test eop_iau1980.δΔψ_error.t[end]        ≈ eop_date_end
    @test eop_iau1980.δΔϵ_error.t[begin]      ≈ eop_date_beg
    @test eop_iau1980.δΔϵ_error.t[end]        ≈ eop_date_end

    @test eop_iau1980.x.u[begin]              ≈ -0.140238
    @test eop_iau1980.x.u[end]                ≈ -0.123711
    @test eop_iau1980.y.u[begin]              ≈ +0.320846
    @test eop_iau1980.y.u[end]                ≈ +0.401294
    @test eop_iau1980.Δut1_utc.u[begin]       ≈ -0.4336147
    @test eop_iau1980.Δut1_utc.u[end]         ≈ -0.4526761
    @test eop_iau1980.lod.u[begin]            ≈ +0.7489
    @test eop_iau1980.lod.u[end]              ≈ +0.6107
    @test eop_iau1980.δΔψ.u[begin]            ≈ -51.461
    @test eop_iau1980.δΔψ.u[end]              ≈ -50.344
    @test eop_iau1980.δΔϵ.u[begin]            ≈ -4.481
    @test eop_iau1980.δΔϵ.u[end]              ≈ -5.381
    @test eop_iau1980.x_error.u[begin]        ≈ +0.000084
    @test eop_iau1980.x_error.u[end]          ≈ +0.000069
    @test eop_iau1980.y_error.u[begin]        ≈ +0.000063
    @test eop_iau1980.y_error.u[end]          ≈ +0.000054
    @test eop_iau1980.Δut1_utc_error.u[begin] ≈ +0.0000030
    @test eop_iau1980.Δut1_utc_error.u[end]   ≈ +0.0000021
    @test eop_iau1980.lod_error.u[begin]      ≈ +0.0020
    @test eop_iau1980.lod_error.u[end]        ≈ +0.0023
    @test eop_iau1980.δΔψ_error.u[begin]      ≈ +0.254
    @test eop_iau1980.δΔψ_error.u[end]        ≈ +0.330
    @test eop_iau1980.δΔϵ_error.u[begin]      ≈ +0.108
    @test eop_iau1980.δΔϵ_error.u[end]        ≈ +0.126
end

@testset "Read and Parse EOP for IAU-2006 / 2010A Theory (Old Format)" begin
    eop_iau2000a = read_iers_eop("../eop_IAU2000A_old.txt", Val(:IAU2000A))

    eop_date_beg = date_to_jd(2004, 4, 1)
    eop_date_end = date_to_jd(2004, 4, 30)

    @test eop_iau2000a.x.t[begin]              ≈ eop_date_beg
    @test eop_iau2000a.x.t[end]                ≈ eop_date_end
    @test eop_iau2000a.y.t[begin]              ≈ eop_date_beg
    @test eop_iau2000a.y.t[end]                ≈ eop_date_end
    @test eop_iau2000a.Δut1_utc.t[begin]       ≈ eop_date_beg
    @test eop_iau2000a.Δut1_utc.t[end]         ≈ eop_date_end
    @test eop_iau2000a.lod.t[begin]            ≈ eop_date_beg
    @test eop_iau2000a.lod.t[end]              ≈ eop_date_end
    @test eop_iau2000a.δx.t[begin]             ≈ eop_date_beg
    @test eop_iau2000a.δx.t[end]               ≈ eop_date_end
    @test eop_iau2000a.δy.t[begin]             ≈ eop_date_beg
    @test eop_iau2000a.δy.t[end]               ≈ eop_date_end
    @test eop_iau2000a.x_error.t[begin]        ≈ eop_date_beg
    @test eop_iau2000a.x_error.t[end]          ≈ eop_date_end
    @test eop_iau2000a.y_error.t[begin]        ≈ eop_date_beg
    @test eop_iau2000a.y_error.t[end]          ≈ eop_date_end
    @test eop_iau2000a.Δut1_utc_error.t[begin] ≈ eop_date_beg
    @test eop_iau2000a.Δut1_utc_error.t[end]   ≈ eop_date_end
    @test eop_iau2000a.lod_error.t[begin]      ≈ eop_date_beg
    @test eop_iau2000a.lod_error.t[end]        ≈ eop_date_end
    @test eop_iau2000a.δx_error.t[begin]       ≈ eop_date_beg
    @test eop_iau2000a.δx_error.t[end]         ≈ eop_date_end
    @test eop_iau2000a.δy_error.t[begin]       ≈ eop_date_beg
    @test eop_iau2000a.δy_error.t[end]         ≈ eop_date_end

    @test eop_iau2000a.x.u[begin]              ≈ -0.140238
    @test eop_iau2000a.x.u[end]                ≈ -0.123711
    @test eop_iau2000a.y.u[begin]              ≈ +0.320846
    @test eop_iau2000a.y.u[end]                ≈ +0.401294
    @test eop_iau2000a.Δut1_utc.u[begin]       ≈ -0.4336147
    @test eop_iau2000a.Δut1_utc.u[end]         ≈ -0.4526761
    @test eop_iau2000a.lod.u[begin]            ≈ +0.7489
    @test eop_iau2000a.lod.u[end]              ≈ +0.6107
    @test eop_iau2000a.δx.u[begin]             ≈ -0.028
    @test eop_iau2000a.δx.u[end]               ≈ 0.112
    @test eop_iau2000a.δy.u[begin]             ≈ -0.017
    @test eop_iau2000a.δy.u[end]               ≈ +0.016
    @test eop_iau2000a.x_error.u[begin]        ≈ +0.000084
    @test eop_iau2000a.x_error.u[end]          ≈ +0.000069
    @test eop_iau2000a.y_error.u[begin]        ≈ +0.000063
    @test eop_iau2000a.y_error.u[end]          ≈ +0.000054
    @test eop_iau2000a.Δut1_utc_error.u[begin] ≈ +0.0000030
    @test eop_iau2000a.Δut1_utc_error.u[end]   ≈ +0.0000021
    @test eop_iau2000a.lod_error.u[begin]      ≈ +0.0020
    @test eop_iau2000a.lod_error.u[end]        ≈ +0.0023
    @test eop_iau2000a.δx_error.u[begin]       ≈ +0.101
    @test eop_iau2000a.δx_error.u[end]         ≈ +0.131
    @test eop_iau2000a.δy_error.u[begin]       ≈ +0.108
    @test eop_iau2000a.δy_error.u[end]         ≈ +0.126
end

@testset "Read and Parse EOP for IAU-2006 / 2010A Theory" begin
    eop_iau2000a = read_iers_eop("../eop_IAU2000A.txt", Val(:IAU2000A))

    eop_date_beg = date_to_jd(2004, 4, 1)
    eop_date_end = date_to_jd(2004, 4, 30)

    @test eop_iau2000a.x.t[begin]              ≈ eop_date_beg
    @test eop_iau2000a.x.t[end]                ≈ eop_date_end
    @test eop_iau2000a.y.t[begin]              ≈ eop_date_beg
    @test eop_iau2000a.y.t[end]                ≈ eop_date_end
    @test eop_iau2000a.Δut1_utc.t[begin]       ≈ eop_date_beg
    @test eop_iau2000a.Δut1_utc.t[end]         ≈ eop_date_end
    @test eop_iau2000a.lod.t[begin]            ≈ eop_date_beg
    @test eop_iau2000a.lod.t[end]              ≈ eop_date_end
    @test eop_iau2000a.δx.t[begin]             ≈ eop_date_beg
    @test eop_iau2000a.δx.t[end]               ≈ eop_date_end
    @test eop_iau2000a.δy.t[begin]             ≈ eop_date_beg
    @test eop_iau2000a.δy.t[end]               ≈ eop_date_end
    @test eop_iau2000a.x_error.t[begin]        ≈ eop_date_beg
    @test eop_iau2000a.x_error.t[end]          ≈ eop_date_end
    @test eop_iau2000a.y_error.t[begin]        ≈ eop_date_beg
    @test eop_iau2000a.y_error.t[end]          ≈ eop_date_end
    @test eop_iau2000a.Δut1_utc_error.t[begin] ≈ eop_date_beg
    @test eop_iau2000a.Δut1_utc_error.t[end]   ≈ eop_date_end
    @test eop_iau2000a.lod_error.t[begin]      ≈ eop_date_beg
    @test eop_iau2000a.lod_error.t[end]        ≈ eop_date_end
    @test eop_iau2000a.δx_error.t[begin]       ≈ eop_date_beg
    @test eop_iau2000a.δx_error.t[end]         ≈ eop_date_end
    @test eop_iau2000a.δy_error.t[begin]       ≈ eop_date_beg
    @test eop_iau2000a.δy_error.t[end]         ≈ eop_date_end

    @test eop_iau2000a.x.u[begin]              ≈ -0.140238
    @test eop_iau2000a.x.u[end]                ≈ -0.123711
    @test eop_iau2000a.y.u[begin]              ≈ +0.320846
    @test eop_iau2000a.y.u[end]                ≈ +0.401294
    @test eop_iau2000a.Δut1_utc.u[begin]       ≈ -0.4336147
    @test eop_iau2000a.Δut1_utc.u[end]         ≈ -0.4526761
    @test eop_iau2000a.lod.u[begin]            ≈ +0.7489
    @test eop_iau2000a.lod.u[end]              ≈ +0.6107
    @test eop_iau2000a.δx.u[begin]             ≈ -0.028
    @test eop_iau2000a.δx.u[end]               ≈ 0.112
    @test eop_iau2000a.δy.u[begin]             ≈ -0.017
    @test eop_iau2000a.δy.u[end]               ≈ +0.016
    @test eop_iau2000a.x_error.u[begin]        ≈ +0.000084
    @test eop_iau2000a.x_error.u[end]          ≈ +0.000069
    @test eop_iau2000a.y_error.u[begin]        ≈ +0.000063
    @test eop_iau2000a.y_error.u[end]          ≈ +0.000054
    @test eop_iau2000a.Δut1_utc_error.u[begin] ≈ +0.0000030
    @test eop_iau2000a.Δut1_utc_error.u[end]   ≈ +0.0000021
    @test eop_iau2000a.lod_error.u[begin]      ≈ +0.0020
    @test eop_iau2000a.lod_error.u[end]        ≈ +0.0023
    @test eop_iau2000a.δx_error.u[begin]       ≈ +0.101
    @test eop_iau2000a.δx_error.u[end]         ≈ +0.131
    @test eop_iau2000a.δy_error.u[begin]       ≈ +0.108
    @test eop_iau2000a.δy_error.u[end]         ≈ +0.126
end
