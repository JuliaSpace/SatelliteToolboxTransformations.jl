# ECI and Satellite Local Frames

```@meta
CurrentModule = SatelliteToolboxTransformations
```

```@setup eci_local_frames
using SatelliteToolboxTransformations
```

This package provides functions to compute the rotation between an Earth-Centered Inertial
(ECI) reference frame and two satellite-centered local frames: the Hill frame (also known
as RSW or RTN) and the Local Vertical, Local Horizontal (LVLH) frame. Both frames are
defined by the satellite position and velocity represented in the ECI frame, and both share
the orbital plane. The along-track axis is aligned with the velocity vector only in circular
orbits; in general, it is the direction in the orbital plane that is perpendicular to the
radial direction and positive toward the direction of motion.

All the functions in this page can return a Direction Cosine Matrix (`DCM`) or a
`Quaternion`. The rotation description is selected by the first argument `T`. If `T` is
omitted, then it defaults to `DCM`. The state can be provided as the position and velocity
vectors or as an `OrbitStateVector`.

!!! note

    The functions throw an `ArgumentError` if the position and velocity vectors are parallel
    or if any of them is zero, since the frames are undefined in this case.

## Hill Frame (RSW / RTN)

The Hill frame is centered at the satellite and its axes are defined as follows:

- The X axis (R) points along the radial direction, from the Earth's center to the
  satellite;
- The Y axis (S) points along the along-track direction; and
- The Z axis (W) points along the orbit angular momentum vector, completing the
  right-handed frame.

The rotations between an ECI frame and the Hill frame are computed by:

```julia
r_eci_to_hill([T, ]r_eci::AbstractVector, v_eci::AbstractVector) -> T
r_eci_to_hill([T, ]sv::OrbitStateVector) -> T
r_hill_to_eci([T, ]r_eci::AbstractVector, v_eci::AbstractVector) -> T
r_hill_to_eci([T, ]sv::OrbitStateVector) -> T
```

where `r_eci` [m] and `v_eci` [m/s] are the satellite position and velocity represented in
the ECI frame, or `sv` is the orbit state vector whose position and velocity are represented
in the ECI frame.

```@repl eci_local_frames
r_eci = [3e6, 4e6, 0.0];

v_eci = [-1e3, 2e3, 2e3];

D_hill_eci = r_eci_to_hill(r_eci, v_eci)

D_hill_eci * r_eci

r_eci_to_hill(Quaternion, r_eci, v_eci)

sv = OrbitStateVector(0.0, r_eci, v_eci);

r_eci_to_hill(sv)

r_hill_to_eci(r_eci, v_eci)
```

## LVLH Frame

The LVLH frame is centered at the satellite and its axes are defined as follows:

- The X axis points along the along-track direction;
- The Y axis points opposite to the orbit angular momentum vector, completing the
  right-handed frame; and
- The Z axis points along the nadir direction, from the satellite to the Earth's center.

Hence, the LVLH frame is a permutation of the Hill frame axes: `x_lvlh = y_hill`,
`y_lvlh = -z_hill`, and `z_lvlh = -x_hill`.

The rotations between an ECI frame and the LVLH frame are computed by:

```julia
r_eci_to_lvlh([T, ]r_eci::AbstractVector, v_eci::AbstractVector) -> T
r_eci_to_lvlh([T, ]sv::OrbitStateVector) -> T
r_lvlh_to_eci([T, ]r_eci::AbstractVector, v_eci::AbstractVector) -> T
r_lvlh_to_eci([T, ]sv::OrbitStateVector) -> T
```

where the arguments have the same meaning as in the Hill frame functions.

```@repl eci_local_frames
D_lvlh_eci = r_eci_to_lvlh(r_eci, v_eci)

D_lvlh_eci * r_eci

r_eci_to_lvlh(Quaternion, r_eci, v_eci)

r_eci_to_lvlh(sv)

r_lvlh_to_eci(r_eci, v_eci)
```
