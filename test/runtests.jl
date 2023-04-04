using Test

using LinearAlgebra
using ReferenceFrameRotations
using SatelliteToolboxBase
using SatelliteToolboxTransformations
using StaticArrays

@testset "IAU-76 / FK5 theory" verbose = true begin
    include("./fk5/nutation.jl")
    include("./fk5/precession.jl")
    include("./fk5/fk5.jl")
end

@testset "IAU 2006 / 2010A theory (CIO-based)" verbose = true begin
    include("./iau2006/cio.jl")
    include("./iau2006/precession.jl")
    include("./iau2006/iau2006_cio.jl")
end

@testset "IAU 2006 / 2010A theory (Equinox-based)" verbose = true begin
    include("./iau2006/nutation_eo.jl")
    include("./iau2006/iau2006_equinox.jl")
end

@testset "True Equator, Mean Equinox (TEME)" verbose = true begin
    include("./teme/teme.jl")
end

@testset "Conversions ECEF <=> ECI" verbose = true begin
    include("./ecef_to_ecef.jl")
    include("./ecef_to_eci.jl")
    include("./eci_to_ecef.jl")
    include("./eci_to_eci.jl")
end

@testset "Conversions ECEF <=> Local frames" verbose = true begin
    include("./local_frame.jl")
end

@testset "Conversions Geodetic <=> Geocentric" verbose = true begin
    include("./geodetic_geocentric.jl")
end

@testset "Time" verbose = true begin
    include("./time.jl")
end
