## Description #############################################################################
#
#  Coordinate transformations related with local reference frames.
#
## References ##############################################################################
#
#   [1] https://gssc.esa.int/navipedia/index.php/Transformations_between_ECEF_and_ENU_coordinates
#
############################################################################################

export ecef_to_ned, ned_to_ecef, r_eci_to_hill, r_hill_to_eci

"""
    ecef_to_ned(r_ecef::AbstractVector{T1}, lat::T2, lon::T3, h::T4; translate::Bool = false) -> SVector{3, T}

Convert a vector `r_ecef` represented in the Earth-Centered, Earth-Fixed (ECEF) frame to the
local reference frame NED (North, East, Down) at the geodetic position `lat` [rad], `lon`
[rad], and `h` [m].

If `translate` is `false`, this function computes only the rotation between ECEF and NED.
Otherwise, it will also translate the vector considering the distance between the Earth's
center and NED origin.

The element type `T` of the returned vector is obtained by promoting `T1`, `T2`, `T3`, and
`T4` to a float.

# Remarks

This algorithm was based on the information in **[1]**.

# References

- **[1]**: [Transformations between ECEF and ENU
    coordinates](https://gssc.esa.int/navipedia/index.php/Transformations_between_ECEF_and_ENU_coordinates)
"""
function ecef_to_ned(
    r_ecef::AbstractVector{T1}, lat::T2, lon::T3, h::T4; translate::Bool = false
) where {T1 <: Number, T2 <: Number, T3 <: Number, T4 <: Number}

    # Obtain the element type of the returned vector.
    T = promote_type(T1, T2, T3, T4) |> float

    # Convert the input vector to the right type.
    r_ecef_T = @SVector T[r_ecef[0 + begin], r_ecef[1 + begin], r_ecef[2 + begin]]

    # Create the matrix that rotates the ECEF into NED. This is the direct form
    # of angle_to_dcm(lon, -(lat + π / 2), 0, :ZYX), avoiding the general
    # Euler-angle construction.
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
        # We need now to translate the vector. Thus, we need to obtain the ECEF
        # position of the NED origin.
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
    ned_to_ecef(r_ned::AbstractVector{T1}, lat::T2, lon::T3, h::T4; translate::Bool = false) -> SVector{3, T}

Convert a vector `r_ned` represented in the local reference frame NED (North, East, Down) at
the geodetic position `lat` [rad], `lon` [rad], and `h` [m] to the Earth-Centered,
Earth-Fixed (ECEF) frame.

If `translate` is `false`, then this function computes only the rotation between NED and
ECEF. Otherwise, it will also translate the vector considering the distance between the
Earth's center and NED origin.

The element type `T` of the returned vector is obtained by promoting `T1`, `T2`, `T3`, and
`T4` to a float.

# Remarks

This algorithm was based on the information in **[1]**.

# References

- **[1]** [Transformations between ECEF and ENU
    coordinates](https://gssc.esa.int/navipedia/index.php/Transformations_between_ECEF_and_ENU_coordinates)
"""
function ned_to_ecef(
    r_ned::AbstractVector{T1}, lat::T2, lon::T3, h::T4; translate::Bool = false
) where {T1 <: Number, T2 <: Number, T3 <: Number, T4 <: Number}

    # Obtain the element type of the returned vector.
    T = promote_type(T1, T2, T3, T4) |> float

    # Convert the input vector to the right type.
    r_ned_T = @SVector T[r_ned[0 + begin], r_ned[1 + begin], r_ned[2 + begin]]

    # Create the matrix that rotates the NED into ECEF. This is the transpose
    # of the direct ECEF-to-NED matrix (and the direct form of the equivalent
    # angle_to_dcm construction).
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
        # We need now to translate the vector. Thus, we need to obtain the ECEF
        # position of the NED origin.
        #
        # TODO: Add support to different ellipsoids here.
        r_ned_ecef = T.(geodetic_to_ecef(lat, lon, h))
        return r_ecef + r_ned_ecef
    end
end

"""
    r_eci_to_hill(r_eci::AbstractVector, v_eci::AbstractVector) -> DCM
    r_eci_to_hill(T, r_eci::AbstractVector, v_eci::AbstractVector) -> T

Compute the rotation from an Earth Centered Inertial (ECI) frame to the Hill frame (also
known as the RTN or RSW frame), given the satellite position [m] `r_eci` and satellite
velocity [m/s] `v_eci` in the ECI reference frame. The rotation description that will be
used is given by `T`, which can be `DCM` or `Quaternion`. If `T` is not specified, it falls
back to `DCM`.

The Hill frame is defined as follows:

- X-axis: along the radial direction (from Earth to satellite).
- Y-axis: along the along-track direction (in the direction of motion).
- Z-axis: along the cross-track direction (perpendicular to the orbital plane).

# Returns

- `T`: Rotation entity that rotates the ECI frame into the Hill frame.

# Extended Help

## Rotation Description

The rotation can be described by Direction Cosine Matrices (DCMs) or Quaternions. This is
selected by the parameter `T`. The possible values are:

- `DCM`: The rotation will be described by a Direction Cosine Matrix.
- `Quaternion`: The rotation will be described by a Quaternion.

If no value is specified, it falls back to `DCM`.
"""
function r_eci_to_hill(r_eci::AbstractVector, v_eci::AbstractVector)
    return r_eci_to_hill(DCM, r_eci, v_eci)
end

function r_eci_to_hill(::Type{Quaternion}, r_eci::AbstractVector, v_eci::AbstractVector)
    return dcm_to_quat(r_eci_to_hill(DCM, r_eci, v_eci))
end

function r_eci_to_hill(
    ::Type{DCM},
    r_eci::AbstractVector{T1},
    v_eci::AbstractVector{T2}
) where {T1 <: Number, T2 <: Number}
    # Convert the input vectors to the right type.
    T = promote_type(T1, T2) |> float

    sr_eci = @SVector T[r_eci[0 + begin], r_eci[1 + begin], r_eci[2 + begin]]
    sv_eci = @SVector T[v_eci[0 + begin], v_eci[1 + begin], v_eci[2 + begin]]

    sr̄_eci = normalize(sr_eci)
    sh_eci = sr_eci × sv_eci
    sh̄_eci = normalize(sh_eci)
    sθ̄_eci = sh̄_eci × sr̄_eci

    #! format: off
    return DCM(
        sr̄_eci[1], sθ̄_eci[1], sh̄_eci[1],
        sr̄_eci[2], sθ̄_eci[2], sh̄_eci[2],
        sr̄_eci[3], sθ̄_eci[3], sh̄_eci[3]
    )
    #! format: on
end

"""
    r_hill_to_eci(r_eci::AbstractVector, v_eci::AbstractVector) -> DCM
    r_hill_to_eci(T, r_eci::AbstractVector, v_eci::AbstractVector) -> T

Compute the rotation from the Hill frame (also known as the RTN or RSW frame) to an Earth
Centered Inertial (ECI) frame, given the satellite position [m] `r_eci` and satellite
velocity [m/s] `v_eci` in the ECI reference frame. The rotation description that will be
used is given by `T`, which can be `DCM` or `Quaternion`. If `T` is not specified, it falls
back to `DCM`.

The Hill frame is defined as follows:

- X-axis: along the radial direction (from Earth to satellite).
- Y-axis: along the along-track direction (in the direction of motion).
- Z-axis: along the cross-track direction (perpendicular to the orbital plane).

# Returns

- `T`: Rotation entity that rotates the Hill frame into the ECI frame.

# Extended Help

## Rotation Description

The rotation can be described by Direction Cosine Matrices (DCMs) or Quaternions. This is
selected by the parameter `T`. The possible values are:

- `DCM`: The rotation will be described by a Direction Cosine Matrix.
- `Quaternion`: The rotation will be described by a Quaternion.

If no value is specified, it falls back to `DCM`.
"""
function r_hill_to_eci(r_eci::AbstractVector, v_eci::AbstractVector)
    return r_hill_to_eci(DCM, r_eci, v_eci)
end

function r_hill_to_eci(T::T_ROT, r_eci::AbstractVector, v_eci::AbstractVector)
    return inv_rotation(r_eci_to_hill(T, r_eci, v_eci))
end
