SatelliteToolboxTransformations.jl
==================================

[![CI](https://github.com/JuliaSpace/SatelliteToolboxTransformations.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/JuliaSpace/SatelliteToolboxTransformations.jl/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/JuliaSpace/SatelliteToolboxTransformations.jl/branch/main/graph/badge.svg?token=SH31IN1JXM)](https://codecov.io/gh/JuliaSpace/SatelliteToolboxTransformations.jl)
[![](https://img.shields.io/badge/docs-stable-blue.svg)][docs-stable-url]
[![](https://img.shields.io/badge/docs-dev-blue.svg)][docs-dev-url]
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)


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

[docs-dev-url]: https://juliaspace.github.io/SatelliteToolboxTransformations.jl/dev
[docs-stable-url]: https://juliaspace.github.io/SatelliteToolboxTransformations.jl/stable
