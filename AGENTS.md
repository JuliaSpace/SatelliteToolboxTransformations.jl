# AGENTS.md

SatelliteToolboxTransformations.jl provides reference-frame, orbit-representation, and time transformations for the SatelliteToolbox.jl ecosystem.

## Package Structure

- Requires Julia 1.10 or newer (`[compat] julia = "1.10, 1.11"`).
- Entrypoint: `src/SatelliteToolboxTransformations.jl`. It loads `src/types.jl` first, then `src/constants.jl` (private constants), then `include`s the feature files. Types must exist before anything else, so new type definitions go in `src/types.jl`, not in the feature file that uses them.
- Source layout: `src/eop/` (Earth Orientation Parameters: fetch, read, conversion, show), `src/reference_frames/` (ECEF/ECI conversions, geodetic/geocentric, local frames, plus the `fk5/`, `iau2006/`, and `teme/` theory subdirectories), `src/orbit/` (state-vector and orbit-representation conversions), `src/time.jl`.
- `src/reference_frames/iau2006/constants/` holds large generated coefficient tables. Treat them as data, not as code to restyle by hand.
- The package re-exports `SatelliteToolboxBase` via `@reexport`, so its symbols are part of this package's public surface.
- No package extensions (`ext/`, `[weakdeps]`) and no `deps/build.jl`, so `Pkg.build()` does nothing here; `Pkg.test()` alone reproduces CI.
- `Manifest.toml` is git-ignored; the dependency tree is not pinned.

### Test Wiring

- Test-only dependencies are declared with `[extras]` + `[targets] test = [...]` in `Project.toml` (Test, Logging, Aqua, AllocCheck, JET). There is no `test/Project.toml`.
- `test/runtests.jl` groups everything in `@testset "..." verbose = true begin ... end` blocks and `include`s the per-feature files. Match that convention when adding tests.
- **`test/runtests.jl` `cd`s into each test subdirectory before including its files**, because test files reference the EOP fixtures (`test/eop_IAU*.txt`) with paths relative to the working directory (e.g. `read_iers_eop("../eop_IAU1980_old.txt")`). A focused run must reproduce that working directory — see Commands.
- `test/` mirrors `src/` only partially. Files with no test counterpart: `src/types.jl`, `src/eop/conversion.jl`, `src/eop/private.jl`, `src/reference_frames/iau2006/fundamental_args.jl`, `src/reference_frames/iau2006/misc.jl`, and everything under `src/reference_frames/iau2006/constants/`. `test/eop.jl` and `test/performance.jl` have no matching source file.
- `test/performance.jl` runs Aqua, JET, and AllocCheck. It is skipped entirely on prerelease Julia; JET is skipped on Julia 1.12+, and the allocation tests are skipped on macOS with Julia 1.12+.
- The EOP network tests (`test/eop/fetch.jl`) only run when `SATELLITETOOLBOX_RUN_NETWORK_TESTS=true`.

## Commands

- Instantiate: `julia --project=. -e 'using Pkg; Pkg.instantiate()'`
- Full test suite: `julia --project=. -e 'using Pkg; Pkg.test()'`
- Focused test file (run from `test/`, or from the file's own subdirectory when it reads fixtures): `cd test && julia --project=.. -e 'using SatelliteToolboxTransformations, Test, Dates, LinearAlgebra, Logging, ReferenceFrameRotations, SatelliteToolboxBase, Scratch, StaticArrays; include("time.jl")'`. Add `using Aqua, AllocCheck, JET` only for `performance.jl`; those are test-only deps and are unavailable outside `Pkg.test()` unless installed in the default environment.
- Network EOP tests: `SATELLITETOOLBOX_RUN_NETWORK_TESTS=true julia --project=. -e 'using Pkg; Pkg.test()'`
- Format: `julia -e 'using JuliaFormatter; format(".")'` — **no `--project=.`**; JuliaFormatter is not a dependency of this package. Verify with `git diff --exit-code` afterwards.
- Build docs locally: `julia --project=docs -e 'using Pkg; Pkg.develop(path="."); Pkg.instantiate()'` once, then `julia --project=docs docs/make.jl`. Pass `local` in `ARGS` to disable pretty URLs.
- There is no test-name selector; `test/runtests.jl` does not read `ARGS`.
- Use generous timeouts. A first `Pkg.instantiate()`, `Pkg.test()`, or docs build precompiles for minutes while printing little — that is not a hang.

## Code Style

- `.JuliaFormatter.toml` is the source of truth: `style = "blue"` with alignment enabled for assignments, conditionals, matrices, pair arrows, and struct fields, and with `whitespace_in_kwargs`/`whitespace_typedefs` on. Run the formatter rather than hand-aligning.
- CI does **not** run a format check. Formatting is a convention enforced by the maintainer, so keep diffs formatted before committing.
- Source files open with a 92-column boxed `## Description ####...` header, followed by a `## References ####...` block when the algorithms come from literature, then the `export` lines. Follow that layout in new files, and cite the reference (Vallado, IERS Technical Note No. 36, etc.) for any new algorithm.
- Section banners inside files use the same 92-column `####` rule; test files mark the source file under test with `# == File: ./src/... ==` and each function with `# -- Function: name --`.
- Unicode identifiers matching the source literature (`δΔϵ`, `ϵ₀`, `Δat`) are used deliberately. Keep them.

## Behavioral Constraints

- This is a numerical package validated against published reference values; test tolerances encode real accuracy expectations. Do not loosen a tolerance to make a test pass — investigate the numerics instead.
- Keep transformations allocation-free where they already are: `test/performance.jl` asserts zero allocations for the EOP interpolation functions via AllocCheck, and JET runs a full `test_package` on the module. Type instabilities and new allocations will fail CI.
- The package supports arbitrary float types (`Float32`, `Float64`) and promotes with the ellipsoid parameter type; preserve type-generic code paths rather than hard-coding `Float64`.
- Every user-visible change gets a `CHANGELOG.md` entry under a new version heading, using the existing `![Bugfix][badge-bugfix]` / `![Enhancement][badge-enhancement]` badge style and explaining the physical impact of the change.
- Public functions carry docstrings with an explicit signature-and-return-type first line (e.g. `ecef_to_geocentric(r_e::AbstractVector{T}) -> NTuple{3, T}`). Match that form.

## CI

- `.github/workflows/ci.yml`: Julia `1.10` (the minimum from `[compat]`) and `1` (latest stable 1.x), on ubuntu-latest (x64), macos-latest (arm64), and windows-latest (x64). Steps: `julia-buildpkg` → `julia-runtest` → coverage upload to Codecov.
- `.github/workflows/ci-nightly.yml`: same OS/arch matrix on `nightly`, no coverage.
- `.github/workflows/docs.yml`: Documenter build and deploy on latest stable.
- `CompatHelper.yml` and `TagBot.yml` handle dependency bumps and release tagging.

## Not Configured

- No pre-commit hooks (`.pre-commit-config.yaml` does not exist).
- No linter beyond Aqua/JET inside the test suite.
- No format-check CI job.
- No build script; `Pkg.build()` is a no-op.
- No benchmark suite; `test/performance.jl` is correctness-of-performance (allocations, inference), not timing.
