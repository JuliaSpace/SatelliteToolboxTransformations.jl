## Description #############################################################################
#
# Coordinate transformations related with the geodetic and geocentric coordinates.
#
## References ##############################################################################
#
# [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. 4th ed.
#     Microcosm Press, Hawthorn, CA, USA.
#
# [2] ESA Navipedia: http://www.navipedia.net/
#
# [3] mu-blox ag (1999). Datum Transformations of GPS Positions. Application Note.
#
# [4] ISO TC 20/SC 14 N (2011). Geomagnetic Reference Models.
#
# [5] Borkowski, K. M (1987). Transformation of geocentric to geodetic coordinates without
#     approximations. Astrophysics and Space Science, vol. 139, pp. 1-4.
#
############################################################################################

export ecef_to_geocentric, geocentric_to_ecef
export ecef_to_geodetic, geodetic_to_ecef
export geocentric_to_geodetic, geodetic_to_geocentric

"""
    ecef_to_geocentric(r_e::AbstractVector{T}) -> NTuple{3, T}

Convert the vector `r_e` [m] represented in the Earth-Centered, Earth-Fixed (ECEF) reference
frame into geocentric coordinates (geocentric latitude, longitude, and distance from the
Earth's center). The function throws if `r_e` is the origin, where the latitude and the
longitude are undefined.

The returned type `T` is the floating-point promotion of `eltype(r_e)`.

# Returns

- `T`: Geocentric latitude [rad] ∈ [-π / 2, π / 2].
- `T`: Longitude [rad] ∈ [-π, π].
- `T`: Distance from the Earth's center [m].

# Extended help

## Throws

- `DomainError`: `r_e` is the null vector, for which the latitude and the longitude are
    undefined.
"""
function ecef_to_geocentric(r_e::AbstractVector)

    # Auxiliary variables.
    x = r_e[1]
    y = r_e[2]
    z = r_e[3]
    if x == 0 && y == 0 && z == 0
        throw(DomainError(r_e, "the ECEF origin has undefined latitude and longitude"))
    end

    lat = atan(z, hypot(x, y))
    lon = atan(y, x)
    r   = hypot(x, y, z)

    return lat, lon, r
end

"""
    geocentric_to_ecef(lat::Number, lon::Number, r::Number) -> SVector{3, T}

Convert the geocentric coordinates (geocentric latitude `lat` [rad], longitude `lon` [rad],
and distance from the Earth's center `r` [m]) into a vector [m] represented in the
Earth-Centered, Earth-Fixed (ECEF) reference frame.

The element type `T` is the promotion of the types of `lat`, `lon`, and `r`. If all of them
are integers, the result is converted to float.
"""
function geocentric_to_ecef(
    lat::T1, lon::T2, r::T3
) where {T1 <: Number, T2 <: Number, T3 <: Number}
    T = promote_type(T1, T2, T3)

    # Compute the vector at Earth's center that points to the desired geocentric point.
    sin_lon, cos_lon = sincos(T(lon))
    sin_lat, cos_lat = sincos(T(lat))

    r_ecef = SVector{3}(T(r) * cos_lat * cos_lon, T(r) * cos_lat * sin_lon, T(r) * sin_lat)

    return r_ecef
end

function geocentric_to_ecef(lat::Integer, lon::Integer, r::Integer)
    return geocentric_to_ecef(float(lat), float(lon), float(r))
end

"""
    geocentric_to_ecef(geocentric_state::AbstractVector) -> SVector{3, T}

Convert the geocentric coordinates in `geocentric_state` (geocentric latitude [rad],
longitude [rad], and distance from the Earth's center [m], in this order) into a vector [m]
represented in the Earth-Centered, Earth-Fixed (ECEF) reference frame.

The element type `T` is obtained as in the method that receives the coordinates as separate
arguments.
"""
function geocentric_to_ecef(geocentric_state::AbstractVector)
    return geocentric_to_ecef(geocentric_state[1], geocentric_state[2], geocentric_state[3])
end

"""
    ecef_to_geodetic(r_e::AbstractVector; kwargs...) -> NTuple{3, RT}

Convert the vector `r_e` [m] represented in the Earth-Centered, Earth-Fixed (ECEF) reference
frame into geodetic coordinates (geodetic latitude, longitude, and altitude) with respect to
the reference `ellipsoid`. The function throws if `r_e` is the origin, where the geodetic
coordinates are undefined.

The returned type `RT` is the promotion of `eltype(r_e)` and the ellipsoid parameter type
`T`.

The algorithm is based on **[3]**.

# Keywords

- `ellipsoid::Ellipsoid{T}`: Reference ellipsoid used in the conversion.
    (**Default**: `WGS84_ELLIPSOID`)

# Returns

- `RT`: Geodetic latitude [rad].
- `RT`: Longitude [rad].
- `RT`: Altitude above the reference ellipsoid [m].

# References

- **[1]** Vallado, D. A (2013). *Fundamentals of Astrodynamics and Applications*. 4th ed.
    Microcosm Press, Hawthorn, CA, USA, p. 172.
- **[3]** mu-blox ag (1999). Datum Transformations of GPS Positions. Application Note.

# Extended help

The closed-form estimate of the latitude in **[3]** is refined with a few bounded Newton
steps to keep the accuracy for high-altitude points. Points on the equator and on the polar
axis are handled explicitly, and the altitude is computed with the alternative expression
suggested in **[1]** when the point is within 1° of the poles.

## Throws

- `DomainError`: `r_e` is the null vector, for which the geodetic coordinates are
    undefined.
"""
function ecef_to_geodetic(
    r_e::AbstractVector; ellipsoid::Ellipsoid{T} = WGS84_ELLIPSOID
) where {T <: Number}

    # Promote the coordinates with the ellipsoid parameters before entering any branch.
    # This keeps all returned values at the same promoted floating-point type.
    RT = promote_type(eltype(r_e), typeof(ellipsoid.a))
    x = RT(r_e[1])
    y = RT(r_e[2])
    z = RT(r_e[3])

    if x == 0 && y == 0 && z == 0
        throw(DomainError(r_e, "the ECEF origin has undefined geodetic coordinates"))
    end

    # Auxiliary variables.
    a   = RT(ellipsoid.a)
    b   = RT(ellipsoid.b)
    e²  = RT(ellipsoid.e²)
    el² = RT(ellipsoid.el²)
    p   = hypot(x, y)

    # On the equator, atan(0, negative) in the closed-form estimate selects the wrong
    # branch for points inside the inner evolute (for example, [1, 0, 0]). The
    # conventional equatorial solution is continuous in x and y, including signed zero
    # z, and its height is the signed distance from the equatorial surface.
    if z == 0
        return copysign(zero(RT), z), atan(y, x), p - a
    end

    # The pole is the only non-origin point for which longitude and the usual height
    # expression are singular. Handle it explicitly before the closed-form estimate.
    if p == 0
        lat = copysign(RT(π / 2), z)
        return lat, zero(lat), abs(z) - b
    end

    θ = atan(z * a, p * b)

    sin_θ, cos_θ = sincos(θ)

    # Compute the longitude and the closed-form estimate of the geodetic latitude.
    lon = atan(y, x)
    lat = atan(z + el² * b * sin_θ^3, p - e² * a * cos_θ^3)

    # Refine Bowring's closed-form estimate with a few bounded Newton steps. Solving
    #
    #   p sin(lat) - z cos(lat) - e² N sin(lat) cos(lat) = 0
    #
    # avoids the loss of latitude accuracy that becomes noticeable for high-altitude
    # points, while retaining the excellent behavior of the closed-form starting value.
    for _ in 1:3
        sin_lat, cos_lat = sincos(lat)
        denominator = 1 - e² * sin_lat^2
        N = a / √(denominator)
        f = p * sin_lat - z * cos_lat - e² * N * sin_lat * cos_lat
        dN = N * e² * sin_lat * cos_lat / denominator
        df =
            p * cos_lat + z * sin_lat -
            e² * (dN * sin_lat * cos_lat + N * (cos_lat^2 - sin_lat^2))
        step = clamp(f / df, -RT(π / 4), RT(π / 4))
        lat = clamp(lat - step, -RT(π / 2), RT(π / 2))
    end

    sin_lat, cos_lat = sincos(lat)

    N = a / √(1 - e² * sin_lat^2)

    # Avoid singularity if we are near the poles (~ 1 deg according to [1, p.172]). Note
    # that `cos(89°) = sin(1°) ≈ 0.017452406437283512`, so the check excludes latitudes
    # within 1° of the poles.
    if !(-0.01745240643728351 < cos_lat < 0.01745240643728351)
        h = p / cos_lat - N
    else
        h = z / sin_lat - N * (1 - e²)
    end

    return lat, lon, h
end

"""
    geodetic_to_ecef(lat::Number, lon::Number, h::Number; kwargs...) -> SVector{3, RT}

Convert the geodetic latitude `lat` [rad], longitude `lon` [rad], and altitude `h` [m] above
the reference `ellipsoid` into a vector [m] represented in the Earth-Centered, Earth-Fixed
(ECEF) reference frame.

The element type `RT` is the promotion of the types of `lat`, `lon`, `h`, and the ellipsoid
parameter `T`.

The algorithm is based on **[3]**.

# Keywords

- `ellipsoid::Ellipsoid{T}`: Reference ellipsoid used in the conversion.
    (**Default**: `WGS84_ELLIPSOID`)

# References

- **[3]** mu-blox ag (1999). Datum Transformations of GPS Positions. Application Note.
"""
function geodetic_to_ecef(
    lat::LT, lon::LT2, h::HT; ellipsoid::Ellipsoid{T} = WGS84_ELLIPSOID
) where {LT <: Number, LT2 <: Number, HT <: Number, T <: Number}
    RT = promote_type(LT, LT2, HT, T)

    # Auxiliary variables. Everything is promoted to `RT` up front so that the returned
    # element type is `RT` regardless of the ellipsoid's own parameter type.
    sin_lat, cos_lat = sincos(RT(lat))
    sin_lon, cos_lon = sincos(RT(lon))

    a  = RT(ellipsoid.a)
    b  = RT(ellipsoid.b)
    e² = RT(ellipsoid.e²)
    hr = RT(h)

    # Radius of curvature [m].
    N = a / √(1 - e² * sin_lat^2)

    # Compute the position in ECEF frame.
    return SVector{3, RT}(
        (N + hr) * cos_lat * cos_lon,
        (N + hr) * cos_lat * sin_lon,
        ((b / a)^2 * N + hr) * sin_lat,
    )
end

"""
    geodetic_to_ecef(geodetic_state::AbstractVector; kwargs...) -> SVector{3, RT}

Convert the geodetic coordinates in `geodetic_state` (geodetic latitude [rad], longitude
[rad], and altitude above the reference `ellipsoid` [m], in this order) into a vector [m]
represented in the Earth-Centered, Earth-Fixed (ECEF) reference frame.

The element type `RT` is the promotion of the element type of `geodetic_state` and the
ellipsoid parameter `T`.

The algorithm is based on **[3]**.

# Keywords

- `ellipsoid::Ellipsoid{T}`: Reference ellipsoid used in the conversion.
    (**Default**: `WGS84_ELLIPSOID`)

# References

- **[3]** mu-blox ag (1999). Datum Transformations of GPS Positions. Application Note.
"""
function geodetic_to_ecef(
    geodetic_state::AbstractVector; ellipsoid::Ellipsoid{T} = WGS84_ELLIPSOID
) where {T <: Number}
    return geodetic_to_ecef(
        geodetic_state[1], geodetic_state[2], geodetic_state[3]; ellipsoid = ellipsoid
    )
end

"""
    geocentric_to_geodetic(ϕ_gc::Number, r::Number; kwargs...) -> NTuple{2, NT}

Compute the geodetic latitude and altitude above the reference `ellipsoid` from the
geocentric latitude `ϕ_gc` [rad] ∈ (-π / 2, π / 2) and radius `r` [m]. Notice that the
longitude is the same in both geocentric and geodetic coordinates.

The returned type `NT` is the promotion of the types of `ϕ_gc`, `r`, and the ellipsoid
parameter `T`, converted to float.

The algorithm is based on **[5]**.

# Keywords

- `ellipsoid::Ellipsoid{T}`: Reference ellipsoid used in the conversion.
    (**Default**: `WGS84_ELLIPSOID`)

# Returns

- `NT`: Geodetic latitude [rad].
- `NT`: Altitude above the reference ellipsoid [m].

# References

- **[5]** Borkowski, K. M (1987). Transformation of geocentric to geodetic coordinates
    without approximations. Astrophysics and Space Science, vol. 139, pp. 1-4.
"""
function geocentric_to_geodetic(
    ϕ_gc::PT, r::RT; ellipsoid::Ellipsoid{T} = WGS84_ELLIPSOID
) where {PT <: Number, RT <: Number, T <: Number}
    # Promote the coordinates with the ellipsoid parameters before entering any branch. This
    # keeps all the returned values at the same promoted floating-point type.
    NT = float(promote_type(PT, RT, T))

    # Obtain the `z` component and the equatorial component `re`.
    sin_ϕ_gc, cos_ϕ_gc = sincos(NT(ϕ_gc))

    r_p = NT(r)
    re  = r_p * cos_ϕ_gc
    z   = r_p * sin_ϕ_gc

    # The algorithm in [5] divides by the equatorial component `re`, which vanishes on the
    # polar axis, yielding `NaN`. `re` is also negative when `|ϕ_gc|` is slightly larger
    # than π / 2, which happens for entirely reasonable inputs such as `Float32(π) / 2`, and
    # in that case the intermediate `√(E² + v)` is evaluated with a negative argument and
    # throws a `DomainError`. In both situations the point lies on the polar axis to within
    # the resolution of the input, where the geodetic solution is exact and needs no
    # iteration.
    if re <= 0
        return copysign(NT(π / 2), z), abs(z) - NT(ellipsoid.b)
    end

    sign_z = z >= 0 ? +1 : -1

    # Auxiliary variables.
    a  = NT(ellipsoid.a)
    a² = a^2
    b  = sign_z * NT(ellipsoid.b)
    b² = b^2

    # Compute the parameters.
    E  = (b * z - (a² - b²)) / (a * re)
    E² = E^2
    F  = (b * z + (a² - b²)) / (a * re)
    P  = NT(4 / 3) * (E * F + 1)
    Q  = 2 * (E² - F^2)
    D  = P^3 + Q^2

    if D ≥ 0
        aux = √D

        # NOTE: `cbrt` must be used here instead of `^(1 / 3)`. When `P < 0` we have
        # `√D ≤ |Q|`, so exactly one of `aux - Q` and `Q + aux` is negative, and raising a
        # negative real to a fractional power throws a `DomainError`. `cbrt` is defined for
        # negative arguments and is also faster.
        v = cbrt(aux - Q) - cbrt(Q + aux)
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
    geocentric_to_geodetic(geocentric_state::AbstractVector; kwargs...) -> NTuple{2, NT}

Compute the geodetic latitude and altitude above the reference `ellipsoid` from
`geocentric_state`, which contains the geocentric latitude [rad] ∈ (-π / 2, π / 2) and the
radius [m], in this order. Notice that the longitude is the same in both geocentric and
geodetic coordinates, so it is not part of the state.

The returned type `NT` is the promotion of the element type of `geocentric_state` and the
ellipsoid parameter `T`, converted to float.

The algorithm is based on **[5]**.

# Keywords

- `ellipsoid::Ellipsoid{T}`: Reference ellipsoid used in the conversion.
    (**Default**: `WGS84_ELLIPSOID`)

# Returns

- `NT`: Geodetic latitude [rad].
- `NT`: Altitude above the reference ellipsoid [m].

# References

- **[5]** Borkowski, K. M (1987). Transformation of geocentric to geodetic coordinates
    without approximations. Astrophysics and Space Science, vol. 139, pp. 1-4.
"""
function geocentric_to_geodetic(
    geocentric_state::AbstractVector; ellipsoid::Ellipsoid{T} = WGS84_ELLIPSOID
) where {T <: Number}
    return geocentric_to_geodetic(
        geocentric_state[1], geocentric_state[2]; ellipsoid = ellipsoid
    )
end

"""
    geodetic_to_geocentric(ϕ_gd::Number, h::Number; kwargs...) -> NTuple{2, NT}

Compute the geocentric latitude and radius from the geodetic latitude `ϕ_gd` [rad] ∈
(-π / 2, π / 2) and altitude `h` [m] above the reference `ellipsoid`. Notice that the
longitude is the same in both geocentric and geodetic coordinates.

The returned type `NT` is the promotion of the types of `ϕ_gd`, `h`, and the ellipsoid
parameter `T`, converted to float.

The algorithm is based on **[4]** (p. 3).

# Keywords

- `ellipsoid::Ellipsoid{T}`: Reference ellipsoid used in the conversion.
    (**Default**: `WGS84_ELLIPSOID`)

# Returns

- `NT`: Geocentric latitude [rad].
- `NT`: Distance from the Earth's center [m].

# References

- **[4]** ISO TC 20/SC 14 N (2011). Geomagnetic Reference Models.
"""
function geodetic_to_geocentric(
    ϕ_gd::PT, h::HT; ellipsoid::Ellipsoid{T} = WGS84_ELLIPSOID
) where {PT <: Number, HT <: Number, T <: Number}
    # Promote the coordinates with the ellipsoid parameters so that both returned values
    # have the same floating-point type regardless of the ellipsoid's own parameter type.
    NT = float(promote_type(PT, HT, T))

    # Auxiliary variables to decrease computational burden.
    sin_ϕ_gd, cos_ϕ_gd = sincos(NT(ϕ_gd))
    sin²_ϕ_gd = sin_ϕ_gd^2

    a   = NT(ellipsoid.a)
    e²  = NT(ellipsoid.e²)
    h_p = NT(h)

    # Radius of curvature in the prime vertical [m].
    N = a / √(1 - e² * sin²_ϕ_gd)

    # Compute the geocentric latitude and radius from the Earth center.
    ρ = (N + h_p) * cos_ϕ_gd
    z = (N * (1 - e²) + h_p) * sin_ϕ_gd

    # `hypot` is used instead of `√(ρ^2 + z^2)` because it does not overflow or underflow
    # when squaring the components.
    r = hypot(ρ, z)

    # The latitude is obtained with `atan` instead of `asin(z / r)`. The latter loses
    # accuracy near the poles, where the derivative of `asin` diverges, and it throws a
    # `DomainError` if rounding pushes `z / r` past 1.
    ϕ_gc = atan(z, ρ)

    return ϕ_gc, r
end

"""
    geodetic_to_geocentric(geodetic_state::AbstractVector; kwargs...) -> NTuple{2, NT}

Compute the geocentric latitude and radius from `geodetic_state`, which contains the
geodetic latitude [rad] ∈ (-π / 2, π / 2) and the altitude above the reference `ellipsoid`
[m], in this order. Notice that the longitude is the same in both geocentric and geodetic
coordinates, so it is not part of the state.

The returned type `NT` is the promotion of the element type of `geodetic_state` and the
ellipsoid parameter `T`, converted to float.

The algorithm is based on **[4]** (p. 3).

# Keywords

- `ellipsoid::Ellipsoid{T}`: Reference ellipsoid used in the conversion.
    (**Default**: `WGS84_ELLIPSOID`)

# Returns

- `NT`: Geocentric latitude [rad].
- `NT`: Distance from the Earth's center [m].

# References

- **[4]** ISO TC 20/SC 14 N (2011). Geomagnetic Reference Models.
"""
function geodetic_to_geocentric(
    geodetic_state::AbstractVector; ellipsoid::Ellipsoid{T} = WGS84_ELLIPSOID
) where {T <: Number}
    return geodetic_to_geocentric(
        geodetic_state[1], geodetic_state[2]; ellipsoid = ellipsoid
    )
end
