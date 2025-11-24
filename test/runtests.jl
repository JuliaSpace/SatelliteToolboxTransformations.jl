using Test

using Dates
using LinearAlgebra
using Logging
using ReferenceFrameRotations
using SatelliteToolboxBase
using SatelliteToolboxTransformations
using Scratch
using StaticArrays

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

if isempty(VERSION.prerelease)
    # Add Mooncake and Enzyme to the project if not the nightly version
    # Adding them via the Project.toml isn't working because it tries to compile them before reaching the gating
    using Pkg
    Pkg.add("DifferentiationInterface")
    Pkg.add("FiniteDiff")
    Pkg.add("ForwardDiff")
    Pkg.add("Mooncake")
    Pkg.add("PolyesterForwardDiff")
    Pkg.add("Zygote")

    Pkg.add("JET")
    Pkg.add("AllocCheck")
    Pkg.add("Aqua")

    if (VERSION.major == 1 && VERSION.minor < 12)
        Pkg.add("Enzyme")
        # Test with Mooncake and Enzyme along with the other backends
        using DifferentiationInterface
        using Enzyme, FiniteDiff, ForwardDiff, Mooncake, PolyesterForwardDiff, Zygote
        const _BACKENDS = (
            ("ForwardDiff", AutoForwardDiff()),
            ("Enzyme", AutoEnzyme(; function_annotation=Enzyme.Const)),
            ("Mooncake", AutoMooncake(;config=nothing)),
            ("PolyesterForwardDiff", AutoPolyesterForwardDiff()),
            ("Zygote", AutoZygote()),
        )
    else
        @warn "Enzyme is not fully supported on Julia 1.12, skipping tests"
        using DifferentiationInterface
        using FiniteDiff, ForwardDiff, Mooncake, PolyesterForwardDiff, Zygote
        const _BACKENDS = (
            ("ForwardDiff", AutoForwardDiff()),
            ("Mooncake", AutoMooncake(;config=nothing)),
            ("PolyesterForwardDiff", AutoPolyesterForwardDiff()),
            ("Zygote", AutoZygote()),
        )
    end

    @testset "Automatic Differentiation" verbose = true begin
        include("./differentiability/eop.jl")
        include("./differentiability/reference_frames.jl")
        include("./differentiability/time.jl")
    end

    using JET
    using AllocCheck
    using Aqua

    @testset "Performace Allocations and Type Stability" verbose = true begin
        include("./performance.jl")
    end
else
    @warn "Differentiation backends not guaranteed to work on julia-nightly, skipping tests"
    @warn "Performance checks not guaranteed to work on julia-nightly, skipping tests"
end
