using Documenter
using SatelliteToolboxTransformations

makedocs(
    modules = [SatelliteToolboxTransformations],
    format = Documenter.HTML(
        prettyurls = !("local" in ARGS),
        canonical = "https://juliaspace.github.io/SatelliteToolboxTransformations.jl/stable/",
        size_threshold = 500 * 1024,
        size_threshold_warn = 300 * 1024,
    ),
    sitename = "SatelliteToolboxTransformations.jl",
    authors = "Ronan Arraes Jardim Chagas",
    pages = [
        "Home" => "index.md",
        "Transformations" => [
            "ECI and ECEF"            => "man/ecef_eci.md",
            "ECEF and Local frames"   => "man/ecef_local_frames.md",
            "Geodetic and Geocentric" => "man/geodetic_geocentric.md",
            "Orbit representations"   => "man/orbit_representations.md",
        ],
        "Library" => "lib/library.md",
    ],
)

deploydocs(
    repo = "github.com/JuliaSpace/SatelliteToolboxTransformations.jl.git",
    target = "build",
)
