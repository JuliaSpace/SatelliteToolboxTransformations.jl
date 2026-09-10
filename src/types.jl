## Description #############################################################################
#
# Definition of types and structures.
#
############################################################################################

export T_ECEFs, T_ECIs, T_ECIs_of_date, T_ECEFs_IAU_2006, T_ECIs_IAU_2006
export T_ECIs_IAU_2006_CIO, T_ECIs_IAU_2006_Equinox
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
const T_ECEFs = Union{Val{:ITRF}, Val{:PEF}}

"""
    T_ECIs

Union of all Earth-Centered Inertial (ECI) frames supported by the IAU-76/FK5 theory.
"""
const T_ECIs = Union{Val{:GCRF}, Val{:J2000}, Val{:TOD}, Val{:MOD}, Val{:TEME}}

"""
    T_ECIs_of_date

Union of all *of date* Earth-Centered Inertial (ECI) frames supported by the IAU-76/FK5
theory.
"""
const T_ECIs_of_date = Union{Val{:TOD}, Val{:MOD}, Val{:TEME}}

"""
    T_ECEFs_IAU_2006

Union of all Earth-Centered Earth-Fixed (ECEF) frames supported by IAU-2006/2010 theory.
"""
const T_ECEFs_IAU_2006 = Union{Val{:ITRF}, Val{:TIRS}}

"""
    T_ECIs_IAU_2006_CIO

Union of all Earth-Centered Inertial (ECI) frames supported by CIO-based IAU-2006/2010
theory.
"""
const T_ECIs_IAU_2006_CIO = Union{Val{:GCRF}, Val{:CIRS}}

"""
    T_ECIs_IAU_2006_Equinox

Union of all Earth-Centered Inertial (ECI) frames supported by Equinox-based IAU-2006/2010
theory.
"""
const T_ECIs_IAU_2006_Equinox = Union{Val{:GCRF}, Val{:MJ2000}, Val{:MOD06}, Val{:ERS}}

"""
    T_ECIs_IAU_2006

Union of all Earth-Centered Inertial (ECI) frames supported by IAU-2006/2010 theory.
"""
const T_ECIs_IAU_2006 = Union{T_ECIs_IAU_2006_CIO, T_ECIs_IAU_2006_Equinox}

"""
    T_ECIs_IAU_2006_Equinox_of_date

Union of all *of date* Earth-Centered Inertial (ECI) frames supported by the equinox-based
IAU-2006/2010 theory.
"""
const T_ECIs_IAU_2006_Equinox_of_date = Union{Val{:MOD06}, Val{:ERS}}

"""
    T_ROT

Union of all supported rotation descriptions.
"""
const T_ROT = Union{Type{DCM}, Type{Quaternion}}

"""
    ITRF() -> Val{:ITRF}

Return the tag that selects the International Terrestrial Reference Frame (ITRF) in the
reference frame transformation functions.
"""
@inline ITRF() = Val(:ITRF)

"""
    PEF() -> Val{:PEF}

Return the tag that selects the Pseudo-Earth Fixed (PEF) reference frame of the IAU-76/FK5
theory in the reference frame transformation functions.
"""
@inline PEF() = Val(:PEF)

"""
    TOD() -> Val{:TOD}

Return the tag that selects the True of Date (TOD) reference frame of the IAU-76/FK5 theory
in the reference frame transformation functions.
"""
@inline TOD() = Val(:TOD)

"""
    MOD() -> Val{:MOD}

Return the tag that selects the Mean of Date (MOD) reference frame of the IAU-76/FK5 theory
in the reference frame transformation functions.
"""
@inline MOD() = Val(:MOD)

"""
    GCRF() -> Val{:GCRF}

Return the tag that selects the Geocentric Celestial Reference Frame (GCRF) in the
reference frame transformation functions.
"""
@inline GCRF() = Val(:GCRF)

"""
    J2000() -> Val{:J2000}

Return the tag that selects the J2000 mean equator and equinox reference frame in the
reference frame transformation functions.
"""
@inline J2000() = Val(:J2000)

"""
    TEME() -> Val{:TEME}

Return the tag that selects the True Equator Mean Equinox (TEME) reference frame in the
reference frame transformation functions.
"""
@inline TEME() = Val(:TEME)

"""
    CIRS() -> Val{:CIRS}

Return the tag that selects the Celestial Intermediate Reference System (CIRS) of the
IAU-2006/2010 theory in the reference frame transformation functions.
"""
@inline CIRS() = Val(:CIRS)

"""
    TIRS() -> Val{:TIRS}

Return the tag that selects the Terrestrial Intermediate Reference System (TIRS) of the
IAU-2006/2010 theory in the reference frame transformation functions.
"""
@inline TIRS() = Val(:TIRS)

"""
    ERS() -> Val{:ERS}

Return the tag that selects the Earth Reference System (ERS) of the equinox-based
IAU-2006/2010 theory in the reference frame transformation functions.
"""
@inline ERS() = Val(:ERS)

"""
    MOD06() -> Val{:MOD06}

Return the tag that selects the Mean of Date (MOD) reference frame of the IAU-2006/2010
theory in the reference frame transformation functions.
"""
@inline MOD06() = Val(:MOD06)

"""
    MJ2000() -> Val{:MJ2000}

Return the tag that selects the J2000 mean equator and equinox reference frame of the
IAU-2006/2010 theory in the reference frame transformation functions.
"""
@inline MJ2000() = Val(:MJ2000)

############################################################################################
#                               Earth Orientation Parameters                               #
############################################################################################

"""
    struct EopIau1980{T}

Store the Earth Orientation Parameters (EOP) for the model IAU 1980.

Each field is a callable interpolation evaluated at the Julian Day [UTC], e.g.
`eop.x(jd_utc)`. The interpolation is linear inside the tabulated span and constant outside
it. The field `Δut1_utc` is continuous across the leap seconds. Hence, the X component of
the polar motion with respect to the crust at 19 June 2018 [UTC] can be obtained with:

    eop.x(datetime2julian(DateTime(2018, 6, 19, 0, 0, 0)))

# Fields

- `x::T`: X component of the polar motion with respect to the crust [arcsec].
- `y::T`: Y component of the polar motion with respect to the crust [arcsec].
- `Δut1_utc::T`: Irregularities of the rotation angle, i.e. the difference UT1-UTC [s].
- `lod::T`: Length of day offset [ms].
- `δΔψ::T`: Celestial pole offset in longitude referred to the model IAU 1980 [mas].
- `δΔϵ::T`: Celestial pole offset in obliquity referred to the model IAU 1980 [mas].
- `x_error::T`: Error in `x` [arcsec].
- `y_error::T`: Error in `y` [arcsec].
- `Δut1_utc_error::T`: Error in `Δut1_utc` [s].
- `lod_error::T`: Error in `lod` [ms].
- `δΔψ_error::T`: Error in `δΔψ` [mas].
- `δΔϵ_error::T`: Error in `δΔϵ` [mas].
"""
struct EopIau1980{T}
    x::T
    y::T
    Δut1_utc::T
    lod::T
    δΔψ::T
    δΔϵ::T

    # Errors in the components above.
    x_error::T
    y_error::T
    Δut1_utc_error::T
    lod_error::T
    δΔψ_error::T
    δΔϵ_error::T
end

"""
    struct EopIau2000A{T}

Store the Earth Orientation Parameters (EOP) for the model IAU 2000A.

Each field is a callable interpolation evaluated at the Julian Day [UTC], e.g.
`eop.x(jd_utc)`. The interpolation is linear inside the tabulated span and constant outside
it. The field `Δut1_utc` is continuous across the leap seconds. Hence, the X component of
the polar motion with respect to the crust at 19 June 2018 [UTC] can be obtained with:

    eop.x(datetime2julian(DateTime(2018, 6, 19, 0, 0, 0)))

# Fields

- `x::T`: X component of the polar motion with respect to the crust [arcsec].
- `y::T`: Y component of the polar motion with respect to the crust [arcsec].
- `Δut1_utc::T`: Irregularities of the rotation angle, i.e. the difference UT1-UTC [s].
- `lod::T`: Length of day offset [ms].
- `δx::T`: X component of the celestial pole offset referred to the model IAU 2000A [mas].
- `δy::T`: Y component of the celestial pole offset referred to the model IAU 2000A [mas].
- `x_error::T`: Error in `x` [arcsec].
- `y_error::T`: Error in `y` [arcsec].
- `Δut1_utc_error::T`: Error in `Δut1_utc` [s].
- `lod_error::T`: Error in `lod` [ms].
- `δx_error::T`: Error in `δx` [mas].
- `δy_error::T`: Error in `δy` [mas].
"""
struct EopIau2000A{T}
    x::T
    y::T
    Δut1_utc::T
    lod::T
    δx::T
    δy::T

    # Errors in the components above.
    x_error::T
    y_error::T
    Δut1_utc_error::T
    lod_error::T
    δx_error::T
    δy_error::T
end
