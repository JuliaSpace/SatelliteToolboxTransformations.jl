# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==========================================================================================
#
#   Convert an orbit representation from an Earth-Centered Inertial (ECI) reference frame to
#   another ECI reference frame.
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

export orb_eci_to_eci

"""
    orb_eci_to_eci(orb::T, args...) where T<:Orbit -> T

Convert the orbit representation `orb` from an ECI frame to another ECI frame. The arguments
`args...` must match those of the function [`r_eci_to_eci`](@ref) **without** the rotation
representation.
"""
function orb_eci_to_eci(orb::Orbit, args...)
    # First, we need to convert to state vector.
    sv_o = convert(OrbitStateVector, orb)
    r_o  = sv_o.r
    v_o  = sv_o.v
    a_o  = sv_o.a

    # NOTE: In my benchmarks, the operation with DCMs are faster than with quaternions after
    # the DCM representation was changed to `SMatrix`.
    D_ecif_ecio = r_eci_to_eci(DCM, args...)
    r_f         = D_ecif_ecio * r_o
    v_f         = D_ecif_ecio * v_o
    a_f         = D_ecif_ecio * a_o

    # Create the new state vector that will be converted to an entity with the type `T`.
    sv_f = OrbitStateVector(sv_o.t, r_f, v_f, a_f)

    return convert(T, sv_f)
end
