## Description #############################################################################
#
# Convert an orbit state vector from an Earth-Centered Inertial (ECI) reference frame to an
# Earth-Centered, Earth-Fixed (ECEF) reference frame.
#
## References ##############################################################################
#
# [1] Vallado, D. A (2013). Fundamentals of Astrodynamics and Applications. Microcosm Press,
#     Hawthorn, CA, USA.
#
############################################################################################

export sv_eci_to_ecef

"""
    sv_eci_to_ecef(sv::OrbitStateVector, ECI, ECEF, jd_utc[, eop]) -> OrbitStateVector

Convert the orbit state vector `sv` from the Earth-Centered Inertial (ECI) reference frame
`ECI` to the Earth-Centered, Earth-Fixed (ECEF) reference frame at the Julian day `jd_utc`
[UTC]. The `eop` may be required depending on the selection of the input and output
reference system. For more information, see the documentation of the function
[`r_eci_to_ecef`](@ref).

!!! info

    It is assumed that the input velocity and acceleration in `sv` are obtained by an
    observer on the ECI frame. Thus, the output will contain the velocity and acceleration
    as measured by an observer on the ECEF frame.
"""
function sv_eci_to_ecef(
    sv::OrbitStateVector,
    T_ECI::T_ECIs,
    T_ECEF::Val{:ITRF},
    jd_utc::Number,
    eop::EopIau1980
)
    # First, convert from ECI to PEF.
    sv_pef = sv_eci_to_ecef(sv, T_ECI, Val(:PEF), jd_utc, eop)

    # Now, convert from PEF to ITRF.
    return sv_ecef_to_ecef(sv_pef, Val(:PEF), Val(:ITRF), jd_utc, eop)
end

function sv_eci_to_ecef(
    sv::OrbitStateVector,
    T_ECI::T_ECIs_IAU_2006,
    T_ECEF::Val{:ITRF},
    jd_utc::Number,
    eop::EopIau2000A
)
    # First, convert from ECI to TIRS.
    sv_tirs = sv_eci_to_ecef(sv, T_ECI, Val(:TIRS), jd_utc, eop)

    # Now, convert from TIRS to ITRF.
    return sv_ecef_to_ecef(sv_tirs, Val(:TIRS), Val(:ITRF), jd_utc, eop)
end

function sv_eci_to_ecef(
    sv::OrbitStateVector,
    T_ECI::Union{T_ECIs, T_ECIs_IAU_2006},
    T_ECEF::Union{Val{:PEF}, Val{:TIRS}},
    jd_utc::Number,
    eop::Union{Nothing, EopIau1980, EopIau2000A} = nothing
)
    # Get the matrix that converts the ECI to the ECEF.
    if eop === nothing
        D = r_eci_to_ecef(DCM, T_ECI, T_ECEF, jd_utc)
    else
        D = r_eci_to_ecef(DCM, T_ECI, T_ECEF, jd_utc, eop)
    end

    # Since the ECI and ECEF frames have a relative velocity between them, then we must
    # account from it when converting the velocity and acceleration. The angular velocity
    # between those frames is computed using `we` and corrected by the length of day (LOD)
    # parameter of the EOP data, if available.
    ω  = EARTH_ANGULAR_SPEED * (1 - (eop !== nothing ? eop.lod(jd_utc) / 86400000 : 0))
    vω = SVector{3}(0, 0, ω)

    # Compute the position in the ECEF frame.
    r_ecef = D * sv.r

    # Compute the velocity in the ECEF frame.
    vω_x_r = vω × r_ecef
    v_ecef = D * sv.v - vω_x_r

    # Compute the acceleration in the ECI frame.
    a_ecef = D * sv.a - vω × vω_x_r - 2vω × v_ecef

    return OrbitStateVector(sv.t, r_ecef, v_ecef, a_ecef)
end
