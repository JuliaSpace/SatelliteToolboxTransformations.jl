## Description #############################################################################
#
# Definition of types and structures.
#
############################################################################################

export T_ECEFs, T_ECIs, T_ECIs_of_date, T_ECEFs_IAU_2006, T_ECIs_IAU_2006
export T_ECIs_IAU_2006_Equinox_of_date, T_ROT
export ITRF, PEF, TOD, MOD, GCRF, J2000, TEME, CIRS, TIRS, ERS, MOD06, MJ2000
export EopIau1980, EopIau2000A

############################################################################################
#                                     Reference Frames                                     #
############################################################################################

"""
    T_ECEFs

Union of all Earth-Centered Earth-Fixed (ECEF) frames supported by the IAU-76/FK5 theory.
"""
T_ECEFs = Union{Val{:ITRF}, Val{:PEF}}

"""
    T_ECIs

Union of all Earth-Centered Inertial (ECI) frames supported by the IAU-76/FK5 theory.
"""
T_ECIs = Union{Val{:GCRF}, Val{:J2000}, Val{:TOD}, Val{:MOD}, Val{:TEME}}

"""
    T_ECIs_of_date

Union of all *of date* Earth-Centered Inertial (ECI) frames supported by the IAU-76/FK5
theory.
"""
T_ECIs_of_date = Union{Val{:TOD}, Val{:MOD}, Val{:TEME}}

"""
    T_ECEFs_IAU_2006

Union of all Earth-Centered Earth-Fixed (ECEF) frames supported by IAU-2006/2010 theory.
"""
T_ECEFs_IAU_2006 = Union{Val{:ITRF}, Val{:TIRS}}

"""
    T_ECIs_IAU_2006_CIO

Union of all Earth-Centered Inertial (ECI) frames supported by CIO-based IAU-2006/2010
theory.
"""
T_ECIs_IAU_2006_CIO = Union{Val{:GCRF}, Val{:CIRS}}

"""
    T_ECIs_IAU_2006_Equinox

Union of all Earth-Centered Inertial (ECI) frames supported by Equinox-based IAU-2006/2010
theory.
"""
T_ECIs_IAU_2006_Equinox = Union{Val{:GCRF}, Val{:MJ2000}, Val{:MOD06}, Val{:ERS}}

"""
    T_ECIs_IAU_2006

Union of all Earth-Centered Inertial (ECI) frames supported by IAU-2006/2010 theory.
"""
T_ECIs_IAU_2006 = Union{T_ECIs_IAU_2006_CIO, T_ECIs_IAU_2006_Equinox}

"""
    T_ECIs_IAU_2006_Equinox_of_date

Union of all *of date* Earth-Centered Inertial (ECI) frames supported by the equinox-based
IAU-2006/2010 theory.
"""
T_ECIs_IAU_2006_Equinox_of_date = Union{Val{:MOD06}, Val{:ERS}}

"""
    T_ROT

Union of all supported rotation descriptions.
"""
T_ROT = Union{Type{DCM}, Type{Quaternion}}

# Auxiliary functions to define the reference frames.
@inline ITRF()   = Val(:ITRF)
@inline PEF()    = Val(:PEF)
@inline TOD()    = Val(:TOD)
@inline MOD()    = Val(:MOD)
@inline GCRF()   = Val(:GCRF)
@inline J2000()  = Val(:J2000)
@inline TEME()   = Val(:TEME)
@inline CIRS()   = Val(:CIRS)
@inline TIRS()   = Val(:TIRS)
@inline ERS()    = Val(:ERS)
@inline MOD06()  = Val(:MOD06)
@inline MJ2000() = Val(:MJ2000)

############################################################################################
#                               Earth Orientation Parameters                               #
############################################################################################

"""
    EopIau1980{T}

Earth orientation parameters for the model IAU 1980.

!!! note

    Each field will be an `AbstractInterpolation` indexed by the Julian Day.  Hence, if one
    wants to obtain, for example, the X component of the polar motion with respect to the
    crust at 19 June 2018, the following can be used:

        x[DateTime(2018, 6, 19, 0, 0, 0) |> datetime2julian]

# Fields

- `x, y`: Polar motion with respect to the crust [arcsec].
- `Δut1_utc`: Irregularities of the rotation angle [s].
- `lod`: Length of day offset [ms].
- `δΔψ, δΔϵ`: Celestial pole offsets referred to the model IAU1980 [milliarcsec].
- `*_error`: Errors in the components [same unit as the component].
"""
struct EopIau1980{T}
    x::T
    y::T
    Δut1_utc::T
    lod::T
    δΔψ::T
    δΔϵ::T

    # Errors
    x_error::T
    y_error::T
    Δut1_utc_error::T
    lod_error::T
    δΔψ_error::T
    δΔϵ_error::T
end

"""
    EopIau2000A{T}

Earth orientation parameters for the model IAU 2000A.

!!! note

    Each field will be an `AbstractInterpolation` indexed by the Julian Day.  Hence, if one
    want to obtain, for example, the X component of the polar motion with respect to the
    crust at 19 June 2018, the following can be used:

        x[DateTime(2018, 6, 19, 0, 0, 0) |> datetime2julian]

# Fields

- `x, y`: Polar motion with respect to the crust [arcsec].
- `Δut1_utc`: Irregularities of the rotation angle [s].
- `lod`: Length of day offset [ms].
- `δx, δy`: Celestial pole offsets referred to the model IAU2000A [milliarcsec].
- `*_error`: Errors in the components [same unit as the component].
"""
struct EopIau2000A{T}
    x::T
    y::T
    Δut1_utc::T
    lod::T
    δx::T
    δy::T

    # Errors
    x_error::T
    y_error::T
    Δut1_utc_error::T
    lod_error::T
    δx_error::T
    δy_error::T
end
