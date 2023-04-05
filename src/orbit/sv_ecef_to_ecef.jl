# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==========================================================================================
#
#   Convert an orbit state vector from an Earth-Centered, Earth-Fixed (ECEF) reference frame
#   to another ECEF reference frame.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# References
# ==========================================================================================
#
#   [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm
#       Press, Hawthorn, CA, USA.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export sv_ecef_to_ecef

"""
    sv_ecef_to_ecef(sv::OrbitStateVector, args...) -> OrbitStateVector

Convert the orbit state vector `sv` from an ECEF frame to another ECEF frame.  The arguments
`args...` must match those of the function [`r_ecef_to_ecef`](@ref) **wihtout** the rotation
representation.
"""
function sv_ecef_to_ecef(sv::OrbitStateVector, args...)
    D = r_ecef_to_ecef(DCM, args...)

    # Since both frames does not have a significant angular velocity between
    # them, then we just need to convert the representations.
    return OrbitStateVector(sv.t, D * sv.r, D * sv.v, D * sv.a)
end
