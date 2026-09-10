SatelliteToolboxTransformations.jl Changelog
============================================

Version 1.3.0
-------------

- ![Feature][badge-feature] Add `r_eci_to_hill` and `r_hill_to_eci` to compute the rotation
  between an Earth-Centered Inertial (ECI) frame and the satellite Hill frame (also known as
  RSW or RTN) as a `DCM` or a `Quaternion`, from the ECI position and velocity or from an
  `OrbitStateVector`. The functions throw an `ArgumentError` if the state does not define an
  orbital plane.
- ![Feature][badge-feature] Add `r_eci_to_lvlh` and `r_lvlh_to_eci` to compute the rotation
  between an ECI frame and the Local Vertical, Local Horizontal (LVLH) frame, whose X-axis
  is the along-track direction, Z-axis is the nadir direction, and Y-axis completes the
  right-handed frame. The LVLH frame is an axis permutation of the Hill frame, so both are
  built from the same orthonormal triad.
- ![Enhancement][badge-enhancement] `geodetic_to_geocentric` obtains the geocentric latitude
  with `atan` instead of `asin`, which is accurate near the poles and cannot throw a
  `DomainError`.
- ![Enhancement][badge-enhancement] `geocentric_to_geodetic` and `geodetic_to_geocentric`
  now promote their inputs with the ellipsoid parameter type, so that both returned values
  always have the same floating-point type.
- ![Enhancement][badge-enhancement] The IAU-1980 nutation coefficients are kept in a
  transposed copy, making the coefficients of each term contiguous. This is worth about 9%
  of the running time of `nutation_fk5`.
- ![Enhancement][badge-enhancement] The IAU-2006 theory no longer recomputes the Julian
  centuries in each of the functions that provide the fundamental arguments and the mean
  obliquity.
- ![Enhancement][badge-enhancement] The identity methods of `r_ecef_to_ecef` now return a
  rotation with the floating-point type of the epoch instead of always `Float64`, and they
  are restricted to the frames supported by each theory. Calling them with an unsupported
  frame, or with a mismatch between the theory and the EOP data, now throws a `MethodError`
  instead of returning the identity.
- ![Enhancement][badge-enhancement] The IAU-76/FK5 nutation and the IAU-2006 series no
  longer widen `Float32` inputs to `Float64` when applying the unit conversion factors, and
  the effective number of nutation terms is bound to an `Int` instead of a union type.
- ![Enhancement][badge-enhancement] The rotations between the PEF, TEME, TOD, and MOD frames
  evaluate the IAU-76/FK5 nutation series once and reuse its Delaunay argument in the 1982
  equation of the equinoxes instead of recomputing it.
- ![Enhancement][badge-enhancement] Single-axis rotations are built directly instead of as
  three-angle sequences with two zero angles, the Earth Rotation Angle is computed by one
  helper, and the CIRS => TIRS and GCRF => CIRS rotations are obtained by inverting their
  counterparts.
- ![Enhancement][badge-enhancement] The PEF => ITRF and TIRS => ITRF conversions in
  `r_ecef_to_ecef` call the direct rotations instead of inverting the forward ones. The PEF
  case changes the off-diagonal elements of the DCM by about 6e-13, because the small-angle
  rotation is orthonormalized before instead of after the transposition.
- ![Enhancement][badge-enhancement] The leap-safe EOP interpolation of UT1-UTC now returns
  the same type inside and outside the tabulated span for any epoch type, and the
  interpolation wrapper no longer stores redundant copies of the knots and end values.
- ![Bugfix][badge-bugfix] `compute_δΔϵ_δΔψ` returned the nutation in longitude correction
  with the wrong sign. The function inverts the system in IERS Technical Note No. 36,
  eq. 5.25, whose determinant is `1 + aux²`, but it used `sin(ϵ₀) ⋅ (aux² - 1)`. This
  affected the equinox-based IAU-2006 transformations that consume the correction, namely
  ITRF and TIRS against ERS, MOD06, and MJ2000, by a few centimetres on the Earth's surface.
- ![Bugfix][badge-bugfix] `geocentric_to_geodetic` returned `NaN` on the polar axis, where
  the algorithm divides by the vanishing equatorial component. It also threw a `DomainError`
  from inside `sqrt` when the geocentric latitude was slightly beyond ±π/2, which is the
  case for `Float32(π) / 2`. Both cases now return the exact polar solution.
- ![Bugfix][badge-bugfix] The fifth-order coefficient of the CIO locator polynomial in
  `cio_iau2006` was 15.65e-6 arcsec, whereas IERS Technical Note No. 36 (Table 5.2d) and
  SOFA give 15.62e-6 arcsec. The effect is below 1e-7 arcsec for one century away from
  J2000.0.
- ![Bugfix][badge-bugfix] `read_iers_eop` now throws a descriptive `ArgumentError` when the
  IERS file does not have 33 or 37 columns, when a field has no valid value, or when the MJD
  column has a missing value inside the tabulated span. Previously, those files were parsed
  from wrong columns or silently produced `NaN` interpolations.
- ![Info][badge-info] Several documentation fixes: signatures that did not match the code,
  generic functions that promised a `Float64` return type, typos, a wrong frame in the
  description of the value returned by `sv_eci_to_ecef`, and a wrong row in its conversion
  table.
- ![Info][badge-info] All docstrings and comments now follow the package documentation
  template, including the units and time scales of every quantity, the exact `# Extended
  help` header, and docstrings for the reference frame tags such as `ITRF()`.
- ![Info][badge-info] The unit conversion factors, the IERS EOP parsers, the `show` methods
  of the EOP data, and the kernels of the orbit state vector conversions are now shared
  private implementations instead of being duplicated across the package.
- ![Info][badge-info] The package now supports DataInterpolations.jl v10.
  (PR [#27][gh-pr-27])

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

[badge-breaking]: https://img.shields.io/badge/Breaking-DC2626?style=flat-square
[badge-deprecation]: https://img.shields.io/badge/Deprecation-D97706?style=flat-square
[badge-feature]: https://img.shields.io/badge/Feature-16A34A?style=flat-square
[badge-enhancement]: https://img.shields.io/badge/Enhancement-0284C7?style=flat-square
[badge-bugfix]: https://img.shields.io/badge/Bugfix-DB2777?style=flat-square
[badge-info]: https://img.shields.io/badge/Info-475569?style=flat-square

[gh-pr-2]: https://github.com/JuliaSpace/SatelliteToolboxTransformations.jl/pull/2
[gh-pr-3]: https://github.com/JuliaSpace/SatelliteToolboxTransformations.jl/pull/3
[gh-pr-4]: https://github.com/JuliaSpace/SatelliteToolboxTransformations.jl/pull/4
[gh-pr-7]: https://github.com/JuliaSpace/SatelliteToolboxTransformations.jl/pull/7
[gh-pr-8]: https://github.com/JuliaSpace/SatelliteToolboxTransformations.jl/pull/8
[gh-pr-11]: https://github.com/JuliaSpace/SatelliteToolboxTransformations.jl/pull/11
[gh-pr-12]: https://github.com/JuliaSpace/SatelliteToolboxTransformations.jl/pull/12
[gh-pr-14]: https://github.com/JuliaSpace/SatelliteToolboxTransformations.jl/pull/14
[gh-pr-27]: https://github.com/JuliaSpace/SatelliteToolboxTransformations.jl/pull/27
