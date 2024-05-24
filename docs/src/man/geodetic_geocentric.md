# Geodetic and Geocentric

```@meta
CurrentModule = SatelliteToolboxTransformations
```

```@setup geodetic_geocentric
using SatelliteToolboxTransformations
```

There are six functions that can help to convert between geodetic and geocentric
representations. Notice that currently all Geodetic representations are based on the WGS84
reference ellipsoid.

## ECEF to Geocentric

We can convert a position vector represented in an Earth-Centered, Earth-Fixed frame (ECEF)
`r_e` to the Geocentric latitude, longitude, and distance from Earth's center using the
following function:

```julia
ecef_to_geocentric(r_e::AbstractVector{T}) -> NTuple{3, float(T)}
```

which returns a tuple with:

- The Geocentric latitude [rad];
- The longitude [rad]; and
- The distance from the Earth's center [m].

```@repl geodetic_geocentric
ecef_to_geocentric([7000, 0, 7000])

ecef_to_geocentric([0, 0, 7000])

ecef_to_geocentric([7000, 0, 0])
```

## Geocentric to ECEF

We can convert a Geocentric coordinate (latitude `lat` [rad], longitude `lon` [rad], and
distance from Earth's center `r` [m]) to a vector represented in the Earth-Centered,
Earth-Fixed (ECEF) frame using the following function:

```julia
geocentric_to_ecef(lat::Number, lon::Number, r::Number) -> SVector{3}
```

which returns a 3x1 vector.

```@repl geodetic_geocentric
geocentric_to_ecef(0, 0, 7000e3)
 
geocentric_to_ecef(pi / 2, 0, 7000e3)
 
geocentric_to_ecef(pi / 4, 0, 7000e3)
```

## ECEF to Geodetic

We can convert a position vector represented in an Earth-Centered, Earth-Fixed frame (ECEF)
`r_e` to the Geodetic latitude, longitude, and altitude using the following function:

```julia
ecef_to_geodetic(r_e::AbstractVector{T}) -> NTuple{3, float(T)}
```

which returns a tuple with:

- The Geodetic latitude [rad];
- The longitude [rad]; and
- The altitude above the reference ellipsoid [m].

```@repl geodetic_geocentric
ecef_to_geodetic([6378137.0, 0, 0])

ecef_to_geodetic([0, 6378137.0, 0])

ecef_to_geodetic([0, 0, 6378137.0])
```

## Geodetic to ECEF

The Geodetic latitude `lat` [rad], longitude `lon` [rad], and altitude `h` [m] can be
converted to a vector represented in an ECEF reference frame by the following function:

```julia
geodetic_to_ecef(lat::Number, lon::Number, h::Number) -> SVector{3}
```

which returns a 3x1 vector.

```@repl geodetic_geocentric
geodetic_to_ecef(0, 0, 0)

geodetic_to_ecef(deg2rad(-22), deg2rad(-45), 0)
```

## Geocentric to Geodetic

Given a Geocentric latitude `ϕ_gc` [rad] and distance from the center of Earth `r` [m], one
can obtain the Geodetic coordinates (Geodetic latitude and altitude above the reference
ellipsoid - WGS84) using the following function:

```julia
geocentric_to_geodetic(ϕ_gc::Number, r::Number) -> Number, Number
```

in which returns a tuple with two values:

- The Geodetic latitude [rad]; and
- The altitude above the reference ellipsoid (WGS-84) [m].

!!! note

    The longitude is the same in both Geodetic and Geocentric representations.

```@repl geodetic_geocentric
geocentric_to_geodetic(deg2rad(-22), 6378137.0)

geocentric_to_geodetic(0, 6378137.0)
```

## Geodetic to Geocentric

Given a Geodetic latitude `ϕ_gd` [rad] and altitude above the reference ellipsoid `h` [m],
one can obtain the Geocentric coordinates (Geocentric latitude and position from the center
of Earth) using the following function:

```julia
geodetic_to_geocentric(ϕ_gd::Number, h::Number) -> Number, Number
```

which returns a tuple with two values:

- The Geocentric latitude [rad]; and
- The distance from the center of Earth [m].

!!! note

    The longitude is the same in both Geodetic and Geocentric representations.

```@repl geodetic_geocentric
geodetic_to_geocentric(deg2rad(-22), 0)

geodetic_to_geocentric(0, 0)
```
