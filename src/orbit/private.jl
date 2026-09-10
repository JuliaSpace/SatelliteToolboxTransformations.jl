## Description #############################################################################
#
# Private functions shared by the orbit state vector conversions.
#
############################################################################################

"""
    _rotate_state_vector(sv::OrbitStateVector, D::DCM) -> OrbitStateVector

Rotate the position, velocity, and acceleration of the orbit state vector `sv` by the DCM
`D`, keeping the epoch. This function must be used only between frames without a
significant relative angular velocity, since no kinematic term is added.
"""
function _rotate_state_vector(sv::OrbitStateVector, D::DCM)
    return OrbitStateVector(sv.t, D * sv.r, D * sv.v, D * sv.a)
end

"""
    _earth_rotation_rate(jd_utc::Number, eop::Union{Nothing, EopIau1980, EopIau2000A}) -> Number

Return the Earth angular speed [rad/s] at the Julian Day `jd_utc` [UTC], corrected by the
length of day of the EOP data `eop` when it is available.
"""
_earth_rotation_rate(jd_utc::Number, ::Nothing) = EARTH_ANGULAR_SPEED

function _earth_rotation_rate(jd_utc::Number, eop::Union{EopIau1980, EopIau2000A})
    return EARTH_ANGULAR_SPEED * (1 - eop.lod(jd_utc) / _MILLISECONDS_PER_DAY)
end

"""
    _sv_rotating_to_inertial(sv::OrbitStateVector, D::DCM, ω::Number) -> OrbitStateVector

Convert the orbit state vector `sv`, represented in a frame that rotates about its Z-axis
with angular speed `ω` [rad/s], to the inertial frame reached by the DCM `D`. The velocity
and the acceleration are corrected by the kinematic terms of the axial rotation.
"""
function _sv_rotating_to_inertial(sv::OrbitStateVector, D::DCM, ω::Number)
    vω = SVector{3}(0, 0, ω)

    # Compute the position in the inertial frame.
    r_i = D * sv.r

    # Compute the velocity in the inertial frame.
    vω_x_r = vω × sv.r
    v_i    = D * (sv.v + vω_x_r)

    # Compute the acceleration in the inertial frame.
    a_i = D * (sv.a + vω × vω_x_r + 2vω × sv.v)

    return OrbitStateVector(sv.t, r_i, v_i, a_i)
end

"""
    _sv_inertial_to_rotating(sv::OrbitStateVector, D::DCM, ω::Number) -> OrbitStateVector

Convert the orbit state vector `sv`, represented in an inertial frame, to the frame reached
by the DCM `D`, which rotates about its Z-axis with angular speed `ω` [rad/s]. The velocity
and the acceleration are corrected by the kinematic terms of the axial rotation.
"""
function _sv_inertial_to_rotating(sv::OrbitStateVector, D::DCM, ω::Number)
    vω = SVector{3}(0, 0, ω)

    # Compute the position in the rotating frame.
    r_r = D * sv.r

    # Compute the velocity in the rotating frame.
    vω_x_r = vω × r_r
    v_r    = D * sv.v - vω_x_r

    # Compute the acceleration in the rotating frame.
    a_r = D * sv.a - vω × vω_x_r - 2vω × v_r

    return OrbitStateVector(sv.t, r_r, v_r, a_r)
end
