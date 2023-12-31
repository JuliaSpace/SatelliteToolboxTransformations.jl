# ECEF and Local frames

```@meta
CurrentModule = SatelliteToolboxTransformations
DocTestSetup = quote
    using SatelliteToolboxTransformations
end
```

There are two functions that can be used to convert a vector between the Earth-Centered,
Earth-Fixed (ECEF) reference frame and a local reference frame.  Currently, only the NED
local frame is supported. This frame is defined as follows at the observer position:

- The X axis points toward the North;
- The Y axis points toward the East; and
- The Z axis points downward.

## Converting from ECEF to NED

We can convert a vector in ECEF to NED using the following function:

```julia
function ecef_to_ned(r_ecef::AbstractVector, lat::Number, lon::Number, h::Number; translate::Bool = false)
```

where a vector `r_ecef` represented in the Earth-Centered, Earth-Fixed (ECEF) frame is
converted to a vector represented in the local reference frame NED (North, East, Down) at
the geodetic position `lat` [rad], `lon` [rad], and `h` [m].

If `translate` is `false`, this function computes only the rotation between ECEF and NED.
Otherwise, it will also translate the vector considering the distance between the Earth's
center and NED origin.

```jldoctest
julia> r_ecef = [
            2.7189672586353812e6
           -3.608191420727525e6
           -4.487701255149731e6
       ];

julia> ecef_to_ned(r_ecef, -45 |> deg2rad, -53 |> deg2rad, 500; translate = true)
3-element StaticArraysCore.SVector{3, Float64} with indices SOneTo(3):
  1.000000000073973
 -1.346480016848351e-10
 -6.608675073698631e-11
 
julia> ecef_to_ned(r_ecef, -45 |> deg2rad, -53 |> deg2rad, 500; translate = false)
3-element StaticArraysCore.SVector{3, Float64} with indices SOneTo(3):
 21385.655604819105
    -2.4815366958196177e-10
    -6.3679536345163295e6
```

## Converting from NED to ECEF

We can convert a vector in NED to ECEF using the following function:

```julia
function ned_to_ecef(r_ned::AbstractVector, lat::Number, lon::Number, h::Number; translate::Bool = false)
```

where a vector `r_ned` represented in the local reference frame NED (North, East, Down) at
the geodetic position `lat` [rad], `lon` [rad], and `h` [m] is converted to the
Earth-Centered, Earth-Fixed (ECEF) frame.

If `translate` is `false`, then this function computes only the rotation between NED and
ECEF. Otherwise, it will also translate the vector considering the distance between the
Earth's center and NED origin.

```jldoctest
julia> ned_to_ecef([1, 0, 0], -45 |> deg2rad, -53 |> deg2rad, 500; translate = true)
3-element StaticArraysCore.SVector{3, Float64} with indices SOneTo(3):
  2.7189672586353812e6
 -3.608191420727525e6
 -4.487701255149731e6

julia> ned_to_ecef([1, 0, 0], -45 |> deg2rad, -53 |> deg2rad, 500; translate = false)
3-element StaticArraysCore.SVector{3, Float64} with indices SOneTo(3):
  0.4255474838907525
 -0.5647205848508179
  0.7071067811865475
```
