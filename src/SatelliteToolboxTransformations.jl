module SatelliteToolboxTransformations

using Crayons
using Dates
using DelimitedFiles
using Downloads: download
using DataInterpolations
using LinearAlgebra
using ReferenceFrameRotations
using Reexport
using Scratch
using StaticArrays

@reexport using SatelliteToolboxBase

import Base: show

# Re-export symbols used in this package.
export DCM, Quaternion

############################################################################################
#                                          Types                                           #
############################################################################################

include("./types.jl")

############################################################################################
#                                        Constants                                         #
############################################################################################

const _CRAYON_BOLD      = Crayon(bold = true)
const _CRAYON_DARK_GRAY = crayon"dark_gray"
const _CRAYON_RESET     = Crayon(reset = true)

############################################################################################
#                                         Includes                                         #
############################################################################################

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

include("./orbit/orb_eci_to_eci.jl")
include("./orbit/sv_ecef_to_ecef.jl")
include("./orbit/sv_ecef_to_eci.jl")
include("./orbit/sv_eci_to_ecef.jl")
include("./orbit/sv_eci_to_eci.jl")

include("./time.jl")

end # module SatelliteToolboxTransformations
