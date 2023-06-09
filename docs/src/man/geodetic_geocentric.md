Geodetic and Geocentric
=======================

```@meta
CurrentModule = SatelliteToolboxTransformations
DocTestSetup = quote
    using SatelliteToolboxTransformations
end
```

There are six functions that can help to convert between geodetic and geocentric
representations. Notice that currently all Geodetic representations are based on the WGS84
reference ellipsoid.

## ECEF to Geocentric

We can convert a position vector represented in an Earth-Centered, Earth-Fixed frame (ECEF)
`r_e` to the Geocentric latitude, longitude, and distance from Earth's center using the
following function:

```julia
function ecef_to_geocentric(r_e::AbstractVector{T})
```

which returns a tuple with:

- The Geocentric latitude [rad];
- The longitude [rad]; and
- The distance from the Earth's center [m].

```jldoctest
julia> ecef_to_geocentric([7000, 0, 7000])
(0.7853981633974483, 0.0, 9899.494936611665)

julia> ecef_to_geocentric([0, 0, 7000])
(1.5707963267948966, 0.0, 7000.0)

julia> ecef_to_geocentric([7000, 0, 0])
(0.0, 0.0, 7000.0)
```

### Geocentric to ECEF

We can convert a Geocentric coordinate (latitude `lat` [rad], longitude `lon` [rad], and
distance from Earth's center `r` [m]) to a vector represented in the Earth-Centered,
Earth-Fixed (ECEF) frame using the following function:

```julia
function geocentric_to_ecef(lat::Number, lon::Number, r::Number) -> SVector{3, T}
```

which returns a 3x1 vector.

```jldoctest
julia> geocentric_to_ecef(0, 0, 7000e3)
3-element StaticArraysCore.SVector{3, Float64} with indices SOneTo(3):
 7.0e6
 0.0
 0.0
 
julia> geocentric_to_ecef(pi / 2, 0, 7000e3)
3-element StaticArraysCore.SVector{3, Float64} with indices SOneTo(3):
 4.286263797015736e-10
 0.0
 7.0e6
 
julia> geocentric_to_ecef(pi / 4, 0, 7000e3)
3-element StaticArraysCore.SVector{3, Float64} with indices SOneTo(3):
 4.949747468305833e6
 0.0
 4.949747468305832e6
```

## ECEF to Geodetic

We can convert a position vector represented in an Earth-Centered, Earth-Fixed frame (ECEF)
`r_e` to the Geodetic latitude, longitude, and altitude using the following function:

```julia
function ecef_to_geodetic(r_e::AbstractVector)
```

which returns a tuple with:

- The Geodetic latitude [rad];
- The longitude [rad]; and
- The altitude above the reference ellipsoid [m].

```jldoctest
julia> ecef_to_geodetic([6378137.0, 0, 0])
(0.0, 0.0, 0.0)

julia> ecef_to_geodetic([0, 6378137.0, 0])
(0.0, 1.5707963267948966, 0.0)

julia> ecef_to_geodetic([0, 0, 6378137.0])
(1.5707963267948966, 0.0, 21384.685754820704)
```

## Geodetic to ECEF

The Geodetic latitude `lat` [rad], longitude `lon` [rad], and altitude `h` [m] can be
converted to a vector represented in an ECEF reference frame by the following function:

```julia
function geodetic_to_ecef(lat::Number, lon::Number, h::Number)
```

which returns a 3x1 vector.

```jldoctest
julia> geodetic_to_ecef(0, 0, 0)
3-element StaticArraysCore.SVector{3, Float64} with indices SOneTo(3):
 6.378137e6
 0.0
 0.0

julia> geodetic_to_ecef(deg2rad(-22), deg2rad(-45), 0)
3-element StaticArraysCore.SVector{3, Float64} with indices SOneTo(3):
  4.1835869067109847e6
 -4.1835869067109837e6
 -2.3744128953028163e6
```

## Geocentric to Geodetic

Given a Geocentric latitude `ϕ_gc` [rad] and distance from the center of Earth `r` [m], one
can obtain the Geodetic coordinates (Geodetic latitude and altitude above the reference
ellipsoid - WGS84) using the following function:

```julia
function geocentric_to_geodetic(ϕ_gc::Number, r::Number)
```

in which returns a tuple with two values:

- The Geodetic latitude [rad]; and
- The altitude above the reference ellipsoid (WGS-84) [m].

!!! note
    The longitude is the same in both Geodetic and Geocentric representations.

```jldoctest
julia> geocentric_to_geodetic(deg2rad(-22), 6378137.0)
(-0.3863099329112617, 3013.9291869809385)

julia> geocentric_to_geodetic(0, 6378137.0)
(0.0, 0.0)
```

## Geodetic to Geocentric

Given a Geodetic latitude `ϕ_gd` [rad] and altitude above the reference ellipsoid `h` [m],
one can obtain the Geocentric coordinates (Geocentric latitude and position from the center
of Earth) using the following function:

```julia
function geodetic_to_geocentric(ϕ_gd::Number, h::Number)
```

which returns a tuple with two values:

- The Geocentric latitude [rad]; and
- The distance from the center of Earth [m].

!!! note
    The longitude is the same in both Geodetic and Geocentric representations.

```jldoctest
julia> geodetic_to_geocentric(deg2rad(-22), 0)
(-0.38164509973650357, 6.375157677217675e6)

julia> geodetic_to_geocentric(0, 0)
(0.0, 6.378137e6)
```
