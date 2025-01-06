using Test

using Dates
using LinearAlgebra
using Logging
using ReferenceFrameRotations
using SatelliteToolboxBase
using SatelliteToolboxTransformations
using Scratch
using StaticArrays

using DifferentiationInterface
using FiniteDiff, ForwardDiff, Enzyme, Mooncake, PolyesterForwardDiff, Zygote

using JET
using AllocCheck
using Aqua

@testset "Earth Orientation Parameters" verbose = true begin
    cd("./eop")
    include("./eop/read.jl")
    include("./eop/fetch.jl")
    include("./eop/show.jl")
    cd("..")
end

@testset "Reference Frame Transformations" verbose = true begin
    cd("./reference_frames")

    @testset "IAU-76 / FK5 Theory" verbose = true begin
        cd("./fk5")
        include("./reference_frames/fk5/nutation.jl")
        include("./reference_frames/fk5/precession.jl")
        include("./reference_frames/fk5/fk5.jl")
        cd("..")
    end

    @testset "IAU 2006 / 2010A Theory (CIO-based)" verbose = true begin
        cd("./iau2006")
        include("./reference_frames/iau2006/cio.jl")
        include("./reference_frames/iau2006/precession.jl")
        include("./reference_frames/iau2006/iau2006_cio.jl")
        cd("..")
    end

    @testset "IAU 2006 / 2010A Theory (Equinox-based)" verbose = true begin
        cd("iau2006/")
        include("./reference_frames/iau2006/nutation_eo.jl")
        include("./reference_frames/iau2006/iau2006_equinox.jl")
        cd("..")
    end

    @testset "True Equator, Mean Equinox (TEME)" verbose = true begin
        cd("teme/")
        include("./reference_frames/teme/teme.jl")
        cd("..")
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

    cd("..")
end

@testset "Orbit Transformations" verbose = true begin
    cd("./orbit")
    include("./orbit/orb_eci_to_eci.jl")
    include("./orbit/sv_ecef_to_ecef.jl")
    include("./orbit/sv_ecef_to_eci.jl")
    include("./orbit/sv_eci_to_ecef.jl")
    include("./orbit/sv_eci_to_eci.jl")
    cd("..")
end

@testset "Time" verbose = true begin
    include("./time.jl")
end

const _BACKENDS = (
    ("ForwardDiff", AutoForwardDiff()),
    ("Enzyme", AutoEnzyme()),
    ("Mooncake", AutoMooncake(;config=nothing)),
    ("PolyesterForwardDiff", AutoPolyesterForwardDiff()),
    ("Zygote", AutoZygote()),
)

@testset "Automatic Differentiation" verbose = true begin
    include("./differentiability/eop.jl")
    include("./differentiability/reference_frames.jl")
    include("./differentiability/time.jl")
end

@testset "Performace Allocations and Type Stability" verbose = true begin
    include("./performance.jl")
end