## Description #############################################################################
#
# Tests related to the transformations of local reference frames.
#
############################################################################################

# == File: ./src/transformations/local_frame.jl ============================================

# -- Functions: ecef_to_ned and ned_to_ecef ------------------------------------------------

@testset "Functions ecef_to_ned and ned_to_ecef" begin
    R0     = 6378137.0
    lat    = 0.5
    lon    = 0.44
    h      = 130e3
    r_ecef = SVector(R0, 0, -R0)

    r_ned = ecef_to_ned(r_ecef, lat, lon, h; translate = true)

    @test r_ned[1] ≈ -8.345950969454717e6
    @test r_ned[2] ≈ -2.7167002618976594e6
    @test r_ned[3] ≈ 4.496865561149651e6

    r_ecef_conv = ned_to_ecef(r_ned, lat, lon, h; translate = true)

    @test r_ecef_conv[1] ≈ r_ecef[1]
    @test r_ecef_conv[2] ≈ r_ecef[2] atol = 1e-9 # r_ecef[2] is 0.
    @test r_ecef_conv[3] ≈ r_ecef[3]

    r_ned = ecef_to_ned(r_ecef, lat, lon, h)
    @test norm(r_ned) == norm(r_ecef)

    B_l = SVector(24178.985570422887, -39579.98354881559, -14897.692106044478)

    # This is a validated code that rotates NED to ECEF without translations.
    D_ecef_l   = angle_to_dcm(lat, -lon, 0, :YZX)
    B_ecef_exp = D_ecef_l * SVector(-B_l[3], +B_l[2], +B_l[1])
    B_ecef     = ned_to_ecef(B_l, lat, lon, h)

    @test B_ecef[1] ≈ B_ecef_exp[1]
    @test B_ecef[2] ≈ B_ecef_exp[2]
    @test B_ecef[3] ≈ B_ecef_exp[3]
end

@testset "ECEF/NED direct rotation equivalence and round trips" begin
    for (lat, lon) in ((-1.1, -2.4), (0.0, 0.0), (0.5, 0.44), (1.1, 2.4))
        r_ecef = SVector(1.2, -3.4, 5.6)
        r_ned = SVector(-7.8, 9.0, -1.2)

        # Keep the previous Euler construction as an independent reference.
        d_ned_ecef = angle_to_dcm(lon, -(lat + π / 2), 0.0, :ZYX)
        d_ecef_ned = angle_to_dcm(0.0, lat + π / 2, -lon, :XYZ)

        @test ecef_to_ned(r_ecef, lat, lon, 0.0) ≈ d_ned_ecef * r_ecef
        @test ned_to_ecef(r_ned, lat, lon, 0.0) ≈ d_ecef_ned * r_ned
        @test ned_to_ecef(ecef_to_ned(r_ecef, lat, lon, 0.0), lat, lon, 0.0) ≈ r_ecef
        @test ecef_to_ned(ned_to_ecef(r_ned, lat, lon, 0.0), lat, lon, 0.0) ≈ r_ned
    end
end

@testset "ECEF/NED rotation allocations" begin
    r = SVector(1.0, 2.0, 3.0)
    # Warm up compilation before measuring the steady-state allocation count.
    ecef_to_ned(r, 0.5, 0.44, 0.0)
    ned_to_ecef(r, 0.5, 0.44, 0.0)

    @test @allocated(ecef_to_ned(r, 0.5, 0.44, 0.0)) == 0
    @test @allocated(ned_to_ecef(r, 0.5, 0.44, 0.0)) == 0
end
