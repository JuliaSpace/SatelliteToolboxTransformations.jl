SatelliteToolboxTransformations.jl Changelog
============================================

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
