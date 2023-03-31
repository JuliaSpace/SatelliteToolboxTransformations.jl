module SatelliteToolboxTransformations

using Crayons
using Dates
using Downloads: download
using Interpolations
using DelimitedFiles
using ReferenceFrameRotations
using SatelliteToolboxTime
using Scratch
using StaticArrays

import Base: show

# Re-export symbols used in this package.
export DCM, Quaternion

################################################################################
#                                    Types
################################################################################

include("./types.jl")

################################################################################
#                                  Constants
################################################################################

const _B = Crayon(bold = true)
const _G = crayon"dark_gray"
const _R = Crayon(reset = true)

# Julian Day of J2000.0 epoch.
const JD_J2000 = 2451545.0

# Define the default ellipsoid based on WGS-84 [2]
const wgs84_ellipsoid = Ellipsoid(6378137.0, 1 / 298.257223563)

################################################################################
#                                   Includes
################################################################################

include("./eop/conversion.jl")
include("./eop/fetch.jl")
include("./eop/private.jl")
include("./eop/read.jl")
include("./eop/show.jl")

include("./reference_frames/ecef_to_ecef.jl")
include("./reference_frames/ecef_to_eci.jl")
include("./reference_frames/eci_to_ecef.jl")
include("./reference_frames/eci_to_eci.jl")
include("./reference_frames/geodetic_geocentric.jl")
include("./reference_frames/local_frame.jl")

include("./reference_frames/fk5/fk5.jl")
include("./reference_frames/fk5/nutation.jl")
include("./reference_frames/fk5/precession.jl")

include("./reference_frames/iau2006/cio.jl")
include("./reference_frames/iau2006/fundamental_args.jl")
include("./reference_frames/iau2006/iau2006_cio.jl")
include("./reference_frames/iau2006/iau2006_equinox.jl")
include("./reference_frames/iau2006/misc.jl")
include("./reference_frames/iau2006/nutation_eo.jl")
include("./reference_frames/iau2006/precession.jl")

include("./reference_frames/iau2006/constants/cio_s.jl")
include("./reference_frames/iau2006/constants/cip_x.jl")
include("./reference_frames/iau2006/constants/cip_y.jl")
include("./reference_frames/iau2006/constants/equation_of_origins.jl")
include("./reference_frames/iau2006/constants/nutation.jl")

include("./reference_frames/teme/teme.jl")

include("./time.jl")

end # module SatelliteToolboxTransformations
