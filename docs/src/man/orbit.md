Transformations of Orbit Representations
========================================

```@meta
CurrentModule = SatelliteToolboxTransformations
DocTestSetup = quote
    using SatelliteToolboxBase
    using SatelliteToolboxTransformations
end
```

## Orbit State Vector

We provide a set of functions to transform an `OrbitStateVector` between any frame described
in [Transformations between ECEF and ECI reference frames](@ref).

### From ECI to ECI

The function

```julia
function sv_eci_to_eci(sv::OrbitStateVector, args...) -> OrbitStateVector
```

can be used to transform the `OrbitStateVector` `sv` from one ECI frame to another. The
arguments `args...` must match those of the function [`r_eci_to_eci`](@ref) **without** the
rotation representation.

The following example shows how we can convert a state vector from the MOD (Mean of Date)
reference frame to the TOD (True of Date) reference frame:

```jldoctest
julia> jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
2.453101827411875e6

julia> r_mod  = [5094.02837450; 6127.87081640; 6380.24851640]
3-element Vector{Float64}:
 5094.0283745
 6127.8708164
 6380.2485164

julia> v_mod  = [-4.7462630520; 0.7860140450; 5.5317905620]
3-element Vector{Float64}:
 -4.746263052
  0.786014045
  5.531790562

julia> sv_mod = OrbitStateVector(jd_utc, r_mod, v_mod)
OrbitStateVector{Float64, Float64}:
  epoch : 2.4531e6 (2004-04-06T07:51:28.386)
      r : [5.09403, 6.12787, 6.38025]             km
      v : [-0.00474626, 0.000786014, 0.00553179]  km/s

julia> sv_tod = sv_eci_to_eci(sv_mod, MOD(), jd_utc, TOD(), jd_utc)
OrbitStateVector{Float64, Float64}:
  epoch : 2.4531e6 (2004-04-06T07:51:28.386)
      r : [5.09451, 6.12737, 6.38035]             km
      v : [-0.00474609, 0.000786077, 0.00553193]  km/s
```

### From ECI to ECEF

The function

```julia
function sv_eci_to_ecef(sv::OrbitStateVector, ECI, ECEF, jd_utc[, eop]) -> OrbitStateVector
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

```jldoctest
julia> jd_ut1 = date_to_jd(2004,4,6,7,51,28.386009) - 0.4399619/86400
2.453101827406783e6

julia> r_j2000  = [5102.50960000; 6123.01152000; 6378.13630000]
3-element Vector{Float64}:
 5102.5096
 6123.01152
 6378.1363

julia> v_j2000  = [-4.7432196000; 0.7905366000; 5.5337561900]
3-element Vector{Float64}:
 -4.7432196
  0.7905366
  5.53375619

julia> sv_j2000 = OrbitStateVector(jd_ut1, r_j2000, v_j2000)
OrbitStateVector{Float64, Float64}:
  epoch : 2.4531e6 (2004-04-06T07:51:27.946)
      r : [5.10251, 6.12301, 6.37814]             km
      v : [-0.00474322, 0.000790537, 0.00553376]  km/s

julia> sv_pef   = sv_eci_to_ecef(sv_j2000, J2000(), PEF(), jd_ut1)
OrbitStateVector{Float64, Float64}:
  epoch : 2.4531e6 (2004-04-06T07:51:27.946)
      r : [-1.03348, 7.90131, 6.38034]            km
      v : [-0.00322563, -0.00287244, 0.00553193]  km/s
```

### From ECEF to ECI

The function

```julia
function sv_ecef_to_eci(sv::OrbitStateVector, ECEF, ECI, jd_utc[, eop]) -> OrbitStateVector
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

```jldoctest
julia> jd_ut1 = date_to_jd(2004,4,6,7,51,28.386009) - 0.4399619/86400
2.453101827406783e6

julia> r_pef    = [-1033.47503130; 7901.30558560; 6380.34453270]
3-element Vector{Float64}:
 -1033.4750313
  7901.3055856
  6380.3445327

julia> v_pef    = [-3.2256327470; -2.8724425110; +5.5319312880]
3-element Vector{Float64}:
 -3.225632747
 -2.872442511
  5.531931288

julia> sv_pef   = OrbitStateVector(jd_ut1, r_pef, v_pef)
OrbitStateVector{Float64, Float64}:
  epoch : 2.4531e6 (2004-04-06T07:51:27.946)
      r : [-1.03348, 7.90131, 6.38034]            km
      v : [-0.00322563, -0.00287244, 0.00553193]  km/s

julia> sv_j2000 = sv_ecef_to_eci(sv_pef, PEF(), J2000(), jd_ut1)
OrbitStateVector{Float64, Float64}:
  epoch : 2.4531e6 (2004-04-06T07:51:27.946)
      r : [5.10251, 6.12301, 6.37814]             km
      v : [-0.00474322, 0.000790537, 0.00553376]  km/s
```

### From ECEF to ECEF

The function

```julia
function sv_ecef_to_ecef(sv::OrbitStateVector, args...) -> OrbitStateVector
```

can be used to transform the orbit state vector `sv` from an ECEF frame to another ECEF
frame. The arguments `args...` must match those of the function [`r_ecef_to_ecef`](@ref)
**wihtout** the rotation representation.

The following example shows how we can convert a state vector from the ITRF reference frame
reference frame to PEF reference frame:

```julia-repl
julia> eop_iau1980 = fetch_iers_eop()
EopIau1980:
     Data │ Timespan
 ─────────┼──────────────────────────────────────────────
        x │ 1973-01-02T00:00:00 -- 2024-03-30T00:00:00
        y │ 1973-01-02T00:00:00 -- 2024-03-30T00:00:00
  UT1-UTC │ 1973-01-02T00:00:00 -- 2024-03-30T00:00:00
      LOD │ 1973-01-02T00:00:00 -- 2023-03-22T00:00:00
      δΔψ │ 1973-01-02T00:00:00 -- 2023-06-08T00:00:00
      δΔϵ │ 1973-01-02T00:00:00 -- 2023-06-08T00:00:00

julia> r_itrf  = [-1033.4793830; 7901.2952754; 6380.3565958]
3-element Vector{Float64}:
 -1033.479383
  7901.2952754
  6380.3565958

julia> v_itrf  = [-3.225636520; -2.872451450; +5.531924446]
3-element Vector{Float64}:
 -3.22563652
 -2.87245145
  5.531924446

julia> sv_itrf = OrbitStateVector(JD_UTC, r_itrf, v_itrf)
OrbitStateVector{Float64, Float64}:
  epoch : 2.4531e6 (2004-04-06T07:51:28.386)
      r : [-1.03348, 7.9013, 6.38036]             km
      v : [-0.00322564, -0.00287245, 0.00553192]  km/s

julia> sv_pef  = sv_ecef_to_ecef(sv_itrf, ITRF(), PEF(), JD_UTC, eop_iau1980)
OrbitStateVector{Float64, Float64}:
  epoch : 2.4531e6 (2004-04-06T07:51:28.386)
      r : [-1.03348, 7.90131, 6.38034]            km
      v : [-0.00322563, -0.00287244, 0.00553193]  km/s
```
