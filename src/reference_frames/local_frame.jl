## Description #############################################################################
#
#  Coordinate transformations related with local reference frames.
#
## References ##############################################################################
#
#   [1] https://gssc.esa.int/navipedia/index.php/Transformations_between_ECEF_and_ENU_coordinates
#
############################################################################################

export ecef_to_ned, ned_to_ecef

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
    r_ecef::AbstractVector{T1},
    lat::T2,
    lon::T3,
    h::T4;
    translate::Bool = false
) where {T1<:Number, T2<:Number, T3<:Number, T4<:Number}

    # Obtain the element type of the returned vector.
    T = promote_type(T1, T2, T3, T4) |> float

    # Convert the input vector to the right type.
    r_ecef_T = @SVector T[r_ecef[0 + begin], r_ecef[1 + begin], r_ecef[2 + begin]]

    # Create the matrix that rotates the ECEF into NED.
    D_ned_ecef = angle_to_dcm(T(lon), -T(lat + π / 2), T(0), :ZYX)

    # Check if we need to translate the vector considering NED origins.
    if !translate
        Δr_ecef = r_ecef_T
    else
        # We need now to translate the vector. Thus, we need to obtain the ECEF
        # position of the NED origin.
        #
        # TODO: Add support to different ellipsoids here.
        r_ned_ecef  = T.(geodetic_to_ecef(lat, lon, h))
        Δr_ecef = r_ecef_T - r_ned_ecef
    end

    # Now we can compute the vector in the NED.
    r_ned = D_ned_ecef * Δr_ecef

    return r_ned
end

"""
    ned_to_ecef(r_ned::AbstractVector, lat::Number, lon::Number, h::Number; translate::Bool = false)

Convert a vector `r_ned` represented in the local reference frame NED (North, East, Down) at
the geodetic position `lat` [rad], `lon` [rad], and `h` [m] to the Earth-Centered,
Earth-Fixed (ECEF) frame.

If `translate` is `false`, then this function computes only the rotation between NED and
ECEF. Otherwise, it will also translate the vector considering the distance between the
Earth's center and NED origin.

# Remarks

This algorithm was based on the information in **[1]**.

# References

- **[1]** [Transformations between ECEF and ENU
    coordinates](https://gssc.esa.int/navipedia/index.php/Transformations_between_ECEF_and_ENU_coordinates)
"""
function ned_to_ecef(
    r_ned::AbstractVector{T1},
    lat::T2,
    lon::T3,
    h::T4;
    translate::Bool = false
) where {T1<:Number, T2<:Number, T3<:Number, T4<:Number}

    # Obtain the element type of the returned vector.
    T = promote_type(T1, T2, T3, T4) |> float

    # Convert the input vector to the right type.
    r_ned_T = @SVector T[r_ned[0 + begin], r_ned[1 + begin], r_ned[2 + begin]]

    # Create the matrix that rotates the NED into ECEF.
    D_ecef_ned = angle_to_dcm(T(0), T(lat + π/2), -T(lon), :XYZ)

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
