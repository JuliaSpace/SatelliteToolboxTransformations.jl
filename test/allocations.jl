@testset "JET Testing" begin
    rep = JET.test_package(SatelliteToolboxTransformations; toplevel_logger=nothing, target_modules=(@__MODULE__,))
end

