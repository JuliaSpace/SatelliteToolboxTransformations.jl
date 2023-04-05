SatelliteToolboxTransformations.jl
==================================

This package contains transformations that are useful for the **SatelliteToolbox.jl**
ecosystem. Currently, the following algorithms are available:

- Conversion between ECI and ECEF reference frames (IAU-76/FK5 and IAU-2006/2010A);
- Conversion between ECEF and local frames (NED);
- Conversion between Geodetic and Geocentric variables; and
- Conversion between time epochs (UTC, UT1, TT).

## Installation

This package can be installed using:

``` julia
julia> using Pkg
julia> Pkg.add("SatelliteToolboxTransformations")
```
