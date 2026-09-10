## Description #############################################################################
#
# Tests related to the transformations of local reference frames.
#
############################################################################################

# == File: ./src/reference_frames/local_frame.jl ===========================================

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

# -- Functions: r_eci_to_hill, r_hill_to_eci, r_eci_to_lvlh, and r_lvlh_to_eci --------------

# The tests use two states:
#
#   1. A circular, inclined orbit, in which `r` ⟂ `v` and the Hill frame is the rotation of
#      the inclination about the X-axis; and
#   2. An eccentric state with a closed-form triad:
#
#        r̄ = (0.6, 0.8, 0),  h̄ = (0.8, -0.6, 1) / √2,  θ̄ = (-0.8, 0.6, 1) / √2.

@testset "Functions r_eci_to_hill and r_hill_to_eci" begin
    inc        = 0.5
    r_circ_eci = SVector(7000e3, 0.0, 0.0)
    v_circ_eci = 7.5e3 * SVector(0.0, cos(inc), sin(inc))
    r_ecc_eci  = SVector(3e6, 4e6, 0.0)
    v_ecc_eci  = SVector(-1e3, 2e3, 2e3)

    for (r_eci, v_eci) in ((r_circ_eci, v_circ_eci), (r_ecc_eci, v_ecc_eci))
        # Independent construction of the expected axes.
        r̄_eci = normalize(r_eci)
        h̄_eci = normalize(r_eci × v_eci)
        θ̄_eci = h̄_eci × r̄_eci
        h_eci = r_eci × v_eci

        D_hill_eci = r_eci_to_hill(r_eci, v_eci)
        @test D_hill_eci isa DCM{Float64}
        @test D_hill_eci == r_eci_to_hill(DCM, r_eci, v_eci)

        # Orthonormality and proper rotation.
        @test D_hill_eci * D_hill_eci' ≈ I atol = 1e-14
        @test det(D_hill_eci) ≈ 1 atol = 1e-14

        # The rows are the Hill axes represented in the ECI frame.
        @test D_hill_eci[1, :] ≈ r̄_eci
        @test D_hill_eci[2, :] ≈ θ̄_eci
        @test D_hill_eci[3, :] ≈ h̄_eci

        # The position lies along +X, the velocity lies in the XY plane with a positive
        # along-track component, and the angular momentum lies along +Z.
        r_hill = D_hill_eci * r_eci
        v_hill = D_hill_eci * v_eci
        h_hill = D_hill_eci * h_eci

        @test r_hill ≈ SVector(norm(r_eci), 0, 0) atol = 1e-6
        @test v_hill[2] > 0
        @test v_hill[3] ≈ 0 atol = 1e-9
        @test h_hill ≈ SVector(0, 0, norm(h_eci)) rtol = 1e-14

        # Quaternion path.
        q_hill_eci = r_eci_to_hill(Quaternion, r_eci, v_eci)
        @test q_hill_eci isa Quaternion{Float64}
        @test vect(q_hill_eci \ r_eci * q_hill_eci) ≈ r_hill
        @test vect(q_hill_eci \ v_eci * q_hill_eci) ≈ v_hill

        # Inverse functions.
        D_eci_hill = r_hill_to_eci(r_eci, v_eci)
        @test D_eci_hill == r_hill_to_eci(DCM, r_eci, v_eci)
        @test D_eci_hill ≈ inv_rotation(D_hill_eci)
        @test D_eci_hill * r_hill ≈ r_eci

        q_eci_hill = r_hill_to_eci(Quaternion, r_eci, v_eci)
        @test q_eci_hill isa Quaternion{Float64}
        @test vect(q_eci_hill \ r_hill * q_eci_hill) ≈ r_eci

        # `OrbitStateVector` methods.
        sv = OrbitStateVector(0.0, r_eci, v_eci)
        @test r_eci_to_hill(sv) == D_hill_eci
        @test r_eci_to_hill(DCM, sv) == D_hill_eci
        @test r_eci_to_hill(Quaternion, sv) == q_hill_eci
        @test r_hill_to_eci(sv) == D_eci_hill
        @test r_hill_to_eci(DCM, sv) == D_eci_hill
        @test r_hill_to_eci(Quaternion, sv) == q_eci_hill
    end

    # Closed-form references.
    @test r_eci_to_hill(r_circ_eci, v_circ_eci) ≈ angle_to_dcm(inc, :X)

    s = 1 / √2

    #! format: off
    D_hill_eci_exp = DCM([
         0.6      0.8      0.0
        -0.8 * s  0.6 * s  1.0 * s
         0.8 * s -0.6 * s  1.0 * s
    ])
    #! format: on

    @test r_eci_to_hill(r_ecc_eci, v_ecc_eci) ≈ D_hill_eci_exp atol = 1e-12
end

@testset "Functions r_eci_to_lvlh and r_lvlh_to_eci" begin
    inc        = 0.5
    r_circ_eci = SVector(7000e3, 0.0, 0.0)
    v_circ_eci = 7.5e3 * SVector(0.0, cos(inc), sin(inc))
    r_ecc_eci  = SVector(3e6, 4e6, 0.0)
    v_ecc_eci  = SVector(-1e3, 2e3, 2e3)

    # Permutation that maps the Hill axes to the LVLH axes.
    D_lvlh_hill = DCM([0 1 0; 0 0 -1; -1 0 0])

    for (r_eci, v_eci) in ((r_circ_eci, v_circ_eci), (r_ecc_eci, v_ecc_eci))
        # Independent construction of the expected axes.
        r̄_eci = normalize(r_eci)
        h̄_eci = normalize(r_eci × v_eci)
        θ̄_eci = h̄_eci × r̄_eci
        h_eci = r_eci × v_eci

        D_lvlh_eci = r_eci_to_lvlh(r_eci, v_eci)
        @test D_lvlh_eci isa DCM{Float64}
        @test D_lvlh_eci == r_eci_to_lvlh(DCM, r_eci, v_eci)

        # Orthonormality and proper rotation. This assertion fails for the eccentric state
        # if the cross-track axis is not normalized.
        @test D_lvlh_eci * D_lvlh_eci' ≈ I atol = 1e-14
        @test det(D_lvlh_eci) ≈ 1 atol = 1e-14

        # The rows are the LVLH axes represented in the ECI frame.
        @test D_lvlh_eci[1, :] ≈ θ̄_eci
        @test D_lvlh_eci[2, :] ≈ -h̄_eci
        @test D_lvlh_eci[3, :] ≈ -r̄_eci

        # The position lies along -Z, the velocity lies in the XZ plane with a positive
        # along-track component, and the angular momentum lies along -Y.
        r_lvlh = D_lvlh_eci * r_eci
        v_lvlh = D_lvlh_eci * v_eci
        h_lvlh = D_lvlh_eci * h_eci

        @test r_lvlh ≈ SVector(0, 0, -norm(r_eci)) atol = 1e-6
        @test v_lvlh[1] > 0
        @test v_lvlh[2] ≈ 0 atol = 1e-9
        @test h_lvlh ≈ SVector(0, -norm(h_eci), 0) rtol = 1e-14

        # The LVLH frame is a permutation of the Hill frame.
        @test D_lvlh_eci ≈ D_lvlh_hill * r_eci_to_hill(r_eci, v_eci)

        # Quaternion path.
        q_lvlh_eci = r_eci_to_lvlh(Quaternion, r_eci, v_eci)
        @test q_lvlh_eci isa Quaternion{Float64}
        @test vect(q_lvlh_eci \ r_eci * q_lvlh_eci) ≈ r_lvlh
        @test vect(q_lvlh_eci \ v_eci * q_lvlh_eci) ≈ v_lvlh

        # Inverse functions.
        D_eci_lvlh = r_lvlh_to_eci(r_eci, v_eci)
        @test D_eci_lvlh == r_lvlh_to_eci(DCM, r_eci, v_eci)
        @test D_eci_lvlh ≈ inv_rotation(D_lvlh_eci)
        @test D_eci_lvlh * r_lvlh ≈ r_eci

        q_eci_lvlh = r_lvlh_to_eci(Quaternion, r_eci, v_eci)
        @test q_eci_lvlh isa Quaternion{Float64}
        @test vect(q_eci_lvlh \ r_lvlh * q_eci_lvlh) ≈ r_eci

        # `OrbitStateVector` methods.
        sv = OrbitStateVector(0.0, r_eci, v_eci)
        @test r_eci_to_lvlh(sv) == D_lvlh_eci
        @test r_eci_to_lvlh(DCM, sv) == D_lvlh_eci
        @test r_eci_to_lvlh(Quaternion, sv) == q_lvlh_eci
        @test r_lvlh_to_eci(sv) == D_eci_lvlh
        @test r_lvlh_to_eci(DCM, sv) == D_eci_lvlh
        @test r_lvlh_to_eci(Quaternion, sv) == q_eci_lvlh
    end

    # Closed-form references.
    @test r_eci_to_lvlh(r_circ_eci, v_circ_eci) ≈ D_lvlh_hill * angle_to_dcm(inc, :X)

    s = 1 / √2

    #! format: off
    D_lvlh_eci_exp = DCM([
        -0.8 * s  0.6 * s  1.0 * s
        -0.8 * s  0.6 * s -1.0 * s
        -0.6     -0.8      0.0
    ])
    #! format: on

    @test r_eci_to_lvlh(r_ecc_eci, v_ecc_eci) ≈ D_lvlh_eci_exp atol = 1e-12
end

@testset "ECI/Hill and ECI/LVLH input types" begin
    r_eci = SVector(3e6, 4e6, 0.0)
    v_eci = SVector(-1e3, 2e3, 2e3)

    for func in (r_eci_to_hill, r_hill_to_eci, r_eci_to_lvlh, r_lvlh_to_eci)
        # Float32 inputs return Float32 rotations.
        r32 = SVector{3, Float32}(r_eci)
        v32 = SVector{3, Float32}(v_eci)
        @test func(r32, v32) isa DCM{Float32}
        @test func(DCM, r32, v32) isa DCM{Float32}
        @test func(Quaternion, r32, v32) isa Quaternion{Float32}
        @test func(OrbitStateVector(0.0f0, r32, v32)) isa DCM{Float32}

        # Integer and mixed inputs promote to Float64.
        @test func([3_000_000, 4_000_000, 0], v_eci) isa DCM{Float64}
        @test func([3_000_000, 4_000_000, 0], [-1000, 2000, 2000]) isa DCM{Float64}

        # `Vector` and `SVector` inputs give the same result.
        @test func(collect(r_eci), collect(v_eci)) == func(r_eci, v_eci)
    end
end

@testset "ECI/Hill and ECI/LVLH degenerate inputs" begin
    r_eci = SVector(3e6, 4e6, 0.0)
    v_eci = SVector(-1e3, 2e3, 2e3)
    zero3 = SVector(0.0, 0.0, 0.0)

    for func in (r_eci_to_hill, r_hill_to_eci, r_eci_to_lvlh, r_lvlh_to_eci)
        @test_throws ArgumentError func(zero3, v_eci)
        @test_throws ArgumentError func(r_eci, zero3)
        @test_throws ArgumentError func(r_eci, 2 * r_eci)
        @test_throws ArgumentError func(DCM, r_eci, -r_eci)
        @test_throws ArgumentError func(Quaternion, r_eci, -r_eci)
        @test_throws ArgumentError func(OrbitStateVector(0.0, r_eci, -r_eci))
    end
end

@testset "ECI/Hill and ECI/LVLH rotation allocations" begin
    r  = SVector(3e6, 4e6, 0.0)
    v  = SVector(-1e3, 2e3, 2e3)
    rv = collect(r)
    vv = collect(v)
    sv = OrbitStateVector(0.0, r, v)

    # Warm up compilation before measuring the steady-state allocation count. The calls are
    # unrolled because a loop over the functions would introduce dynamic dispatch. The
    # methods that take the rotation type `T` are not measured here because `@allocated`
    # reports a spurious allocation for calls whose first argument is a type; they are
    # covered by AllocCheck.jl in `test/performance.jl`.
    r_eci_to_hill(r, v)
    r_eci_to_hill(DCM, r, v)
    r_eci_to_hill(Quaternion, r, v)
    r_eci_to_hill(rv, vv)
    r_eci_to_hill(sv)
    r_hill_to_eci(r, v)
    r_hill_to_eci(DCM, r, v)
    r_hill_to_eci(Quaternion, r, v)
    r_hill_to_eci(rv, vv)
    r_hill_to_eci(sv)
    r_eci_to_lvlh(r, v)
    r_eci_to_lvlh(DCM, r, v)
    r_eci_to_lvlh(Quaternion, r, v)
    r_eci_to_lvlh(rv, vv)
    r_eci_to_lvlh(sv)
    r_lvlh_to_eci(r, v)
    r_lvlh_to_eci(DCM, r, v)
    r_lvlh_to_eci(Quaternion, r, v)
    r_lvlh_to_eci(rv, vv)
    r_lvlh_to_eci(sv)

    @test @allocated(r_eci_to_hill(r, v)) == 0
    @test @allocated(r_eci_to_hill(rv, vv)) == 0
    @test @allocated(r_eci_to_hill(sv)) == 0

    @test @allocated(r_hill_to_eci(r, v)) == 0
    @test @allocated(r_hill_to_eci(rv, vv)) == 0
    @test @allocated(r_hill_to_eci(sv)) == 0

    @test @allocated(r_eci_to_lvlh(r, v)) == 0
    @test @allocated(r_eci_to_lvlh(rv, vv)) == 0
    @test @allocated(r_eci_to_lvlh(sv)) == 0

    @test @allocated(r_lvlh_to_eci(r, v)) == 0
    @test @allocated(r_lvlh_to_eci(rv, vv)) == 0
    @test @allocated(r_lvlh_to_eci(sv)) == 0
end
