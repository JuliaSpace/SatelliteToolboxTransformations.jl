# ECEF and Local frames

```@meta
CurrentModule = SatelliteToolboxTransformations
```

```@setup ecef_local_frames
using SatelliteToolboxTransformations
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
ecef_to_ned(r_ecef::AbstractVector, lat::Number, lon::Number, h::Number; translate::Bool = false) -> SVector{3}
```

where a vector `r_ecef` represented in the Earth-Centered, Earth-Fixed (ECEF) frame is
converted to a vector represented in the local reference frame NED (North, East, Down) at
the geodetic position `lat` [rad], `lon` [rad], and `h` [m].

If `translate` is `false`, this function computes only the rotation between ECEF and NED.
Otherwise, it will also translate the vector considering the distance between the Earth's
center and NED origin.

```@repl ecef_local_frames
r_ecef = [
     2.7189672586353812e6
    -3.608191420727525e6
    -4.487701255149731e6
];

ecef_to_ned(r_ecef, -45 |> deg2rad, -53 |> deg2rad, 500; translate = true)
 
ecef_to_ned(r_ecef, -45 |> deg2rad, -53 |> deg2rad, 500; translate = false)
```

## Converting from NED to ECEF

We can convert a vector in NED to ECEF using the following function:

```julia
ned_to_ecef(r_ned::AbstractVector, lat::Number, lon::Number, h::Number; translate::Bool = false) -> SVector{3}
```

where a vector `r_ned` represented in the local reference frame NED (North, East, Down) at
the geodetic position `lat` [rad], `lon` [rad], and `h` [m] is converted to the
Earth-Centered, Earth-Fixed (ECEF) frame.

If `translate` is `false`, then this function computes only the rotation between NED and
ECEF. Otherwise, it will also translate the vector considering the distance between the
Earth's center and NED origin.

```@repl ecef_local_frames
ned_to_ecef([1, 0, 0], -45 |> deg2rad, -53 |> deg2rad, 500; translate = true)

ned_to_ecef([1, 0, 0], -45 |> deg2rad, -53 |> deg2rad, 500; translate = false)
```
