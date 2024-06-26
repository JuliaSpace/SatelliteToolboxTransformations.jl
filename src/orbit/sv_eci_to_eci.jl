## Description #############################################################################
#
# Convert an orbit state vector from an Earth-Centered Inertial (ECI) reference frame to
# another ECI reference frame.
#
## References ##############################################################################
#
# [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm Press,
#     Hawthorn, CA, USA.
#
############################################################################################

export sv_eci_to_eci

"""
    sv_eci_to_eci(sv::OrbitStateVector, args...) -> OrbitStateVector

Convert the orbit state vector `sv` from an ECI frame to another ECI frame. The arguments
`args...` must match those of the function [`r_eci_to_eci`](@ref) **without** the rotation
representation.
"""
function sv_eci_to_eci(sv::OrbitStateVector, args...)
    D = r_eci_to_eci(DCM, args...)

    # Since both frames does not have a significant angular velocity between
    # them, then we just need to convert the representations.
    return OrbitStateVector(sv.t, D * sv.r, D * sv.v, D * sv.a)
end
