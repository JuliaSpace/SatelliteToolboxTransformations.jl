## Description #############################################################################
#
#  Coordinate transformations related with the geodetic and geocentric coordinates.
#
## References ##############################################################################
#
# [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications.  Microcosm
#     Press, Hawthorn, CA, USA.
#
# [2] ESA Navipedia: http://www.navipedia.net/
#
# [3] mu-blox ag (1999). Datum Transformations of GPS Positions. Application Note.
#
# [4] ISO TC 20/SC 14 N (2011). Geomagnetic Reference Models.
#
# [5] Borkowski, K. M (1987). Transformation of geocentric to geodetic coordinates without
#     approximations. Astrophysics and Space Science, vol.  139, pp. 1-4.
#
############################################################################################

export ecef_to_geocentric, geocentric_to_ecef
export ecef_to_geodetic, geodetic_to_ecef
export geocentric_to_geodetic, geodetic_to_geocentric

"""
    ecef_to_geocentric(r_e::AbstractVector{T}) -> NTuple{3, float(T)}

Convert the vector `r_e` represented in the Earth-Centered, Earth-Fixed (ECEF) reference
frame into geocentric coordinates (geocentric latitude, longitude, and distance from Earth's
center).

# Returns

- `SVector`: The Geocentric state: [Geocentric latitude [rad] ∈ [-π / 2, π / 2], Longitude [rad] ∈ [-π , π], Distance from Earth's center [m]].
"""
function ecef_to_geocentric(r_e::AbstractVector)

    # Auxiliary variables.
    x  = r_e[1]
    y  = r_e[2]
    z  = r_e[3]
    x² = x^2
    y² = y^2
    z² = z^2

    lat = atan(z, √(x² + y²))
    lon = atan(y, x)
    r   = √(x² + y² + z²)

    return lat, lon, r
end

"""
    geocentric_to_ecef(lat::Number, lon::Number, r::Number) -> SVector{3, T}

Convert the geocentric coordinates (latitude `lat` [rad], longitude `lon` [rad], and
distance from Earth's center `r` [m]) into a Earth-Centered, Earth-Fixed vector [m].

!!! note
    The output type `T` is obtained by promoting the input types `T1`, `T2`, and `T3` to
    float.
"""
function geocentric_to_ecef(lat::T1, lon::T2, r::T3) where {T1<:Number, T2<:Number, T3<:Number}
    T = promote_type(T1, T2, T3)

    # Compute the vector at Earth's center that points to the desired geocentric point.
    sin_lon, cos_lon = sincos(lon)
    sin_lat, cos_lat = sincos(lat)

    r_ecef = SVector{3, T}(
        r * cos_lat * cos_lon,
        r * cos_lat * sin_lon,
        r * sin_lat
    )

    return r_ecef
end

"""
    geocentric_to_ecef(geocentric_state::AbstractVector) -> SVector{3, T}

Convert the geocentric coordinates (latitude `lat` [rad], longitude `lon` [rad], and
distance from Earth's center `r` [m]) into a Earth-Centered, Earth-Fixed vector [m].
"""
function geocentric_to_ecef(geocentric_state::AbstractVector)
    return geocentric_to_ecef(geocentric_state...)
end

"""
    ecef_to_geodetic(r_e::AbstractVector; ellipsoid::Ellipsoid{T} = WGS84_ELLIPSOID) where T<:Number -> NTuple{3, T}

Convert the vector `r_e` [m] represented in the Earth-Centered, Earth-Fixed (ECEF) reference
frame into Geodetic coordinates for a custom target ellipsoid (defaults to WGS-84).

!!! info

    The algorithm is based in **[1]**.

# Returns

- `SVector`: The Geodetic State: [Latitude [rad], Longitude [rad], Altitude [m]]

# Reference

- **[1]**: mu-blox ag (1999). Datum Transformations of GPS Positions. Application Note.
"""
function ecef_to_geodetic(
    r_e::AbstractVector;
    ellipsoid::Ellipsoid{T} = WGS84_ELLIPSOID
) where {T<:Number}

    # Auxiliary variables.
    x = r_e[1]
    y = r_e[2]
    z = r_e[3]

    # Auxiliary variables.
    a   = ellipsoid.a
    b   = ellipsoid.b
    e²  = ellipsoid.e²
    el² = ellipsoid.el²
    p   = √(x^2 + y^2)
    θ   = atan(z * a, p * b)

    sin_θ, cos_θ = sincos(θ)

    # Compute Geodetic.
    lon = atan(y, x)
    lat = atan(z + el² * b * sin_θ^3, p -  e² * a * cos_θ^3)

    sin_lat, cos_lat = sincos(lat)

    N = a / √(1 - e² * sin_lat^2)

    # Avoid singularity if we are near the poles (~ 1 deg according to [1, p.172]). Note
    # that `cosd(1) = -0.01745240643728351`.
    if !(-0.01745240643728351 < cos_lat < 0.01745240643728351)
        h = p / cos_lat - N
    else
        h = z / sin_lat - N * (1 - e²)
    end

    return lat, lon, h
end

"""
    geodetic_to_ecef(lat::Number, lon::Number, h::Number; ellipsoid::Ellipsoid{T} = wgs84_ellipsoid) where T<:Number -> SVector{3, T}

Convert the latitude `lat` [rad], longitude `lon` [rad], and altitude `h` \\[m] above the
reference ellipsoid (defaults to WGS-84) into a vector represented on the Earth-Centered,
Earth-Fixed (ECEF) reference frame.

!!! info

    The algorithm is based in **[1]**.

# Reference

- **[1]**: mu-blox ag (1999). Datum Transformations of GPS Positions. Application Note.
"""
function geodetic_to_ecef(
    lat::Number,
    lon::Number,
    h::Number;
    ellipsoid::Ellipsoid{T} = WGS84_ELLIPSOID
) where T<:Number
    # Auxiliary variables.
    sin_lat, cos_lat = sincos(lat)
    sin_lon, cos_lon = sincos(lon)

    a  = ellipsoid.a
    b  = ellipsoid.b
    e² = ellipsoid.e²

    # Radius of curvature [m].
    N = a / √(1 - e² * sin_lat^2)

    # Compute the position in ECEF frame.
    return SVector(
        (            N + h) * cos_lat * cos_lon,
        (            N + h) * cos_lat * sin_lon,
        ((b / a)^2 * N + h) * sin_lat
    )
end

"""
    geodetic_to_ecef(geodetic_state::AbstractVector; ellipsoid::Ellipsoid{T} = wgs84_ellipsoid) where T<:Number -> SVector{3, T}

Convert the latitude `lat` [rad], longitude `lon` [rad], and altitude `h` \\[m] above the
reference ellipsoid (defaults to WGS-84) into a vector represented on the Earth-Centered,
Earth-Fixed (ECEF) reference frame.

!!! info

    The algorithm is based in **[1]**.

# Reference

- **[1]**: mu-blox ag (1999). Datum Transformations of GPS Positions. Application Note.
"""
function geodetic_to_ecef(
    geodetic_state::AbstractVector;
    ellipsoid::Ellipsoid{T} = WGS84_ELLIPSOID
) where T<:Number

    return geodetic_to_ecef(geodetic_state...; ellipsoid=ellipsoid)

end

"""
    geocentric_to_geodetic(ϕ_gc::Number, r::Number; ellipsoid::Ellipsoid{T} = WGS84_ELLIPSOID) where T<:Number -> T, T

Compute the geodetic latitude and altitude above the reference ellipsoid (defaults to
WGS-84) from the geocentric latitude `ϕ_gc` (-π/2, π/2) [rad] and radius `r` [m].  Notice
that the longitude is the same in both geocentric and geodetic coordinates.

!!! info

    The algorithm is based in **[1]**.

# Returns

- `SVector`: The Geodetic State [Geodetic latitude [rad], Altitude above the reference ellipsoid (defaults to WGS-84) [m]].

# References

- **[1]** Borkowski, K. M (1987). Transformation of geocentric to geodetic coordinates
    without approximations. Astrophysics and Space Science, vol.  139, pp. 1-4.
"""
function geocentric_to_geodetic(
    ϕ_gc::Number,
    r::Number;
    ellipsoid::Ellipsoid{T} = WGS84_ELLIPSOID
) where T<:Number
    # Obtain the `z` component and the equatorial component `re`.
    sin_ϕ_gc, cos_ϕ_gc = sincos(ϕ_gc)

    re = r * cos_ϕ_gc
    z  = r * sin_ϕ_gc

    sign_z = z >= 0 ? +1 : -1

    # Auxiliary variables.
    a  = ellipsoid.a
    a² = a^2
    b  = sign_z * ellipsoid.b
    b² = b^2

    # Compute the parameters.
    E  = (b * z - (a² - b²)) / (a * re)
    E² = E^2
    F  = (b * z + (a² - b²)) / (a * re)
    P  = T(4 / 3) * (E * F + 1)
    Q  = 2 * (E² - F^2)
    D  = P^3 + Q^2

    if D ≥ 0
        aux = √D
        v = (aux - Q)^T(1 / 3) - (Q + aux)^T(1 / 3)
    else
        aux = √(-P)
        v = 2 * aux * cos(acos(Q / (P * aux)) / 3)
    end

    G = (√(E² + v) + E) / 2

    # NOTE: Reference [5] appears to have an error in Eq. (13), where we must have G^2
    # instead of G inside the square root. The correct version can be seen here:
    #
    #   https://www.astro.uni.torun.pl/~kb/Papers/geod/Geod-BG.htm
    #
    t = √(G^2 + (F - v * G) / (2 * G - E)) - G

    # Compute the geodetic latitude and altitude.
    ϕ_gd = atan(a * (1 - t^2)/(2b * t))
    sin_ϕ_gd, cos_ϕ_gd = sincos(ϕ_gd)
    h = (re - a * t) * cos_ϕ_gd + (z - b) * sin_ϕ_gd

    return ϕ_gd, h
end

"""
    geocentric_to_geodetic(geocentric_state::AbstractVector; ellipsoid::Ellipsoid{T} = WGS84_ELLIPSOID) where T<:Number -> T, T

Compute the geodetic latitude and altitude above the reference ellipsoid (defaults to
WGS-84) from the geocentric latitude `ϕ_gc` (-π/2, π/2) [rad] and radius `r` [m].  Notice
that the longitude is the same in both geocentric and geodetic coordinates.

!!! info

    The longitude is the same between states so the geocentric state vector only includes latitude and radius.

    The algorithm is based in **[1]**.

# Returns

- `SVector`: The Geodetic State [Geodetic latitude [rad], Altitude above the reference ellipsoid (defaults to WGS-84) [m]].

# References

- **[1]** Borkowski, K. M (1987). Transformation of geocentric to geodetic coordinates
    without approximations. Astrophysics and Space Science, vol.  139, pp. 1-4.
"""
function geocentric_to_geodetic(
    geocentric_state::AbstractVector;
    ellipsoid::Ellipsoid{T} = WGS84_ELLIPSOID
) where T<:Number

    return geocentric_to_geodetic(geocentric_state...; ellipsoid=ellipsoid)

end

"""
    geodetic_to_geocentric(ϕ_gd::Number, h::Number; ellipsoid::Ellipsoid{T} = WGS84_ELLIPSOID) where T<:Number -> T, T

Compute the geocentric latitude and radius from the geodetic latitude `ϕ_gd` (-π/2, π/2)
[rad] and height above the reference ellipsoid `h` \\[m] (defaults to WGS-84).  Notice that
the longitude is the same in both geocentric and geodetic coordinates.

!!! info
    The algorithm is based in **[1]**(p. 3).

# Returns

- `SVector`: The Geocentric State [Geocentric latitude [rad]; Radius from the center of the Earth [m]].

# References

- **[1]** ISO TC 20/SC 14 N (2011). Geomagnetic Reference Models.
"""
function geodetic_to_geocentric(
    ϕ_gd::Number,
    h::Number;
    ellipsoid::Ellipsoid{T} = WGS84_ELLIPSOID
) where T<:Number
    # Auxiliary variables to decrease computational burden.
    sin_ϕ_gd, cos_ϕ_gd = sincos(ϕ_gd)
    sin²_ϕ_gd = sin_ϕ_gd^2

    a  = ellipsoid.a
    e² = ellipsoid.e²

    # Radius of curvature in the prime vertical [m].
    N = a / √(1 - e² * sin²_ϕ_gd )

    # Compute the geocentric latitude and radius from the Earth center.
    ρ    = (N + h) * cos_ϕ_gd
    z    = (N * (1 - e²) + h) * sin_ϕ_gd
    r    = √(ρ^2 + z^2)
    ϕ_gc = asin(z / r)

    return ϕ_gc, r
end

"""
    geodetic_to_geocentric(geodetic_state::AbstractVector; ellipsoid::Ellipsoid{T} = WGS84_ELLIPSOID) where T<:Number -> T, T

Compute the geocentric latitude and radius from the geodetic latitude `ϕ_gd` (-π/2, π/2)
[rad] and height above the reference ellipsoid `h` \\[m] (defaults to WGS-84).  Notice that
the longitude is the same in both geocentric and geodetic coordinates.

!!! info

    The longitude is the same between states so the geocentric state vector only includes latitude and radius.

    The algorithm is based in **[1]**(p. 3).

# Returns

- `SVector`: The Geocentric State [Geocentric latitude [rad]; Radius from the center of the Earth [m]].

# References

- **[1]** ISO TC 20/SC 14 N (2011). Geomagnetic Reference Models.
"""
function geodetic_to_geocentric(
    geodetic_state::AbstractVector;
    ellipsoid::Ellipsoid{T} = WGS84_ELLIPSOID
) where T<:Number

    return geodetic_to_geocentric(geodetic_state...; ellipsoid=ellipsoid)
end