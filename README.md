SatelliteToolboxTransformations.jl
==================================

[![CI](https://github.com/JuliaSpace/SatelliteToolboxTransformations.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/JuliaSpace/SatelliteToolboxTransformations.jl/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/JuliaSpace/SatelliteToolboxTransformations.jl/branch/main/graph/badge.svg?token=SH31IN1JXM)](https://codecov.io/gh/JuliaSpace/SatelliteToolboxTransformations.jl)

This package contains transformations that are useful for the
**SatelliteToolbox.jl** ecosystem. Currently, the following algorithms are
available:

- Conversion between ECI and ECEF reference frames (IAU-76/FK5 and
  IAU-2006/2010A);
- Conversion between ECEF and local frames (NED);
- Conversion between Geodetic and Geocentric variables; and
- Conversion between time epochs (UTC, UT1, TT).

## Installation

This package can be installed using:

``` julia
julia> using Pkg
julia> Pkg.add("SatelliteToolboxTransformations")
```
