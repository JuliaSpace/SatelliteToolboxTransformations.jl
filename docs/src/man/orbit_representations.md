# Transformations of Orbit Representations

```@meta
CurrentModule = SatelliteToolboxTransformations
```

```@setup transformation_orbit
using SatelliteToolboxTransformations
```

## Orbit State Vector

We provide a set of functions to transform an `OrbitStateVector` between any frame described
in [Transformations Between ECEF and ECI Reference Frames](@ref).

### From ECI to ECI

The function

```julia
sv_eci_to_eci(sv::OrbitStateVector, args...) -> OrbitStateVector
```

can be used to transform the `OrbitStateVector` `sv` from one ECI frame to another. The
arguments `args...` must match those of the function [`r_eci_to_eci`](@ref) **without** the
rotation representation.

The following example shows how we can convert a state vector from the MOD (Mean of Date)
reference frame to the TOD (True of Date) reference frame:

```@repl transformation_orbit
jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)

r_mod  = [5094.02837450; 6127.87081640; 6380.24851640]

v_mod  = [-4.7462630520; 0.7860140450; 5.5317905620]

sv_mod = OrbitStateVector(jd_utc, r_mod, v_mod)

sv_tod = sv_eci_to_eci(sv_mod, MOD(), jd_utc, TOD(), jd_utc)
```

### From ECI to ECEF

The function

```julia
sv_eci_to_ecef(sv::OrbitStateVector, ECI, ECEF, jd_utc[, eop]) -> OrbitStateVector
```

can be used to convert the orbit state vector `sv` from the Earth-Centered Inertial (ECI)
reference frame `ECI` to the Earth-Centered, Earth-Fixed (ECEF) reference frame at the
Julian day `jd_utc` [UTC]. The `eop` may be required depending on the selection of the input
and output reference system. For more information, see the documentation of the function
[`r_eci_to_ecef`](@ref).

!!! info

    It is assumed that the input velocity and acceleration in `sv` are obtained by an
    observer on the ECI frame. Thus, the output will contain the velocity and acceleration
    as measured by an observer on the ECEF frame.

The following example shows how we can convert a state vector from the J2000 reference frame
reference frame to PEF (True of Date) reference frame:

```@repl transformation_orbit
jd_ut1 = date_to_jd(2004, 4, 6, 7, 51, 28.386009) - 0.4399619 / 86400

r_j2000  = [5102.50960000; 6123.01152000; 6378.13630000]

v_j2000  = [-4.7432196000; 0.7905366000; 5.5337561900]

sv_j2000 = OrbitStateVector(jd_ut1, r_j2000, v_j2000)

sv_pef   = sv_eci_to_ecef(sv_j2000, J2000(), PEF(), jd_ut1)
```

### From ECEF to ECI

The function

```julia
sv_ecef_to_eci(sv::OrbitStateVector, ECEF, ECI, jd_utc[, eop]) -> OrbitStateVector
```

can be used to convert the orbit state vector `sv` from the Earth-Centered, Earth-Fixed
(ECEF) reference frame `ECEF` to the Earth-Centered Inertial (ECI) reference frame at the
Julian day `jd_utc` [UTC]. The `eop` may be required depending on the selection of the input
and output reference system. For more information, see the documentation of the function
[`r_ecef_to_eci`](@ref).

!!! info

    It is assumed that the input velocity and acceleration in `sv` are obtained by an
    observer on the ECEF frame. Thus, the output will contain the velocity and acceleration
    as measured by an observer on the ECI frame.

The following example shows how we can convert a state vector from the PEF reference frame
reference frame to J2000 reference frame:

```@repl transformation_orbit
jd_ut1 = date_to_jd(2004, 4, 6, 7, 51, 28.386009) - 0.4399619 / 86400

r_pef = [-1033.47503130; 7901.30558560; 6380.34453270]

v_pef = [-3.2256327470; -2.8724425110; +5.5319312880]

sv_pef   = OrbitStateVector(jd_ut1, r_pef, v_pef)

sv_j2000 = sv_ecef_to_eci(sv_pef, PEF(), J2000(), jd_ut1)
```

### From ECEF to ECEF

The function

```julia
sv_ecef_to_ecef(sv::OrbitStateVector, args...) -> OrbitStateVector
```

can be used to transform the orbit state vector `sv` from an ECEF frame to another ECEF
frame. The arguments `args...` must match those of the function [`r_ecef_to_ecef`](@ref)
**wihtout** the rotation representation.

The following example shows how we can convert a state vector from the ITRF reference frame
reference frame to PEF reference frame:

```@repl transformation_orbit
eop_iau1980 = fetch_iers_eop()

jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)

r_itrf = [-1033.4793830; 7901.2952754; 6380.3565958]

v_itrf = [-3.225636520; -2.872451450; +5.531924446]

sv_itrf = OrbitStateVector(jd_utc, r_itrf, v_itrf)

sv_pef = sv_ecef_to_ecef(sv_itrf, ITRF(), PEF(), jd_utc, eop_iau1980)
```
