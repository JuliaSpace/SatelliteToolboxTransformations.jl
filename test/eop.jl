## Description #############################################################################
#
# Tests related to the EOP data.
#
############################################################################################

using DataInterpolations

@testset "EOP UT1-UTC leap-boundary interpolation" begin
    leap = date_to_jd(2017, 1, 1)
    data = zeros(2, 37)
    data[:, 1] = [leap - 2400000.5 - 1, leap - 2400000.5]
    data[:, 15] = [-0.4, 0.6]

    eop = SatelliteToolboxTransformations._parse_iers_eop_iau_1980(data)
    @test hasproperty(eop.x, :u)
    @test hasproperty(eop.lod, :u)
    @test :u in propertynames(eop.x)
    @test :t in propertynames(eop.x)
    @test typeof(eop.x) === typeof(eop.Δut1_utc)
    @test typeof(eop.x) !== Any
    @test eop.x isa DataInterpolations.AbstractInterpolation
    @test eop.Δut1_utc isa DataInterpolations.AbstractInterpolation
    @test eop.Δut1_utc(leap - 0.5) ≈ -0.4 atol = 1e-12
    @test eop.Δut1_utc(leap) ≈ 0.6 atol = 1e-12
end
