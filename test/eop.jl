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
    @test eop.x.t === eop.x.interpolation.t
    value_before_leap = @inferred eop.Δut1_utc(leap - 0.5)
    value_at_leap = @inferred eop.Δut1_utc(leap)
    @test value_before_leap ≈ -0.4 atol = 1e-12
    @test value_at_leap ≈ 0.6 atol = 1e-12
end

@testset "EOP celestial pole offsets use UTC lookup and TT polynomial epoch" begin
    eop = read_iers_eop("../eop_IAU2000A.txt", Val(:IAU2000A))
    jd_utc = date_to_jd(2004, 4, 6, 7, 51, 28.386009)
    jd_tt = jd_utc_to_tt(jd_utc)

    d2r = π / 180
    a2r = d2r / 3600
    δx = eop.δx(jd_utc)
    δy = eop.δy(jd_utc)
    T = (jd_tt - SatelliteToolboxTransformations.JD_J2000) / 36525
    Ψ = @evalpoly(T, 0, 5038.47875, -1.07259, -0.001147) * a2r
    χ = @evalpoly(T, 0, 10.5526, -2.38064, -0.001125) * a2r
    sϵ₀, cϵ₀ = sincos(84381.406 * a2r)
    aux = Ψ * cϵ₀ - χ
    den = aux^2 * sϵ₀ - sϵ₀
    expected = (
        (aux * sϵ₀ * δx - sϵ₀ * δy) / den,
        (δx - aux * δy) / den,
    )

    got = compute_δΔϵ_δΔψ(eop, jd_utc)
    @test got[1] ≈ expected[1]
    @test got[2] ≈ expected[2]
end
