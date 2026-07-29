SatelliteToolboxTransformations.jl Changelog
============================================

Version 1.2.1
-------------

- ![Bugfix][badge-bugfix] `compute_δΔϵ_δΔψ` returned the nutation in longitude correction
  with the wrong sign. The function inverts the system in IERS Technical Note No. 36,
  eq. 5.25, whose determinant is `1 + aux²`, but it used `sin(ϵ₀) ⋅ (aux² - 1)`. This
  affected the equinox-based IAU-2006 transformations that consume the correction, namely
  ITRF and TIRS against ERS, MOD06, and MJ2000, by a few centimetres on the Earth's surface.
- ![Bugfix][badge-bugfix] `geocentric_to_geodetic` returned `NaN` on the polar axis, where
  the algorithm divides by the vanishing equatorial component. It also threw a `DomainError`
  from inside `sqrt` when the geocentric latitude was slightly beyond ±π/2, which is the case
  for `Float32(π) / 2`. Both cases now return the exact polar solution.
- ![Enhancement][badge-enhancement] `geodetic_to_geocentric` obtains the geocentric latitude
  with `atan` instead of `asin`, which is accurate near the poles and cannot throw a
  `DomainError`.
- ![Enhancement][badge-enhancement] `geocentric_to_geodetic` and `geodetic_to_geocentric` now
  promote their inputs with the ellipsoid parameter type, so that both returned values always
  have the same floating-point type.
- ![Enhancement][badge-enhancement] The IAU-1980 nutation coefficients are kept in a
  transposed copy, making the coefficients of each term contiguous. This is worth about 9% of
  the running time of `nutation_fk5`.
- ![Enhancement][badge-enhancement] The IAU-2006 theory no longer recomputes the Julian
  centuries in each of the functions that provide the fundamental arguments and the mean
  obliquity.
- ![Info][badge-info] Several documentation fixes: signatures that did not match the code,
  generic functions that promised a `Float64` return type, and typos.

Version 1.2.0
-------------

- ![Enhancement][badge-enhancement] Data interpolations now use DataInterpolations.jl
  instead of Interpolations.jl.  (PR [#14][gh-pr-14])

Version 1.1.0
-------------

- ![Feature][badge-feature] The package now supports automatic differentiation using
  different backends. (PRs [#12][gh-pr-12])
- ![Enhancement][badge-enhancement] Some allocations were removed. (PRs [#12][gh-pr-12])

Version 1.0.0
-------------

- ![Info][badge-info] We dropped support for Julia 1.6. This version only supports the
  current Julia version and v1.10 (LTS).
- ![Info][badge-info] This version does not have breaking changes. We bump the version to
  1.0.0 because we now consider the API stable.

Version 0.1.9
-------------

- ![Feature][badge-feature] The functions to transform orbit state vectors `sv_<>_to_<>` can
  now be called without the parameters related to the epoch. In this case, the epoch of the
  state vector is used.
- ![Feature][badge-feature] The function to transform orbit representations `orb_eci_to_eci`
  can now be called without the parameters related to the epoch. In this case, the epoch of
  the orbit representation is used.
- ![Enhancement][badge-enhancement] The functions in this package are now compatible with
  automatic differentiation. (PRs [#7][gh-pr-7], [#8][gh-pr-8], [#11][gh-pr-11])

Version 0.1.8
-------------

- ![Bugfix][badge-bugfix] We fixed the compat bound of the package `Downloads` so that we
  can still use **SatelliteToolboxTransformations.jl** in Julia 1.6.

Version 0.1.7
-------------

- ![Enhancement][badge-enhancement] Minor source-code updates.
- ![Enhancement][badge-enhancement] Documentation updates.

Version 0.1.6
-------------

- ![Info][badge-info] We updated Interpolations.jl compat bounds to v0.15. Notice that v0.14
  is still supported. (PR [#4][gh-pr-4])

Version 0.1.5
-------------

- ![Enhancement][badge-enhancement] The package now supports the new format of the EOP files
  `finals.all.csv` and `finals2000A.all.csv` introduced in November 6, 2023. (PR
  [#3][gh-pr-3])

Version 0.1.4
-------------

- ![Enhancement][badge-enhancement] We updated the dependency compatibility bounds.
- ![Enhancement][badge-enhancement] We forced specialization in the function
  `sv_ecef_to_ecef`, reducing the allocations due to compilation. (PR [#2][gh-pr-2])

Version 0.1.3
-------------

- ![Feature][badge-feature] We added the functions `ecef_to_geocentric` and
  `geocentric_to_ecef` to convert between ECEF vectors and Geocentric coordinates.

Version 0.1.2
-------------

- ![Bugfix][badge-bugfix] We fixed a bug that was failing the task that builds the stable
  documentation.

Version 0.1.1
-------------

- ![Info][badge-info] The functions related to orbit anomalies were transferred to
  **SatelliteToolboxBase.jl**. These functions are re-exported here. Hence, this
  modifications is note breaking from this package point of view.

Version 0.1.0
-------------

- Initial version.
  - This version was based on the functions in **SatelliteToolbox.jl**.

[badge-breaking]: https://img.shields.io/badge/BREAKING-red.svg
[badge-deprecation]: https://img.shields.io/badge/Deprecation-orange.svg
[badge-feature]: https://img.shields.io/badge/Feature-green.svg
[badge-enhancement]: https://img.shields.io/badge/Enhancement-blue.svg
[badge-bugfix]: https://img.shields.io/badge/Bugfix-purple.svg
[badge-info]: https://img.shields.io/badge/Info-gray.svg

[gh-pr-2]: https://github.com/JuliaSpace/SatelliteToolboxTransformations.jl/pull/2
[gh-pr-3]: https://github.com/JuliaSpace/SatelliteToolboxTransformations.jl/pull/3
[gh-pr-4]: https://github.com/JuliaSpace/SatelliteToolboxTransformations.jl/pull/4
[gh-pr-7]: https://github.com/JuliaSpace/SatelliteToolboxTransformations.jl/pull/7
[gh-pr-8]: https://github.com/JuliaSpace/SatelliteToolboxTransformations.jl/pull/8
[gh-pr-11]: https://github.com/JuliaSpace/SatelliteToolboxTransformations.jl/pull/11
[gh-pr-12]: https://github.com/JuliaSpace/SatelliteToolboxTransformations.jl/pull/12
[gh-pr-14]: https://github.com/JuliaSpace/SatelliteToolboxTransformations.jl/pull/14
