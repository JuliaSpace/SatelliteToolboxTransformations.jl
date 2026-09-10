## Description #############################################################################
#
# Coordinate transformations related with local reference frames: the NED frame attached to
# a geodetic position, and the satellite-centered Hill (RSW) and LVLH frames.
#
## References ##############################################################################
#
#   [1] https://gssc.esa.int/navipedia/index.php/Transformations_between_ECEF_and_ENU_coordinates
#
#   [2] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. 4th ed.
#       Microcosm Press, Hawthorn, CA, USA.
#
############################################################################################

export ecef_to_ned, ned_to_ecef
export r_eci_to_hill, r_hill_to_eci, r_eci_to_lvlh, r_lvlh_to_eci

"""
    ecef_to_ned(r_ecef::AbstractVector{T1}, lat::T2, lon::T3, h::T4; kwargs...) -> SVector{3, T}

Convert the vector `r_ecef` [m] represented in the Earth-Centered, Earth-Fixed (ECEF)
reference frame to the local North-East-Down (NED) reference frame defined at the geodetic
latitude `lat` [rad], longitude `lon` [rad], and altitude `h` [m].

The NED frame is centered at the geodetic position and its axes are defined as follows:

- X-axis: Toward the geodetic North;
- Y-axis: Toward the East; and
- Z-axis: Downward, along the inward ellipsoid normal.

The element type `T` of the returned vector is obtained by promoting `T1`, `T2`, `T3`, and
`T4` to a float.

See also: [`ned_to_ecef`](@ref)

# Keywords

- `translate::Bool`: If `true`, the vector is also translated by the ECEF position of the
    NED origin, so that the input is treated as a position. If `false`, only the rotation is
    applied, so that the input is treated as a free vector.
    (**Default**: `false`)

# Returns

- `SVector{3, T}`: Vector `r_ecef` represented in the NED reference frame.

# References

- **[1]** [Transformations between ECEF and ENU
    coordinates](https://gssc.esa.int/navipedia/index.php/Transformations_between_ECEF_and_ENU_coordinates)

# Extended help

The rotation is the direct form of `angle_to_dcm(lon, -(lat + π / 2), 0, :ZYX)`, avoiding
the general Euler-angle construction. The translation uses the WGS-84 ellipsoid through
[`geodetic_to_ecef`](@ref).
"""
function ecef_to_ned(
    r_ecef::AbstractVector{T1}, lat::T2, lon::T3, h::T4; translate::Bool = false
) where {T1 <: Number, T2 <: Number, T3 <: Number, T4 <: Number}

    # Obtain the element type of the returned vector.
    T = promote_type(T1, T2, T3, T4) |> float

    # Convert the input vector to the right type.
    r_ecef_T = @SVector T[r_ecef[0 + begin], r_ecef[1 + begin], r_ecef[2 + begin]]

    # Create the matrix that rotates the ECEF into NED. This is the direct form of
    # `angle_to_dcm(lon, -(lat + π / 2), 0, :ZYX)`, avoiding the general Euler-angle
    # construction.
    sin_lat, cos_lat = sincos(T(lat))
    sin_lon, cos_lon = sincos(T(lon))
    D_ned_ecef = @SMatrix [
        -sin_lat * cos_lon  -sin_lat * sin_lon   cos_lat
        -sin_lon             cos_lon             zero(T)
        -cos_lat * cos_lon  -cos_lat * sin_lon  -sin_lat
    ]

    # Check if we need to translate the vector considering NED origins.
    if !translate
        Δr_ecef = r_ecef_T
    else
        # We need now to translate the vector. Thus, we need to obtain the ECEF position of
        # the NED origin.
        #
        # TODO: Add support to different ellipsoids here.
        r_ned_ecef = T.(geodetic_to_ecef(lat, lon, h))
        Δr_ecef = r_ecef_T - r_ned_ecef
    end

    # Now we can compute the vector in the NED.
    r_ned = D_ned_ecef * Δr_ecef

    return r_ned
end

"""
    ned_to_ecef(r_ned::AbstractVector{T1}, lat::T2, lon::T3, h::T4; kwargs...) -> SVector{3, T}

Convert the vector `r_ned` [m] represented in the local North-East-Down (NED) reference
frame defined at the geodetic latitude `lat` [rad], longitude `lon` [rad], and altitude `h`
[m] to the Earth-Centered, Earth-Fixed (ECEF) reference frame.

The NED frame is centered at the geodetic position and its axes are defined as follows:

- X-axis: Toward the geodetic North;
- Y-axis: Toward the East; and
- Z-axis: Downward, along the inward ellipsoid normal.

The element type `T` of the returned vector is obtained by promoting `T1`, `T2`, `T3`, and
`T4` to a float.

See also: [`ecef_to_ned`](@ref)

# Keywords

- `translate::Bool`: If `true`, the vector is also translated by the ECEF position of the
    NED origin, so that the input is treated as a position. If `false`, only the rotation is
    applied, so that the input is treated as a free vector.
    (**Default**: `false`)

# Returns

- `SVector{3, T}`: Vector `r_ned` represented in the ECEF reference frame.

# References

- **[1]** [Transformations between ECEF and ENU
    coordinates](https://gssc.esa.int/navipedia/index.php/Transformations_between_ECEF_and_ENU_coordinates)

# Extended help

The rotation is the transpose of the one used in [`ecef_to_ned`](@ref). The translation uses
the WGS-84 ellipsoid through [`geodetic_to_ecef`](@ref).
"""
function ned_to_ecef(
    r_ned::AbstractVector{T1}, lat::T2, lon::T3, h::T4; translate::Bool = false
) where {T1 <: Number, T2 <: Number, T3 <: Number, T4 <: Number}

    # Obtain the element type of the returned vector.
    T = promote_type(T1, T2, T3, T4) |> float

    # Convert the input vector to the right type.
    r_ned_T = @SVector T[r_ned[0 + begin], r_ned[1 + begin], r_ned[2 + begin]]

    # Create the matrix that rotates the NED into ECEF. This is the transpose of the direct
    # ECEF-to-NED matrix and the direct form of the equivalent `angle_to_dcm` construction.
    sin_lat, cos_lat = sincos(T(lat))
    sin_lon, cos_lon = sincos(T(lon))
    D_ecef_ned = @SMatrix [
        -sin_lat * cos_lon  -sin_lon             -cos_lat * cos_lon
        -sin_lat * sin_lon   cos_lon             -cos_lat * sin_lon
         cos_lat             zero(T)             -sin_lat
    ]

    # Now we can compute the vector in ECEF.
    r_ecef = D_ecef_ned * r_ned_T

    # Check if we need to translate the vector considering NED origins.
    if !translate
        return r_ecef
    else
        # We need now to translate the vector. Thus, we need to obtain the ECEF position of
        # the NED origin.
        #
        # TODO: Add support to different ellipsoids here.
        r_ned_ecef = T.(geodetic_to_ecef(lat, lon, h))
        return r_ecef + r_ned_ecef
    end
end

"""
    r_eci_to_hill([T, ]r_eci::AbstractVector, v_eci::AbstractVector) -> T
    r_eci_to_hill([T, ]sv::OrbitStateVector) -> T

Compute the rotation from an Earth-Centered Inertial (ECI) reference frame to the Hill
frame, also known as RSW or RTN frame, given the satellite position `r_eci` [m] and velocity
`v_eci` [m/s] represented in the ECI frame. The state can also be provided as the orbit
state vector `sv`, whose position `sv.r` [m] and velocity `sv.v` [m/s] must be represented
in the ECI frame. The rotation description is selected by `T`, which can be `DCM` or
`Quaternion`. If `T` is omitted, it defaults to `DCM`.

The Hill frame is centered at the satellite and its axes are defined as follows:

- X-axis (R): Radial direction, from the Earth's center to the satellite;
- Y-axis (S): Along-track direction, perpendicular to the radial direction in the orbital
    plane and positive toward the direction of motion; and
- Z-axis (W): Cross-track direction, along the orbit angular momentum vector, completing the
    right-handed frame.

The Y-axis is aligned with the velocity vector only in circular orbits. The function throws
if `r_eci` and `v_eci` do not define an orbital plane.

See also: [`r_hill_to_eci`](@ref), [`r_eci_to_lvlh`](@ref)

# Returns

- `T`: Rotation that maps a vector represented in the ECI frame to the Hill frame
    (`D_hill_eci` or `q_hill_eci`).

# References

- **[2]** Vallado, D. A (2013). *Fundamentals of Astrodynamics and Applications*. 4th ed.
    Microcosm Press, pp. 163-164.

# Extended help

## Rotation Description

The rotation can be described by Direction Cosine Matrices (DCMs) or Quaternions. This is
selected by the parameter `T`. The possible values are:

- `DCM`: The rotation will be described by a Direction Cosine Matrix.
- `Quaternion`: The rotation will be described by a Quaternion.

If no value is specified, it falls back to `DCM`.

## Throws

- `ArgumentError`: `r_eci` and `v_eci` are parallel or at least one of them is zero, so that
    the orbit angular momentum vanishes and the cross-track direction is undefined. The
    frame is ill-conditioned, but not rejected, when the two vectors are nearly parallel.
"""
function r_eci_to_hill(r_eci::AbstractVector, v_eci::AbstractVector)
    return r_eci_to_hill(DCM, r_eci, v_eci)
end

function r_eci_to_hill(::Type{Quaternion}, r_eci::AbstractVector, v_eci::AbstractVector)
    return dcm_to_quat(r_eci_to_hill(DCM, r_eci, v_eci))
end

function r_eci_to_hill(::Type{DCM}, r_eci::AbstractVector, v_eci::AbstractVector)
    r̄_eci, θ̄_eci, h̄_eci = _hill_triad(r_eci, v_eci)

    # The rows of `D_hill_eci` are the Hill axes represented in the ECI frame. `hcat` places
    # them as columns, hence the transpose. Both operations are allocation-free for
    # `SVector`s.
    D_hill_eci = DCM(transpose(hcat(r̄_eci, θ̄_eci, h̄_eci)))

    return D_hill_eci
end

function r_eci_to_hill(sv::OrbitStateVector)
    return r_eci_to_hill(DCM, sv.r, sv.v)
end

function r_eci_to_hill(T::T_ROT, sv::OrbitStateVector)
    return r_eci_to_hill(T, sv.r, sv.v)
end

"""
    r_hill_to_eci([T, ]r_eci::AbstractVector, v_eci::AbstractVector) -> T
    r_hill_to_eci([T, ]sv::OrbitStateVector) -> T

Compute the rotation from the Hill frame, also known as RSW or RTN frame to an
Earth-Centered Inertial (ECI) reference frame, given the satellite position `r_eci` [m] and
velocity `v_eci` [m/s] represented in the ECI frame. The state can also be provided as the
orbit state vector `sv`, whose position `sv.r` [m] and velocity `sv.v` [m/s] must be
represented in the ECI frame. The rotation description is selected by `T`, which can be
`DCM` or `Quaternion`. If `T` is omitted, it defaults to `DCM`.

The Hill frame is centered at the satellite and its axes are defined as follows:

- X-axis (R): Radial direction, from the Earth's center to the satellite;
- Y-axis (S): Along-track direction, perpendicular to the radial direction in the orbital
    plane and positive toward the direction of motion; and
- Z-axis (W): Cross-track direction, along the orbit angular momentum vector, completing the
    right-handed frame.

The Y-axis is aligned with the velocity vector only in circular orbits. The function throws
if `r_eci` and `v_eci` do not define an orbital plane.

See also: [`r_eci_to_hill`](@ref), [`r_lvlh_to_eci`](@ref)

# Returns

- `T`: Rotation that maps a vector represented in the Hill frame to the ECI frame
    (`D_eci_hill` or `q_eci_hill`).

# References

- **[2]** Vallado, D. A (2013). *Fundamentals of Astrodynamics and Applications*. 4th ed.
    Microcosm Press, pp. 163-164.

# Extended help

## Rotation Description

The rotation can be described by Direction Cosine Matrices (DCMs) or Quaternions. This is
selected by the parameter `T`. The possible values are:

- `DCM`: The rotation will be described by a Direction Cosine Matrix.
- `Quaternion`: The rotation will be described by a Quaternion.

If no value is specified, it falls back to `DCM`.

## Throws

- `ArgumentError`: `r_eci` and `v_eci` are parallel or at least one of them is zero, so that
    the orbit angular momentum vanishes and the cross-track direction is undefined. The
    frame is ill-conditioned, but not rejected, when the two vectors are nearly parallel.
"""
function r_hill_to_eci(r_eci::AbstractVector, v_eci::AbstractVector)
    return r_hill_to_eci(DCM, r_eci, v_eci)
end

function r_hill_to_eci(T::T_ROT, r_eci::AbstractVector, v_eci::AbstractVector)
    return inv_rotation(r_eci_to_hill(T, r_eci, v_eci))
end

function r_hill_to_eci(sv::OrbitStateVector)
    return r_hill_to_eci(DCM, sv.r, sv.v)
end

function r_hill_to_eci(T::T_ROT, sv::OrbitStateVector)
    return r_hill_to_eci(T, sv.r, sv.v)
end

"""
    r_eci_to_lvlh([T, ]r_eci::AbstractVector, v_eci::AbstractVector) -> T
    r_eci_to_lvlh([T, ]sv::OrbitStateVector) -> T

Compute the rotation from an Earth-Centered Inertial (ECI) reference frame to the Local
Vertical, Local Horizontal (LVLH) frame, given the satellite position `r_eci` [m] and
velocity `v_eci` [m/s] represented in the ECI frame. The state can also be provided as the
orbit state vector `sv`, whose position `sv.r` [m] and velocity `sv.v` [m/s] must be
represented in the ECI frame. The rotation description is selected by `T`, which can be
`DCM` or `Quaternion`. If `T` is omitted, it defaults to `DCM`.

The LVLH frame is centered at the satellite and its axes are defined as follows:

- X-axis: Along-track direction, perpendicular to the radial direction in the orbital plane
    and positive toward the direction of motion;
- Y-axis: Opposite to the orbit angular momentum vector, completing the right-handed frame;
    and
- Z-axis: Nadir direction, from the satellite to the Earth's center.

The X-axis is aligned with the velocity vector only in circular orbits. This frame is a
permutation of the Hill frame axes: `x_lvlh = y_hill`, `y_lvlh = -z_hill`, and
`z_lvlh = -x_hill`. The function throws if `r_eci` and `v_eci` do not define an orbital
plane.

See also: [`r_lvlh_to_eci`](@ref), [`r_eci_to_hill`](@ref)

# Returns

- `T`: Rotation that maps a vector represented in the ECI frame to the LVLH frame
    (`D_lvlh_eci` or `q_lvlh_eci`).

# References

- **[2]** Vallado, D. A (2013). *Fundamentals of Astrodynamics and Applications*. 4th ed.
    Microcosm Press, pp. 163-164.

# Extended help

## Rotation Description

The rotation can be described by Direction Cosine Matrices (DCMs) or Quaternions. This is
selected by the parameter `T`. The possible values are:

- `DCM`: The rotation will be described by a Direction Cosine Matrix.
- `Quaternion`: The rotation will be described by a Quaternion.

If no value is specified, it falls back to `DCM`.

## Throws

- `ArgumentError`: `r_eci` and `v_eci` are parallel or at least one of them is zero, so that
    the orbit angular momentum vanishes and the cross-track direction is undefined. The
    frame is ill-conditioned, but not rejected, when the two vectors are nearly parallel.
"""
function r_eci_to_lvlh(r_eci::AbstractVector, v_eci::AbstractVector)
    return r_eci_to_lvlh(DCM, r_eci, v_eci)
end

function r_eci_to_lvlh(::Type{Quaternion}, r_eci::AbstractVector, v_eci::AbstractVector)
    return dcm_to_quat(r_eci_to_lvlh(DCM, r_eci, v_eci))
end

function r_eci_to_lvlh(::Type{DCM}, r_eci::AbstractVector, v_eci::AbstractVector)
    r̄_eci, θ̄_eci, h̄_eci = _hill_triad(r_eci, v_eci)

    # The LVLH frame is a permutation of the Hill frame: X is the along-track direction, Z
    # is the nadir direction, and Y completes the right-handed frame, pointing opposite to
    # the orbit angular momentum. The rows of `D_lvlh_eci` are those axes in the ECI frame.
    D_lvlh_eci = DCM(transpose(hcat(θ̄_eci, -h̄_eci, -r̄_eci)))

    return D_lvlh_eci
end

function r_eci_to_lvlh(sv::OrbitStateVector)
    return r_eci_to_lvlh(DCM, sv.r, sv.v)
end

function r_eci_to_lvlh(T::T_ROT, sv::OrbitStateVector)
    return r_eci_to_lvlh(T, sv.r, sv.v)
end

"""
    r_lvlh_to_eci([T, ]r_eci::AbstractVector, v_eci::AbstractVector) -> T
    r_lvlh_to_eci([T, ]sv::OrbitStateVector) -> T

Compute the rotation from the Local Vertical, Local Horizontal (LVLH) frame to an
Earth-Centered Inertial (ECI) reference frame, given the satellite position `r_eci` [m] and
velocity `v_eci` [m/s] represented in the ECI frame. The state can also be provided as the
orbit state vector `sv`, whose position `sv.r` [m] and velocity `sv.v` [m/s] must be
represented in the ECI frame. The rotation description is selected by `T`, which can be
`DCM` or `Quaternion`. If `T` is omitted, it defaults to `DCM`.

The LVLH frame is centered at the satellite and its axes are defined as follows:

- X-axis: Along-track direction, perpendicular to the radial direction in the orbital plane
    and positive toward the direction of motion;
- Y-axis: Opposite to the orbit angular momentum vector, completing the right-handed frame;
    and
- Z-axis: Nadir direction, from the satellite to the Earth's center.

The X-axis is aligned with the velocity vector only in circular orbits. This frame is a
permutation of the Hill frame axes: `x_lvlh = y_hill`, `y_lvlh = -z_hill`, and
`z_lvlh = -x_hill`. The function throws if `r_eci` and `v_eci` do not define an orbital
plane.

See also: [`r_eci_to_lvlh`](@ref), [`r_hill_to_eci`](@ref)

# Returns

- `T`: Rotation that maps a vector represented in the LVLH frame to the ECI frame
    (`D_eci_lvlh` or `q_eci_lvlh`).

# References

- **[2]** Vallado, D. A (2013). *Fundamentals of Astrodynamics and Applications*. 4th ed.
    Microcosm Press, pp. 163-164.

# Extended help

## Rotation Description

The rotation can be described by Direction Cosine Matrices (DCMs) or Quaternions. This is
selected by the parameter `T`. The possible values are:

- `DCM`: The rotation will be described by a Direction Cosine Matrix.
- `Quaternion`: The rotation will be described by a Quaternion.

If no value is specified, it falls back to `DCM`.

## Throws

- `ArgumentError`: `r_eci` and `v_eci` are parallel or at least one of them is zero, so that
    the orbit angular momentum vanishes and the cross-track direction is undefined. The
    frame is ill-conditioned, but not rejected, when the two vectors are nearly parallel.
"""
function r_lvlh_to_eci(r_eci::AbstractVector, v_eci::AbstractVector)
    return r_lvlh_to_eci(DCM, r_eci, v_eci)
end

function r_lvlh_to_eci(T::T_ROT, r_eci::AbstractVector, v_eci::AbstractVector)
    return inv_rotation(r_eci_to_lvlh(T, r_eci, v_eci))
end

function r_lvlh_to_eci(sv::OrbitStateVector)
    return r_lvlh_to_eci(DCM, sv.r, sv.v)
end

function r_lvlh_to_eci(T::T_ROT, sv::OrbitStateVector)
    return r_lvlh_to_eci(T, sv.r, sv.v)
end

############################################################################################
#                                    Private Functions                                     #
############################################################################################

"""
    _hill_triad(r_eci::AbstractVector{T1}, v_eci::AbstractVector{T2}) where {T1 <: Number, T2 <: Number} -> NTuple{3, SVector{3, T}}

Compute the orthonormal triad of the Hill frame given the satellite position `r_eci` [m] and
velocity `v_eci` [m/s] represented in an Earth-Centered Inertial (ECI) reference frame.

The element type `T` of the returned vectors is obtained by promoting `T1` and `T2` to a
float. The function throws if `r_eci` and `v_eci` do not define an orbital plane.

# Returns

- `SVector{3, T}`: Unit vector [-] along the radial direction (from the Earth's center to
    the satellite) represented in the ECI frame.
- `SVector{3, T}`: Unit vector [-] along the along-track direction represented in the ECI
    frame.
- `SVector{3, T}`: Unit vector [-] along the orbit angular momentum represented in the ECI
    frame.

# References

- **[2]** Vallado, D. A (2013). *Fundamentals of Astrodynamics and Applications*. 4th ed.
    Microcosm Press, pp. 163-164.

# Extended help

## Throws

- `ArgumentError`: `r_eci` and `v_eci` are parallel or at least one of them is zero, so that
    the orbit angular momentum vanishes and the frame is undefined.
"""
function _hill_triad(
    r_eci::AbstractVector{T1}, v_eci::AbstractVector{T2}
) where {T1 <: Number, T2 <: Number}
    # Obtain the element type of the returned vectors.
    T = promote_type(T1, T2) |> float

    # Convert the input vectors to the right type.
    sr_eci = @SVector T[r_eci[0 + begin], r_eci[1 + begin], r_eci[2 + begin]]
    sv_eci = @SVector T[v_eci[0 + begin], v_eci[1 + begin], v_eci[2 + begin]]

    # The orbit angular momentum defines the cross-track direction. It vanishes if the
    # position and velocity are parallel or if any of them is zero, and in this case the
    # frame is undefined.
    h_eci  = sr_eci × sv_eci
    norm_h = norm(h_eci)

    norm_h == 0 && throw(
        ArgumentError(
            "The position and velocity vectors must be non-zero and non-parallel to " *
            "define the Hill frame.",
        ),
    )

    # Radial, cross-track, and along-track unit vectors [2, pp. 163-164].
    r̄_eci = normalize(sr_eci)
    h̄_eci = h_eci / norm_h
    θ̄_eci = h̄_eci × r̄_eci

    return r̄_eci, θ̄_eci, h̄_eci
end
