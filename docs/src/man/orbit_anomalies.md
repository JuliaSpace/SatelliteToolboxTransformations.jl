Conversion between Orbit Anomalies
==================================

```@meta
CurrentModule = SatelliteToolboxTransformations
DocTestSetup = quote
    using SatelliteToolboxTransformations
end
```

There are three types of anomalies[^1] that can be used to describe the position of the
satellite in the orbit plane with respect to the argument of perigee:

- The mean anomaly (`M`);
- The eccentric anomaly (`E`); and
- The true anomaly (`f`).

This package contains the following functions that can be used to convert one to another:

```julia
function mean_to_eccentric_anomaly(e::Number, M::Number; kwargs...) -> T
function mean_to_true_anomaly(e::Number, M::Number; kwargs...) -> T
function eccentric_to_true_anomaly(e::Number, E::Number) -> T
function eccentric_to_mean_anomaly(e::Number, E::Number) -> T
function true_to_eccentric_anomaly(e::Number,f::Number) -> T
function true_to_mean_anomaly(e::Number, f::Number) -> T
```

where:

- `M` is the mean anomaly [rad];
- `E` is the eccentric anomaly [rad];
- `f` is the true anomaly [rad];
- `e` is the eccentricity.
- `T` is the output type obtained by promoting `T1` and `T2` to float.

All the returned values are in [rad].

The functions `mean_to_eccentric` and `mean_to_true` uses the Newton-Raphson algorithm to
solve the Kepler's equation. In this case, the following keywords are available to configure
it:

- `tol::Union{Nothing, Number}`: Tolerance to accept the solution from Newton-Raphson
    algorithm. If `tol` is `nothing`, then it will be `eps(T)`, where `T` is a
    floating-point type obtained from the promotion of `T1` and `T2` to a float.
    (**Default** = `nothing`)
- `max_iterations::Number`: Maximum number of iterations allowed for the Newton-Raphson
    algorithm. If it is lower than 1, then it is set to 10. (**Default** = 10)

```jldoctest
julia> mean_to_eccentric_anomaly(0.04, pi / 4)
0.814493281928579

julia> mean_to_true_anomaly(0.04, pi / 4)
0.8440031124631191

julia> true_to_mean_anomaly(0.04, pi / 4)
0.7300148523821107

julia> mean_to_true_anomaly(0, 0.343)
0.3430000000000001

julia> mean_to_true_anomaly(0.04, 0.343)
0.3712280339918371
```

[^1]: In astronomy, anomaly is an angle.

