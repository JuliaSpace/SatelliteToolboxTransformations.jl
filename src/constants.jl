## Description #############################################################################
#
# Private constants used throughout the package.
#
############################################################################################

# == Crayons ===============================================================================

const _CRAYON_BOLD      = Crayon(; bold = true)
const _CRAYON_DARK_GRAY = crayon"dark_gray"
const _CRAYON_RESET     = Crayon(; reset = true)

# == Unit Conversion Factors ===============================================================

# NOTE: These factors are `Float64`. They are meant for quantities that are already
# `Float64`, such as the EOP data and the coefficient tables. Generic code paths must
# convert them to the working type first to avoid widening `Float32` or dual numbers.

const _ARCSEC_TO_DEG      = 1 / 3600                    # ................... [deg / arcsec]
const _ARCSEC_TO_RAD      = π / 648_000                 # ................... [rad / arcsec]
const _MILLIARCSEC_TO_RAD = _ARCSEC_TO_RAD / 1000       # ...................... [rad / mas]
const _RAD_TO_ARCSEC      = 1 / _ARCSEC_TO_RAD          # ................... [arcsec / rad]

# == Epochs and Time =======================================================================

const _MJD_EPOCH_JD         = 2_400_000.5               # .. JD of 1858-11-17T00:00:00 [day]
const _MILLISECONDS_PER_DAY = 86_400_000                # ....................... [ms / day]

# == IAU-2006 Theory =======================================================================

# Mean obliquity of the ecliptic at J2000.0 [rad] (IERS Technical Note No. 36, eq. 5.40).
const _OBLIQUITY_J2000_IAU2006 = 84381.406 * _ARCSEC_TO_RAD
