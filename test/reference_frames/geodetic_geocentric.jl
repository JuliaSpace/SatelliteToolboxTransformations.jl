## Description #############################################################################
#
# Tests related to the transformations between Geodetic and Geocentric frames.
#
## References ##############################################################################
#
# [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm Press,
#     Hawthorn, CA, USA.
#
############################################################################################

# == File: ./src/reference_frames/geodetic_geocentric.jl ===================================

# -- Function: ecef_to_geocentric ----------------------------------------------------------

@testset "Function ecef_to_geocentric" begin
    @test_throws DomainError ecef_to_geocentric([0.0, 0.0, 0.0])

    for T in (Float64, Float32)
        R₀ = T(7000e3)

        lat, lon, r = ecef_to_geocentric([R₀, 0, R₀])
        @test lat ≈ deg2rad(45)
        @test lon ≈ deg2rad(0)
        @test r   ≈ √2 * R₀
        @test typeof(lat) === T
        @test typeof(lon) === T
        @test typeof(r)   === T

        lat, lon, r = ecef_to_geocentric([R₀, 0, -R₀])
        @test lat ≈ deg2rad(-45)
        @test lon ≈ deg2rad(0)
        @test r   ≈ √2 * R₀
        @test typeof(lat) === T
        @test typeof(lon) === T
        @test typeof(r)   === T

        lat, lon, r = ecef_to_geocentric([-R₀, 0, R₀])
        @test lat ≈ deg2rad(45)
        @test lon ≈ deg2rad(180)
        @test r   ≈ √2 * R₀
        @test typeof(lat) === T
        @test typeof(lon) === T
        @test typeof(r)   === T

        lat, lon, r = ecef_to_geocentric([-R₀, 0, -R₀])
        @test lat ≈ deg2rad(-45)
        @test lon ≈ deg2rad(180)
        @test r   ≈ √2 * R₀
        @test typeof(lat) === T
        @test typeof(lon) === T
        @test typeof(r)   === T

        lat, lon, r = ecef_to_geocentric([R₀, R₀, 0])
        @test lat ≈ deg2rad(0)
        @test lon ≈ deg2rad(45)
        @test r   ≈ √2 * R₀
        @test typeof(lat) === T
        @test typeof(lon) === T
        @test typeof(r)   === T

        lat, lon, r = ecef_to_geocentric([-R₀, R₀, 0])
        @test lat ≈ deg2rad(0)
        @test lon ≈ deg2rad(135)
        @test r   ≈ √2 * R₀
        @test typeof(lat) === T
        @test typeof(lon) === T
        @test typeof(r)   === T

        lat, lon, r = ecef_to_geocentric([-R₀, -R₀, 0])
        @test lat ≈ deg2rad(0)
        @test lon ≈ deg2rad(-135)
        @test r   ≈ √2 * R₀
        @test typeof(lat) === T
        @test typeof(lon) === T
        @test typeof(r)   === T

        lat, lon, r = ecef_to_geocentric([R₀, -R₀, 0])
        @test lat ≈ deg2rad(0)
        @test lon ≈ deg2rad(-45)
        @test r   ≈ √2 * R₀
        @test typeof(lat) === T
        @test typeof(lon) === T
        @test typeof(r)   === T
    end
end

# -- Function: geocentric_to_ecef ----------------------------------------------------------

@testset "Function geocentric_to_ecef" verbose = true begin
    for T in (Float64, Float32)
        @testset "Type: $T" begin
            R₀ = T(7000e3)

            lat = deg2rad(T(45))
            lon = deg2rad(T(0))
            r   = T(R₀ * √2)
            R   = geocentric_to_ecef(lat, lon, r)
            @test R[1] ≈ R₀
            @test R[2] ≈ 0
            @test R[3] ≈ R₀
            @test eltype(R) === T

            lat = deg2rad(T(-45))
            lon = deg2rad(T(0))
            r   = T(R₀ * √2)
            R   = geocentric_to_ecef(lat, lon, r)
            @test R[1] ≈ R₀
            @test R[2] ≈ 0
            @test R[3] ≈ -R₀
            @test eltype(R) === T

            lat = deg2rad(T(45))
            lon = deg2rad(T(180))
            r   = T(R₀ * √2)
            R   = geocentric_to_ecef(lat, lon, r)
            @test R[1] ≈ -R₀
            @test R[2] ≈ 0 atol = (T == Float64 ? 1e-9 : 1)
            @test R[3] ≈ R₀
            @test eltype(R) === T

            lat = deg2rad(T(-45))
            lon = deg2rad(T(180))
            r   = T(R₀ * √2)
            R   = geocentric_to_ecef(lat, lon, r)
            @test R[1] ≈ -R₀
            @test R[2] ≈ 0 atol = (T == Float64 ? 1e-9 : 1)
            @test R[3] ≈ -R₀
            @test eltype(R) === T

            lat = deg2rad(T(0))
            lon = deg2rad(T(45))
            r   = T(R₀ * √2)
            R   = geocentric_to_ecef(lat, lon, r)
            @test R[1] ≈ R₀
            @test R[2] ≈ R₀
            @test R[3] ≈ 0
            @test eltype(R) === T

            lat = deg2rad(T(0))
            lon = deg2rad(T(135))
            r   = T(R₀ * √2)
            R   = geocentric_to_ecef(lat, lon, r)
            @test R[1] ≈ -R₀
            @test R[2] ≈ R₀
            @test R[3] ≈ 0
            @test eltype(R) === T

            lat = deg2rad(T(0))
            lon = deg2rad(T(-135))
            r   = T(R₀ * √2)
            R   = geocentric_to_ecef(lat, lon, r)
            @test R[1] ≈ -R₀
            @test R[2] ≈ -R₀
            @test R[3] ≈ 0
            @test eltype(R) === T

            lat = deg2rad(T(0))
            lon = deg2rad(T(-45))
            r   = T(R₀ * √2)
            R   = geocentric_to_ecef(lat, lon, r)
            @test R[1] ≈ R₀
            @test R[2] ≈ -R₀
            @test R[3] ≈ 0
            @test eltype(R) === T
        end
    end

    @testset "Type: Integer" begin
        R = geocentric_to_ecef(0, 0, 1000)

        @test R[1] ≈ 1000
        @test R[2] ≈ 0
        @test R[3] ≈ 0
        @test eltype(R) === float(Int)
    end
end

# -- Function: ecef_to_geodetic ------------------------------------------------------------

############################################################################################
#                                       Test Results                                       #
############################################################################################
#
# == Scenario 01 ===========================================================================
#
# Example 3-3: Converting ECEF to Lat Lon [1, p. 173].
#
# According to this example, using:
#
#   r_ecef = 6524.834 i + 6862.875 j + 6448.296 k [km]
#
# one gets:
#
#   Geodetic Latitude  = 34.352496°
#            Longitude = 46.4464°
#            Altitude  = 5085.22 km
#
# == Scenario 02 ===========================================================================
#
# At the poles, we have a singularity. We know that, if:
#
#   r_ecef = 0 i + 0 j + Z k
#
# then
#
#   Geodetic Latitude  = 90° for Z > 0 and -90° for Z < 0
#            Longitude =  0°
#            Altitude  = Z - b_wgs84
#
############################################################################################

@testset "Function ecef_to_geodetic" begin
    R0 = 6378137.0

    @test_throws DomainError ecef_to_geodetic([0.0, 0.0, 0.0])

    # Float32 coordinates are promoted with the default Float64 ellipsoid consistently
    # in each of the explicit and closed-form branches.
    for r in ([Float32(1), 0f0, 0f0],
              [0f0, 0f0, Float32(R0 + 1000)],
              [Float32(6524.834e3), Float32(6862.875e3), Float32(6448.296e3)])
        ϕ_gd, λ_gd, h = ecef_to_geodetic(r)
        @test typeof(ϕ_gd) === Float64
        @test typeof(λ_gd) === Float64
        @test typeof(h) === Float64
    end

    ϕ_gd, λ_gd, h = ecef_to_geodetic(Float32[1, 0, 0])
    @test ϕ_gd == 0
    @test λ_gd == 0
    @test h ≈ 1 - WGS84_ELLIPSOID.a

    ϕ_gd, λ_gd, h = ecef_to_geodetic(Float32[0, 0, R0 + 1000])
    @test ϕ_gd ≈ π / 2
    @test λ_gd == 0
    @test h ≈ R0 + 1000 - WGS84_ELLIPSOID.b

    ϕ_gd, λ_gd, h = ecef_to_geodetic(Float32[6524.834e3, 6862.875e3, 6448.296e3])
    @test rad2deg(ϕ_gd) ≈ 34.352496 atol = 1e-4
    @test rad2deg(λ_gd) ≈ 46.4464 atol = 1e-4
    @test h / 1000 ≈ 5085.22 atol = 1e-2

    # Inside the inner evolute, the closed-form atan can select a polar branch on the
    # equator.  The equatorial convention must remain stable across that region.
    for p in (1.0, 0.5 * WGS84_ELLIPSOID.e² * WGS84_ELLIPSOID.a,
              2.0 * WGS84_ELLIPSOID.e² * WGS84_ELLIPSOID.a)
        for z in (0.0, -0.0)
            ϕ_gd, λ_gd, h = ecef_to_geodetic([p, 0.0, z])
            @test ϕ_gd == z
            @test λ_gd == 0
            @test h ≈ p - WGS84_ELLIPSOID.a
        end
    end

    # The same branch is continuous through the equator in longitude.
    ϕ₊, λ₊, h₊ = ecef_to_geodetic([1.0, 1.0, 0.0])
    ϕ₋, λ₋, h₋ = ecef_to_geodetic([-1.0, -1.0, -0.0])
    @test ϕ₊ == ϕ₋ == 0
    @test λ₊ ≈ π / 4
    @test λ₋ ≈ -3π / 4
    @test h₊ ≈ h₋ ≈ hypot(1.0, 1.0) - WGS84_ELLIPSOID.a

    # The polar limit has a defined latitude and height, but no longitude.
    for Z in (R0 + 1000, -(R0 + 1000))
        ϕ_gd, λ_gd, h = ecef_to_geodetic([0.0, 0.0, Z])
        @test ϕ_gd ≈ copysign(π / 2, Z)
        @test λ_gd == 0
        @test h ≈ abs(Z) - WGS84_ELLIPSOID.b
    end

    # == Scenario 01 =======================================================================

    r = [6524.834e3, 6862.875e3, 6448.296e3]

    ϕ_gd, λ_gd, h = ecef_to_geodetic(r)

    @test rad2deg(ϕ_gd) ≈ 34.352496 atol = 1e-6
    @test rad2deg(λ_gd) ≈ 46.4464   atol = 1e-4
    @test h/1000        ≈ 5085.22   atol = 1e-2

    # == Scenario 02 =======================================================================

    aux = rand(0:1000)

    Z = R0 + aux
    ϕ_gd, λ_gd, h = ecef_to_geodetic([0;0;Z])

    @test rad2deg(ϕ_gd) ≈ 90
    @test rad2deg(λ_gd) ≈ 0
    @test h             ≈ Z - WGS84_ELLIPSOID.b

    Z = -R0 + aux
    ϕ_gd, λ_gd, h = ecef_to_geodetic([0;0;Z])

    @test rad2deg(ϕ_gd) ≈ -90
    @test rad2deg(λ_gd) ≈ 0
    @test h             ≈ -Z - WGS84_ELLIPSOID.b

    # Round trips representative of LEO and GEO should retain both latitude and
    # altitude after conversion through ECEF.
    for (lat, lon, h) in ((deg2rad(51.6), deg2rad(-73.2), 400e3),
                          (deg2rad(-12.5), deg2rad(141.0), 35_786e3))
        r_ecef = geodetic_to_ecef(lat, lon, h)
        lat′, lon′, h′ = ecef_to_geodetic(r_ecef)
        @test lat′ ≈ lat atol = 2e-14
        @test lon′ ≈ lon atol = 2e-14
        @test h′ ≈ h atol = 1e-6
    end

    # Below-ellipsoid positions are valid and must retain their signed height.
    lat, lon, h = deg2rad(35), deg2rad(20), -6.0e6
    lat′, lon′, h′ = ecef_to_geodetic(geodetic_to_ecef(lat, lon, h))
    @test lat′ ≈ lat atol = 2e-14
    @test lon′ ≈ lon atol = 2e-14
    @test h′ ≈ h atol = 1e-6
end

############################################################################################
#                                       Test Results                                       #
############################################################################################
#
# Using the FORTRAN code available in:
#
#   https://www.astro.uni.torun.pl/~kb/Papers/geod/Geod-BG.htm
#
# we obtained the following matrix of data:
#
# | Geocentric lat [rad] | Distance [m] | Geodetic lat [rad]   | Altitude [m]        |
# |----------------------|--------------|----------------------|---------------------|
# |  19.86               | R0 + 1987    |  1.0134554245512695  | 17352.756962650223  |
# |  π/2                 | R0 + 190686  |  1.5707963267948966  | 212070.68575482070  |
# |  31.35 * π/180       | R0 + 752000  |  0.54808101129276687 | 757773.37237201189  |
# | -19.86               | R0 + 1987    | -1.0134554245512695  | 17352.756962650223  |
# | -π/2                 | R0 + 190686  | -1.5707963267948966  | 212070.68575482070  |
# | -31.35 * π/180       | R0 + 752000  | -0.54808101129276687 | 757773.37237201189  |
# |  0                   | R0           |  0.0000000000000000  | 0.0000000000000000  |
# |  15                  | 10000        |  1.3567978765139961  | -6353137.8454352869 |
# | -15                  | 10000        | -1.3567978765139961  | -6353137.8454352869 |
#
############################################################################################
#
# == FORTRAN code used to obtain the results ===============================================
#
#      subroutine GEOD(r,z,fi,h)
#          implicit real*8(a-h,o-z)
#          data a,frec /6378137.d0,298.257223563d0/
#          b=dsign(a-a/frec,z)
#          if(r.eq.0d0) return
#          E=((z+b)*b/a-a)/r
#          F=((z-b)*b/a+a)/r
#          P=(E*F+1.)*4d0/3.
#          Q=(E*E-F*F)*2.
#          D=P*P*P+Q*Q
#          if(D.ge.0d0) then
#              s=dsqrt(D)+Q
#              s=dsign(dexp(dlog(dabs(s))/3d0),s)
#              v=P/s-s
#              v=-(Q+Q+v*v*v)/(3*P)
#          else
#              v=2.*dsqrt(-P)*dcos(dacos(Q/P/dsqrt(-P))/3.)
#          endif
#          G=.5*(E+dsqrt(E*E+v))
#          t=dsqrt(G*G+(F-v*G)/(G+G-E))-G
#          fi=datan((1.-t*t)*a/(2*b*t))
#          h=(r-a*t)*dcos(fi)+(z-b)*dsin(fi)
#          end
#
#      program TEST
#          implicit real*8(a-h,o-z)
#          R0 = 6378137.d0
#          PI = 4 * atan(1.d0)
#
#          dlat = 19.86d0
#          r    = R0 + 1987.d0
#          call GEOD(r * dcos(dlat), r * dsin(dlat), fi, h)
#          PRINT *, fi, h
#
#          dlat = 90.00d0 * PI / 180.d0
#          r    = R0 + 190686.d0
#          call GEOD(r * dcos(dlat), r * dsin(dlat), fi, h)
#          PRINT *, fi, h
#
#          dlat = 31.25d0 * PI / 180.d0
#          r    = R0 + 752000.d0
#          call GEOD(r * dcos(dlat), r * dsin(dlat), fi, h)
#          PRINT *, fi, h
#
#          dlat = -19.86d0
#          r    = R0 + 1987.d0
#          call GEOD(r * dcos(dlat), r * dsin(dlat), fi, h)
#          PRINT *, fi, h
#
#          dlat = -90.00d0 * PI / 180.d0
#          r    = R0 + 190686.d0
#          call GEOD(r * dcos(dlat), r * dsin(dlat), fi, h)
#          PRINT *, fi, h
#
#          dlat = -31.25d0 * PI / 180.d0
#          r    = R0 + 752000.d0
#          call GEOD(r * dcos(dlat), r * dsin(dlat), fi, h)
#          PRINT *, fi, h
#
#          dlat = 0.d0
#          r    = R0
#          call GEOD(r * dcos(dlat), r * dsin(dlat), fi, h)
#          PRINT *, fi, h
#
#          dlat = 15.d0 * PI / 180.d0
#          r    = 10000.d0
#          call GEOD(r * dcos(dlat), r * dsin(dlat), fi, h)
#          PRINT *, fi, h
#
#          dlat = -15.d0 * PI / 180.d0
#          r    = 10000.d0
#          call GEOD(r * dcos(dlat), r * dsin(dlat), fi, h)
#          PRINT *, fi, h
#      end program
#
############################################################################################

# -- Function: geocentric_to_geodetic and geodetic_to_geocentric ---------------------------

@testset "Function geocentric_to_geodetic" begin
    R0 = 6378137.0

    # == North Hemisphere ==================================================================

    ϕ_gd, h = geocentric_to_geodetic(19.86, R0 + 1987)
    @test ϕ_gd ≈ 1.0134554245512695
    @test h    ≈ 17352.756962650223

    ϕ_gd, h = geocentric_to_geodetic(π/2, R0 + 190686)
    @test ϕ_gd ≈ 1.5707963267948966
    @test h    ≈ 212070.68575482070

    ϕ_gd, h = geocentric_to_geodetic(deg2rad(31.25), R0 + 752000)
    @test ϕ_gd ≈ 0.54808101129276687
    @test h    ≈ 757773.37237201189

    # == South Hemisphere ==================================================================

    ϕ_gd, h = geocentric_to_geodetic(-19.86, R0 + 1987)
    @test ϕ_gd ≈ -1.0134554245512695
    @test h    ≈ 17352.756962650223

    ϕ_gd, h = geocentric_to_geodetic(-π/2, R0 + 190686)
    @test ϕ_gd ≈ -1.5707963267948966
    @test h    ≈ 212070.68575482070

    ϕ_gd, h = geocentric_to_geodetic(-deg2rad(31.25), R0 + 752000)
    @test ϕ_gd ≈ -0.54808101129276687
    @test h    ≈ 757773.37237201189

    # == Special Cases =====================================================================

    ϕ_gd, h = geocentric_to_geodetic(0, R0)
    @test ϕ_gd ≈ 0.0
    @test h    ≈ 0.0

    # D < 0
    ϕ_gd, h = geocentric_to_geodetic(deg2rad(15), 10e3)
    @test ϕ_gd ≈ 1.3567978765139961
    @test h    ≈ -6353137.8454352869

    ϕ_gd, h = geocentric_to_geodetic(-deg2rad(15), 10e3)
    @test ϕ_gd ≈ -1.3567978765139961
    @test h    ≈ -6353137.8454352869

    # == Polar Axis ========================================================================
    #
    # The equatorial component vanishes on the polar axis, where the algorithm in the
    # reference divides by zero. The geodetic solution is exact there.

    b = 6356752.314245179

    ϕ_gd, h = geocentric_to_geodetic(0.0, 0.0)
    @test ϕ_gd ≈ +π / 2
    @test h    ≈ -b

    # `cos(Float32(π) / 2)` is negative, so the equatorial component is negative and the
    # algorithm in the reference used to throw a `DomainError` from inside `sqrt`.
    ϕ_gd, h = geocentric_to_geodetic(Float32(π) / 2, 6378137.0f0)
    @test ϕ_gd ≈ +π / 2
    @test h    ≈ 6378137.0 - b rtol = 1e-6

    ϕ_gd, h = geocentric_to_geodetic(-Float32(π) / 2, 6378137.0f0)
    @test ϕ_gd ≈ -π / 2
    @test h    ≈ 6378137.0 - b rtol = 1e-6

    # The result must remain continuous when approaching the axis from within the domain.
    ϕ_gd, h = geocentric_to_geodetic(π / 2 - 1e-12, 6378137.0)
    @test ϕ_gd ≈ +π / 2   atol = 1e-6
    @test h    ≈ 6378137.0 - b rtol = 1e-9
end

@testset "Function geodetic_to_geocentric" begin
    R0 = 6378137.0

    # == North Hemisphere ==================================================================

    ϕ_gc, r = geodetic_to_geocentric(1.0134554245512695, 17352.756962650223)
    @test ϕ_gc ≈ mod(19.86, 2π)
    @test r    ≈ R0 + 1987

    ϕ_gc, r = geodetic_to_geocentric(1.5707963267948966, 212070.68575482070)
    @test ϕ_gc ≈ π/2
    @test r    ≈ R0 + 190686

    ϕ_gc, r = geodetic_to_geocentric(0.54808101129276687, 757773.37237201189)
    @test ϕ_gc ≈ deg2rad(31.25)
    @test r    ≈ R0 + 752000

    # == South Hemisphere ==================================================================

    ϕ_gc, r = geodetic_to_geocentric(-1.0134554245512695, 17352.756962650223)
    @test ϕ_gc ≈ -mod(19.86, 2π)
    @test r    ≈ R0 + 1987

    ϕ_gc, r = geodetic_to_geocentric(-1.5707963267948966, 212070.68575482070)
    @test ϕ_gc ≈ -π/2
    @test r    ≈ R0 + 190686

    ϕ_gc, r = geodetic_to_geocentric(-0.54808101129276687, 757773.37237201189)
    @test ϕ_gc ≈ -deg2rad(31.25)
    @test r    ≈ R0 + 752000

    # == Special Cases =====================================================================

    ϕ_gc, r = geodetic_to_geocentric(0.0, 0.0)
    @test ϕ_gc ≈ 0
    @test r    ≈ R0

    # D < 0
    ϕ_gc, r = geodetic_to_geocentric(1.3567978765139961, -6353137.8454352869)
    @test ϕ_gc ≈ deg2rad(15)
    @test r    ≈ 10e3

    ϕ_gc, r = geodetic_to_geocentric(-1.3567978765139961, -6353137.8454352869)
    @test ϕ_gc ≈ -deg2rad(15)
    @test r    ≈ 10e3
end
