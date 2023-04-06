# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==========================================================================================
#
#   Tests related to conversion between the orbit anomalies.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# References
# ==========================================================================================
#
#   [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm
#       Press, Hawthorn, CA, USA.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# File: ./src/orbit/anomalies.jl
# ==========================================================================================

# Functions: mean_to_eccentric_anomaly and eccentric_to_mean_anomaly
# ------------------------------------------------------------------------------------------

############################################################################################
#                                       Test Results
############################################################################################
#
# Example 2-1: Using Kepler's Equation [1, p. 66].
#
# According to this example, if:
#
#   M = 235.4°
#   e = 0.4
#
# then
#
#   E = 220.512_074_767_522°
#
############################################################################################

@testset "Functions mean_to_eccentric_anomaly and eccentric_to_mean_anomaly" begin
    M = 235.4 |> deg2rad
    e = 0.4

    E = mean_to_eccentric_anomaly(e, M)
    @test E ≈ 220.512_074_767_522 |> deg2rad atol = 1e-14

    E = mean_to_eccentric_anomaly(e, M; max_iterations = -1)
    @test E ≈ 220.512_074_767_522 |> deg2rad atol = 1e-14

    E = 220.512_074_767_522 |> deg2rad

    M = eccentric_to_mean_anomaly(e, E)
    @test M ≈ 235.4 |> deg2rad atol = 1e-14

    # Types
    # ======================================================================================

    E = mean_to_eccentric_anomaly(0, 0.5)
    @test E isa Float64
    E = mean_to_eccentric_anomaly(0.0, 0)
    @test E isa Float64
    E = mean_to_eccentric_anomaly(0, 0.5f0)
    @test E isa Float32
    E = mean_to_eccentric_anomaly(0.0f0, 0)
    @test E isa Float32

    M = eccentric_to_mean_anomaly(0, 0.5)
    @test M isa Float64
    M = eccentric_to_mean_anomaly(0.0, 0)
    @test M isa Float64
    M = eccentric_to_mean_anomaly(0, 0.5f0)
    @test M isa Float32
    M = eccentric_to_mean_anomaly(0.0f0, 0)
    @test M isa Float32
end

# Functions: mean_to_true_anomaly and true_to_mean_anomaly
# ------------------------------------------------------------------------------------------

############################################################################################
#                                       Test Results
############################################################################################
#
# Values obtained from the old, validated code in SatelliteToolbox.jl.
#
# If we have:
#
#   M = 235.4°
#   e = 0.4
#
# then
#
#   f = 207.163_991_769_213_96°
#
############################################################################################

@testset "Functions mean_to_true_anomaly and true_to_mean_anomaly" begin
    M = 235.4 |> deg2rad
    e = 0.4

    f = mean_to_true_anomaly(e, M)
    @test f ≈ 207.163_991_769_213_96 |> deg2rad atol = 1e-14

    f = mean_to_true_anomaly(e, M; max_iterations = -1)
    @test f ≈ 207.163_991_769_213_96 |> deg2rad atol = 1e-14

    f = 207.163_991_769_213_96 |> deg2rad

    M = true_to_mean_anomaly(e, f)
    @test M ≈ 235.4 |> deg2rad atol = 1e-14

    # Types
    # ======================================================================================

    f = mean_to_true_anomaly(0, 0.5)
    @test f isa Float64
    f = mean_to_true_anomaly(0.0, 0)
    @test f isa Float64
    f = mean_to_true_anomaly(0, 0.5f0)
    @test f isa Float32
    f = mean_to_true_anomaly(0.0f0, 0)
    @test f isa Float32

    M = true_to_mean_anomaly(0, 0.5)
    @test M isa Float64
    M = true_to_mean_anomaly(0.0, 0)
    @test M isa Float64
    M = true_to_mean_anomaly(0, 0.5f0)
    @test M isa Float32
    M = true_to_mean_anomaly(0.0f0, 0)
    @test M isa Float32
end

# Functions: eccentric_to_true_anomaly and true_to_eccentric_anomaly
# ------------------------------------------------------------------------------------------

############################################################################################
#                                       Test Results
############################################################################################
#
# Values obtained from the old, validated code in SatelliteToolbox.jl.
#
# If we have:
#
#   E = 235.4°
#   e = 0.4
#
# then
#
#   f = 217.935_779_687_955_03°
#
############################################################################################

@testset "Functions eccentric_to_true_anomaly and true_to_eccentric_anomaly" begin
    E = 235.4 |> deg2rad
    e = 0.4

    f = eccentric_to_true_anomaly(e, E)
    @test f ≈ 217.935_779_687_955_03 |> deg2rad atol = 1e-14

    f = 217.935_779_687_955_03 |> deg2rad

    E = true_to_eccentric_anomaly(e, f)
    @test E ≈ 235.4 |> deg2rad atol = 1e-14

    # Types
    # ======================================================================================

    f = eccentric_to_true_anomaly(0, 0.5)
    @test f isa Float64
    f = eccentric_to_true_anomaly(0.0, 0)
    @test f isa Float64
    f = eccentric_to_true_anomaly(0, 0.5f0)
    @test f isa Float32
    f = eccentric_to_true_anomaly(0.0f0, 0)
    @test f isa Float32

    E = true_to_eccentric_anomaly(0, 0.5)
    @test E isa Float64
    E = true_to_eccentric_anomaly(0.0, 0)
    @test E isa Float64
    E = true_to_eccentric_anomaly(0, 0.5f0)
    @test E isa Float32
    E = true_to_eccentric_anomaly(0.0f0, 0)
    @test E isa Float32
end
