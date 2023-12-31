Transformations between ECEF and ECI reference frames
=====================================================

```@meta
CurrentModule = SatelliteToolboxTransformations
DocTestSetup = quote
    using SatelliteToolboxTransformations
end
```

This package currently provides two models to transform reference systems: the IAU-76/FK5
and the IAU-2006/2010 (CIO and Equinox-based approach). The following table lists the
available coordinate frames and how they can be referenced in the functions that will be
described later on.

| Reference  | Type |            Coordinate frame name             |
|------------|------|----------------------------------------------|
| `ITRF()`   | ECEF | International terrestrial reference frame    |
| `PEF()`    | ECEF | Pseudo-earth fixed reference frame           |
| `TIRS()`   | ECEF | Terrestrial intermediate reference system    |
| `ERS()`    | ECEF | Earth reference system                       | 
| `MOD()`    | ECI  | Mean-of-date reference frame                 | 
| `TOD()`    | ECI  | True-of-data reference frame                 | 
| `GCRF()`   | ECI  | Geocentric celestial reference frame (GCRF)  | 
| `J2000()`  | ECI  | J2000 reference frame                        |
| `TEME()`   | ECI  | True equator, mean equinox reference frame   |
| `CIRS()`   | ECI  | Celestial intermediate reference system      |
| `MOD06()`  | ECI  | Mean-of-date reference frame (IAU-2006/2010) |
| `MJ2000()` | ECI  | J2000 mean equatorial frame                  |

!!! note
    ECEF stands for Earth-Centered, Earth-Fixed whereas ECI stands for Earth-Centered
    Inertial.

!!! warning
    In all the functions that will be presented here, it is not possible to mix frames
    between the IAU-76/FK5 and IAU-2006/2010 models in the same call.  Hence, if it is
    required to compute the rotation between frames in different models, then the
    recommended approach is to first compute the rotation from the origin frame to the ITRF
    or GCRF, and then compute the rotation from the ITRF or GCRF to the destination frame.
    However, this will only work for past dates since the Earth orientation parameters are
    required.

## Earth orientation parameters (EOP)

Some conversions here requires additional data related to the Earth orientation.  This
information is provided by [IERS](https://www.iers.org) (International Earth Rotation and
Reference Systems Service). This package has the capability to automatically download and
parse the IERS EOP (Earth Orientation Parameters).

The function that will automatically download the files, store them in the package [scratch
space](https://github.com/JuliaPackaging/Scratch.jl), and parse the data is:

```julia
fetch_iers_eop([data_type]; kwargs...)
```

in which `data_type` specifies what EOP type is desired (`Val(:IAU1980)` for IAU1980 and
`Val(:IAU2000A)` for IAU2000A). If omitted, then it defaults to `Val(:IAU1980)`.

This function returns an instance of the structure [`EopIau1980`](@ref) or
[`EopIau2000A`](@ref) depending on the selection of `data_type`. The returned value should
be passed to the reference frame conversion functions as described in the following.
  
The following keywords are available:

- `force_download::Bool`: If the EOP file exists and is less than 7 days old, it will not be
    downloaded again. A new download can be forced by setting this keyword to `true`.
    (**Default** = `false`)
- `url::String`: URL of the EOP file.

```jldoctest ECEF_ECI
julia> eop_iau1980 = fetch_iers_eop();
[ Info: Downloading the file 'finals.all.csv' from 'https://datacenter.iers.org/data/csv/finals.all.csv'...

julia> eop_iau2000a = fetch_iers_eop(Val(:IAU2000A));
[ Info: Downloading the file 'finals2000A.all.csv' from 'https://datacenter.iers.org/data/csv/finals2000A.all.csv'...
```

## ECEF to ECEF

One ECEF frame can be converted to another one by the following function:

```julia
function r_ecef_to_ecef([T,] ECEFo, ECEFf, JD_UTC::Number, eop)
```

where it will be computed the rotation from the ECEF reference frame `ECEFo` to the ECEF
reference frame `ECEFf` at the Julian Day [UTC] `JD_UTC`. The rotation description that will
be used is given by `T`, which can be `DCM` or `Quaternion`. If `T` is omitted, then it
defaults to `DCM`. The `eop` in this case is always necessary. Hence, the user must
initialize it as described in the section [Earth orientation parameters (EOP)](@ref).

```jldoctest ECEF_ECI
julia> r_ecef_to_ecef(PEF(), ITRF(), date_to_jd(1986, 6, 19, 21, 35, 0), eop_iau1980)
DCM{Float64}:
  1.0          0.0         -4.34677e-7
 -6.29476e-13  1.0         -1.44815e-6
  4.34677e-7   1.44815e-6   1.0

julia> r_ecef_to_ecef(TIRS(), ITRF(), date_to_jd(1986, 6, 19, 21, 35, 0), eop_iau2000a)
DCM{Float64}:
  1.0          3.08408e-11  -4.34677e-7
 -3.14703e-11  1.0          -1.44815e-6
  4.34677e-7   1.44815e-6    1.0

julia> r_ecef_to_ecef(Quaternion, PEF(), ITRF(), date_to_jd(1986, 6, 19, 21, 35, 0), eop_iau1980)
Quaternion{Float64}:
  + 1.0 - 7.24073e-7⋅i + 2.17339e-7⋅j - 0.0⋅k

julia> r_ecef_to_ecef(Quaternion, TIRS(), ITRF(), date_to_jd(1986, 6, 19, 21, 35, 0), eop_iau2000a)
Quaternion{Float64}:
  + 1.0 - 7.24073e-7⋅i + 2.17339e-7⋅j + 1.55778e-11⋅k
```

## ECI to ECI

One ECI frame can be converted to another ECI frame by one of the following functions:

```julia
function r_eci_to_eci([T,] ECIo, ECIf, JD_UTC::Number[, eop])
function r_eci_to_eci([T,] ECIo, JD_UTCo::Number, ECIf, JD_UTCf::Number[, eop])
```

where it will be computed compute the rotation from the ECI reference frame `ECIo` to
another ECI reference frame `ECIf`. If the origin and destination frame contain only one *of
date* frame, then the first signature is used and `JD_UTC` is the epoch of this frame. On
the other hand, if the origin and destination frame contain two *of date* frame[^1], e.g.
`TOD => MOD`, then the second signature must be used in which `JD_UTCo` is the epoch of the
origin frame and `JD_UTCf` is the epoch of the destination frame. The rotation description
that will be used is given by `T`, which can be `DCM` or `Quaternion`. If `T` is omitted,
then it defaults to `DCM`. The EOP data `eop_data`, as described in section [Earth
orientation parameters (EOP)](@ref), is required in some conversions, as described in the
following table.

[^1]: TEME is an *of date* frame.

|   Model                     |   ECIo   |   ECIf   |    EOP Data   | Function Signature |
|:----------------------------|:---------|:---------|:--------------|:-------------------|
| IAU-76/FK5                  | `GCRF`   | `J2000`  | EOP IAU1980   | First              |
| IAU-76/FK5                  | `GCRF`   | `MOD`    | EOP IAU1980   | First              |
| IAU-76/FK5                  | `GCRF`   | `TOD`    | EOP IAU1980   | First              |
| IAU-76/FK5                  | `GCRF`   | `TEME`   | EOP IAU1980   | First              |
| IAU-76/FK5                  | `J2000`  | `GCRF`   | EOP IAU1980   | First              |
| IAU-76/FK5                  | `J2000`  | `MOD`    | Not required  | First              |
| IAU-76/FK5                  | `J2000`  | `TOD`    | Not required  | First              |
| IAU-76/FK5                  | `J2000`  | `TEME`   | Not required  | First              |
| IAU-76/FK5                  | `MOD`    | `GCRF`   | EOP IAU1980   | First              |
| IAU-76/FK5                  | `MOD`    | `J2000`  | Not required  | First              |
| IAU-76/FK5                  | `MOD`    | `TOD`    | Not required  | Second             |
| IAU-76/FK5                  | `MOD`    | `TEME`   | Not required  | Second             |
| IAU-76/FK5                  | `TOD`    | `GCRF`   | EOP IAU1980   | First              |
| IAU-76/FK5                  | `TOD`    | `J2000`  | Not required  | First              |
| IAU-76/FK5                  | `TOD`    | `MOD`    | Not required  | Second             |
| IAU-76/FK5                  | `TOD`    | `TEME`   | Not required  | Second             |
| IAU-76/FK5                  | `TEME`   | `GCRF`   | EOP IAU1980   | First              |
| IAU-76/FK5                  | `TEME`   | `J2000`  | Not required  | First              |
| IAU-76/FK5                  | `TEME`   | `MOD`    | Not required  | Second             |
| IAU-76/FK5                  | `TEME`   | `TOD`    | Not required  | Second             |
| IAU-2006/2010 CIO-based     | `GCRF`   | `CIRS`   | Not required¹ | First              |
| IAU-2006/2010 CIO-based     | `CIRS`   | `CIRS`   | Not required¹ | Second             |
| IAU-2006/2010 Equinox-based | `GCRF`   | `MJ2000` | Not required  | First²             |
| IAU-2006/2010 Equinox-based | `GCRF`   | `MOD06`  | Not required  | First              |
| IAU-2006/2010 Equinox-based | `GCRF`   | `ERS`    | Not required³ | First              |
| IAU-2006/2010 Equinox-based | `MJ2000` | `GCRF`   | Not required  | First²             |
| IAU-2006/2010 Equinox-based | `MJ2000` | `MOD06`  | Not required  | First              |
| IAU-2006/2010 Equinox-based | `MJ2000` | `ERS`    | Not required³ | First              |
| IAU-2006/2010 Equinox-based | `MOD06`  | `GCRF`   | Not required  | First              |
| IAU-2006/2010 Equinox-based | `MOD06`  | `MJ2000` | Not required  | First              |
| IAU-2006/2010 Equinox-based | `MOD06`  | `ERS`    | Not required³ | First              |
| IAU-2006/2010 Equinox-based | `ERS`    | `GCRF`   | Not required³ | First              |
| IAU-2006/2010 Equinox-based | `ERS`    | `MJ2000` | Not required³ | First              |
| IAU-2006/2010 Equinox-based | `ERS`    | `MOD06`  | Not required³ | First              |

`¹`: In this case, the terms that account for the free-core nutation and time dependent
effects of the Celestial Intermediate Pole (CIP) position with respect to the GCRF will not
be available, reducing the precision.

`²`: The transformation between GCRF and MJ2000 is a constant rotation matrix called bias.
Hence, the date does not modify it. However, this signature was kept to avoid complications
in the API.

`³`: In this case, the terms that corrects the nutation in obliquity and in longitude due to
the free core nutation will not be available, reducing the precision.

!!! note
    In this function, if EOP corrections are not provided, then MOD and TOD frames will be
    computed considering the original IAU-76/FK5 theory.  Otherwise, the corrected frame
    will be used.

```jldoctest ECEF_ECI
julia> r_eci_to_eci(DCM, GCRF(), J2000(), date_to_jd(1986, 6, 19, 21, 35, 0), eop_iau1980)
DCM{Float64}:
  1.0          -4.71326e-12   1.53474e-9
  4.71332e-12   1.0          -3.53979e-9
 -1.53474e-9    3.53979e-9    1.0

julia> r_eci_to_eci(
            Quaternion,
            TEME(),
            GCRF(),
            date_to_jd(1986, 6, 19, 21, 35, 0),
            eop_iau1980
        )
Quaternion{Float64}:
  + 0.999999 + 1.83013e-5⋅i + 0.000665304⋅j - 0.00151324⋅k

julia> r_eci_to_eci(
            TOD(),
            date_to_jd(1986, 6, 19, 21, 35, 0),
            TOD(),
            date_to_jd(1987, 5, 19 , 3, 0, 0),
            eop_iau1980
        )
DCM{Float64}:
 1.0          -0.000224088  -9.73787e-5
 0.000224087   1.0          -5.80065e-6
 9.738e-5      5.77883e-6    1.0

julia> r_eci_to_eci(
            Quaternion,
            TOD(),
            2451545.0,
            MOD(),
            2451545.0,
            eop_iau1980
        )
Quaternion{Float64}:
  + 1.0 - 1.40025e-5⋅i + 1.34736e-5⋅j - 3.10785e-5⋅k

julia> r_eci_to_eci(
            J2000(),
            TEME(),
            date_to_jd(1986, 6, 19, 21, 35, 0)
        )
DCM{Float64}:
  0.999995    0.0030265    0.00133055
 -0.00302645  0.999995    -3.86125e-5
 -0.00133066  3.45854e-5   0.999999

julia> r_eci_to_eci(
            CIRS(),
            GCRF(),
            date_to_jd(1986, 6, 19, 21, 35, 0),
            eop_iau2000a
        )
DCM{Float64}:
 0.999999     3.88389e-8  -0.00133066
 7.18837e-9   1.0          3.45897e-5
 0.00133066  -3.45897e-5   0.999999

julia> r_eci_to_eci(
            Quaternion,
            CIRS(),
            GCRF(),
            date_to_jd(1986, 6, 19, 21, 35, 0),
            eop_iau2000a
        )
Quaternion{Float64}:
  + 1.0 + 1.72949e-5⋅i + 0.000665332⋅j + 7.91263e-9⋅k

julia> r_eci_to_eci(
            DCM,
            GCRF(),
            J2000(),
            date_to_jd(1986, 6, 19, 21, 35, 0),
            eop_iau1980
        )
DCM{Float64}:
  1.0          -4.71326e-12   1.53474e-9
  4.71332e-12   1.0          -3.53979e-9
 -1.53474e-9    3.53979e-9    1.0
```

## ECEF to ECI

One ECEF frame can be convert to one ECI frame using the following function:

```julia
function r_ecef_to_eci([T,] ECEF, ECI, JD_UTC::Number[, eop])
```

where it will be compute the rotation from the ECEF frame `ECEF` to the ECI frame `ECI` at
the Julian Day [UTC] `JD_UTC`. The rotation description that will be used is given by `T`,
which can be `DCM` or `Quaternion`. If it is omitted, then it defaults to `DCM`. The EOP
data `eop_data`, as described in section [Earth orientation parameters (EOP)](@ref), is
required in some conversions, as described in the following table.

|   Model                     |  ECEF  |   ECI    |    EOP Data     |
|:----------------------------|:-------|:---------|:----------------|
| IAU-76/FK5                  | `ITRF` | `GCRF`   | EOP IAU1980     |
| IAU-76/FK5                  | `ITRF` | `J2000`  | EOP IAU1980     |
| IAU-76/FK5                  | `ITRF` | `MOD`    | EOP IAU1980     |
| IAU-76/FK5                  | `ITRF` | `TOD`    | EOP IAU1980     |
| IAU-76/FK5                  | `ITRF` | `TEME`   | EOP IAU1980     |
| IAU-76/FK5                  | `PEF`  | `GCRF`   | EOP IAU1980     |
| IAU-76/FK5                  | `PEF`  | `J2000`  | Not required¹   |
| IAU-76/FK5                  | `PEF`  | `MOD`    | Not required¹   |
| IAU-76/FK5                  | `PEF`  | `TOD`    | Not required¹   |
| IAU-76/FK5                  | `PEF`  | `TEME`   | Not required¹   |
| IAU-2006/2010 CIO-based     | `ITRF` | `CIRS`   | EOP IAU2000A    |
| IAU-2006/2010 CIO-based     | `ITRF` | `GCRF`   | EOP IAU2000A    |
| IAU-2006/2010 CIO-based     | `TIRS` | `CIRS`   | Not required¹   |
| IAU-2006/2010 CIO-based     | `TIRS` | `GCRF`   | Not required¹ ² |
| IAU-2006/2010 Equinox-based | `ITRF` | `ERS`    | EOP IAU2000A    |
| IAU-2006/2010 Equinox-based | `ITRF` | `MOD06`  | EOP IAU2000A    |
| IAU-2006/2010 Equinox-based | `ITRF` | `MJ2000` | EOP IAU2000A    |
| IAU-2006/2010 Equinox-based | `TIRS` | `ERS`    | Not required¹ ³ |
| IAU-2006/2010 Equinox-based | `TIRS` | `MOD06`  | Not required¹ ³ |
| IAU-2006/2010 Equinox-based | `TIRS` | `MJ2000` | Not required¹ ³ |

`¹`: In this case, UTC will be assumed equal to UT1 to compute the Greenwich Mean Sidereal
Time. This is an approximation, but should be sufficiently accurate for some applications.
Notice that, if EOP Data is provided, UT1 will be accurately computed.

`²`: In this case, the terms that account for the free core nutation and time dependent
effects of the Celestial Intermediate Pole (CIP) position with respect to the GCRF will not
be available, reducing the precision.

`³`: In this case, the terms that corrects the nutation in obliquity and in longitude due to
the free core nutation will not be available, reducing the precision.

!!! note
    In this function, if EOP corrections are not provided, then MOD and TOD frames will be
    computed considering the original IAU-76/FK5 theory.  Otherwise, the corrected frame
    will be used.

```jldoctest ECEF_ECI
julia> r_ecef_to_eci(DCM, ITRF(), GCRF(), date_to_jd(1986, 06, 19, 21, 35, 0), eop_iau1980)
DCM{Float64}:
 -0.619267      0.78518     -0.00132979
 -0.78518      -0.619267     3.33509e-5
 -0.000797312   0.00106478   0.999999

julia> r_ecef_to_eci(ITRF(), GCRF(), date_to_jd(1986, 06, 19, 21, 35, 0), eop_iau1980)
DCM{Float64}:
 -0.619267      0.78518     -0.00132979
 -0.78518      -0.619267     3.33509e-5
 -0.000797312   0.00106478   0.999999

julia> r_ecef_to_eci(PEF(), J2000(), date_to_jd(1986, 06, 19, 21, 35, 0))
DCM{Float64}:
 -0.619271      0.785176    -0.00133066
 -0.785177     -0.619272     3.45854e-5
 -0.000796885   0.00106622   0.999999

julia> r_ecef_to_eci(PEF(), J2000(), date_to_jd(1986, 06, 19, 21, 35, 0), eop_iau1980)
DCM{Float64}:
 -0.619267      0.78518     -0.00133066
 -0.78518      -0.619267     3.45854e-5
 -0.000796879   0.00106623   0.999999

julia> r_ecef_to_eci(Quaternion, ITRF(), GCRF(), date_to_jd(1986, 06, 19, 21, 35, 0), eop_iau1980)
Quaternion{Float64}:
  + 0.43631 - 0.000590997⋅i + 0.000305106⋅j + 0.899796⋅k

julia> r_ecef_to_eci(ITRF(), GCRF(), date_to_jd(1986, 06, 19, 21, 35, 0), eop_iau2000a)
DCM{Float64}:
 -0.619267      0.78518     -0.00132979
 -0.78518      -0.619267     3.33516e-5
 -0.000797311   0.00106478   0.999999

julia> r_ecef_to_eci(TIRS(), GCRF(), date_to_jd(1986, 06, 19, 21, 35, 0))
DCM{Float64}:
 -0.619271      0.785176    -0.00133066
 -0.785177     -0.619272     3.45884e-5
 -0.000796885   0.00106623   0.999999

julia> r_ecef_to_eci(Quaternion, ITRF(), GCRF(), date_to_jd(1986, 06, 19, 21, 35, 0), eop_iau2000a)
Quaternion{Float64}:
  + 0.43631 - 0.000590997⋅i + 0.000305106⋅j + 0.899796⋅k
```

# ECI to ECEF

One ECI frame can be converted to one ECEF frame using the following function:

```julia
function r_eci_to_ecef([T,] ECI, ECEF, JD_UTC::Number[, eop])
```

which has the same characteristics of the function [`r_ecef_to_eci`](@ref) described in
Section [ECEF to ECI](@ref), but with the inputs `ECI`  and `ECEF` swapped.

!!! note
    This function actually calls [`r_ecef_to_eci`](@ref) first and then uses `inv_rotation`.
    Hence, it has a slightly overhead on top of [`r_ecef_to_eci`](@ref), which should be
    negligible for both rotation representations that are supported.

```jldoctest ECEF_ECI
julia> r_eci_to_ecef(DCM, GCRF(), ITRF(), date_to_jd(1986, 06, 19, 21, 35, 0), eop_iau1980)
DCM{Float64}:
 -0.619267    -0.78518     -0.000797312
  0.78518     -0.619267     0.00106478
 -0.00132979   3.33509e-5   0.999999

julia> r_eci_to_ecef(GCRF(), ITRF(), date_to_jd(1986, 06, 19, 21, 35, 0), eop_iau1980)
DCM{Float64}:
 -0.619267    -0.78518     -0.000797312
  0.78518     -0.619267     0.00106478
 -0.00132979   3.33509e-5   0.999999

julia> r_eci_to_ecef(J2000(), PEF(), date_to_jd(1986, 06, 19, 21, 35, 0))
DCM{Float64}:
 -0.619271    -0.785177    -0.000796885
  0.785176    -0.619272     0.00106622
 -0.00133066   3.45854e-5   0.999999

julia> r_eci_to_ecef(J2000(), PEF(), date_to_jd(1986, 06, 19, 21, 35, 0), eop_iau1980)
DCM{Float64}:
 -0.619267    -0.78518     -0.000796879
  0.78518     -0.619267     0.00106623
 -0.00133066   3.45854e-5   0.999999

julia> r_eci_to_ecef(Quaternion, GCRF(), ITRF(), date_to_jd(1986, 06, 19, 21, 35, 0), eop_iau1980)
Quaternion{Float64}:
  + 0.43631 + 0.000590997⋅i - 0.000305106⋅j - 0.899796⋅k

julia> r_eci_to_ecef(GCRF(), ITRF(), date_to_jd(1986, 06, 19, 21, 35, 0), eop_iau2000a)
DCM{Float64}:
 -0.619267    -0.78518     -0.000797311
  0.78518     -0.619267     0.00106478
 -0.00132979   3.33516e-5   0.999999

julia> r_eci_to_ecef(GCRF(), TIRS(), date_to_jd(1986, 06, 19, 21, 35, 0))
DCM{Float64}:
 -0.619271    -0.785177    -0.000796885
  0.785176    -0.619272     0.00106623
 -0.00133066   3.45884e-5   0.999999

julia> r_eci_to_ecef(Quaternion, GCRF(), ITRF(), date_to_jd(1986, 06, 19, 21, 35, 0), eop_iau2000a)
Quaternion{Float64}:
  + 0.43631 + 0.000590997⋅i - 0.000305106⋅j - 0.899796⋅k
```
