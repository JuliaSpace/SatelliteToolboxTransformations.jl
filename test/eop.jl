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

    eop = SatelliteToolboxTransformations._parse_iers_eop(EopIau1980, data)
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

    δΔϵ, δΔΨ = compute_δΔϵ_δΔψ(eop, jd_utc)

    # The returned corrections must satisfy [1](eq. 5.25), which is the relation the function
    # inverts. Checking the *forward* direction is what makes this test meaningful: it fails
    # if the inversion picks the wrong sign, which merely re-deriving the closed-form
    # expression here would not catch.
    #
    # [1] IERS (2010). IERS Technical Note No. 36, Chapter 5.
    @test δΔΨ * sϵ₀ + aux * δΔϵ ≈ δx
    @test δΔϵ - aux * δΔΨ * sϵ₀ ≈ δy

    # `aux` is of the order of 1e-3, so the first-order relation must hold to about that
    # relative accuracy. This pins down the sign and the scaling by `sin(ϵ₀)`.
    @test δΔΨ ≈ δx / sϵ₀ rtol = 1e-2
    @test δΔϵ ≈ δy rtol = 1e-2

    # The corrections are returned in the same unit as the EOP pole offsets
    # (milliarcseconds), and the TT epoch may be supplied by the caller.
    @test compute_δΔϵ_δΔψ(eop, jd_utc, jd_tt) == (δΔϵ, δΔΨ)
end

@testset "EOP matrix width validation" begin
    data = zeros(2, 35)
    data[:, 1] = [59000.0, 59001.0]
    @test_throws ArgumentError SatelliteToolboxTransformations._parse_iers_eop(
        EopIau1980, data
    )
    @test_throws ArgumentError SatelliteToolboxTransformations._parse_iers_eop(
        EopIau2000A, data
    )
end

@testset "EOP field validation" begin
    knots = [2.4e6, 2.4e6 + 1, 2.4e6 + 2]

    # A field without any valid value is rejected with a message that does not point to an
    # index, since there is no gap to report.
    field = [NaN, NaN, NaN]
    err = try
        SatelliteToolboxTransformations._create_iers_eop_interpolation(knots, field)
        nothing
    catch e
        e
    end
    @test err isa ArgumentError
    @test !occursin("index", err.msg)

    # A gap in the middle of the field is rejected.
    @test_throws ArgumentError SatelliteToolboxTransformations._create_iers_eop_interpolation(
        knots, [1.0, NaN, 3.0]
    )

    # A missing knot inside the tabulated span is rejected, but a trailing one is tolerated
    # when the field is also missing there.
    @test_throws ArgumentError SatelliteToolboxTransformations._create_iers_eop_interpolation(
        [2.4e6, NaN, 2.4e6 + 2], [1.0, 2.0, 3.0]
    )
    itp = SatelliteToolboxTransformations._create_iers_eop_interpolation(
        [2.4e6, 2.4e6 + 1, NaN], [1.0, 2.0, NaN]
    )
    @test itp(2.4e6 + 0.5) ≈ 1.5
end
