using Test

using LinearAlgebra
using ReferenceFrameRotations
using SatelliteToolboxBase
using SatelliteToolboxTransformations
using StaticArrays

@testset "Earth Orientation Parameters" verbose = true begin
    cd("./eop")
    include("./eop/read.jl")
    cd("../")
end

@testset "Reference Frame Transformations" verbose = true begin
    @testset "IAU-76 / FK5 Theory" verbose = true begin
        include("./reference_frames/fk5/nutation.jl")
        include("./reference_frames/fk5/precession.jl")
        include("./reference_frames/fk5/fk5.jl")
    end

    @testset "IAU 2006 / 2010A Theory (CIO-based)" verbose = true begin
        include("./reference_frames/iau2006/cio.jl")
        include("./reference_frames/iau2006/precession.jl")
        include("./reference_frames/iau2006/iau2006_cio.jl")
    end

    @testset "IAU 2006 / 2010A Theory (Equinox-based)" verbose = true begin
        include("./reference_frames/iau2006/nutation_eo.jl")
        include("./reference_frames/iau2006/iau2006_equinox.jl")
    end

    @testset "True Equator, Mean Equinox (TEME)" verbose = true begin
        include("./reference_frames/teme/teme.jl")
    end

    @testset "Conversions ECEF <=> ECI" verbose = true begin
        include("./reference_frames/ecef_to_ecef.jl")
        include("./reference_frames/ecef_to_eci.jl")
        include("./reference_frames/eci_to_ecef.jl")
        include("./reference_frames/eci_to_eci.jl")
    end

    @testset "Conversions ECEF <=> Local frames" verbose = true begin
        include("./reference_frames/local_frame.jl")
    end

    @testset "Conversions Geodetic <=> Geocentric" verbose = true begin
        include("./reference_frames/geodetic_geocentric.jl")
    end
end

@testset "Orbit Transformations" verbose = true begin
    include("./orbit/sv_ecef_to_ecef.jl")
    include("./orbit/sv_ecef_to_eci.jl")
    include("./orbit/sv_eci_to_ecef.jl")
    include("./orbit/sv_eci_to_eci.jl")
end

@testset "Time" verbose = true begin
    include("./time.jl")
end
