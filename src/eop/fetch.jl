## Description #############################################################################
#
# Functions to fetch the EOP data from the IERS website.
#
############################################################################################

export fetch_iers_eop

"""
    fetch_iers_eop([data_type]; kwargs...) -> Union{EopIau1980, EopIau2000A}

Download and parse the IERS EOP data related to the model selected by `data_type`, which can
be `Val(:IAU1980)` for the IAU 1980 model (file `finals.all.csv`) or `Val(:IAU2000A)` for
the IAU 2000A model (file `finals2000A.all.csv`). If `data_type` is omitted, it defaults to
`Val(:IAU1980)`.

The file is downloaded from `url` into a scratch space and reused for 7 days unless
`force_download` is `true`. The result is an [`EopIau1980`](@ref) or an
[`EopIau2000A`](@ref), depending on `data_type`, with the interpolations of the EOP fields
indexed by the Julian Day [UTC].

See also: [`read_iers_eop`](@ref)

# Keywords

- `force_download::Bool`: If `true`, download the file even when a cached file less than 7
    days old exists.
    (**Default**: `false`)
- `url::String`: URL of the EOP file in the CSV format provided by IERS.
    (**Default**: the IERS URL of `finals.all.csv` or `finals2000A.all.csv`, depending on
    `data_type`)

# Extended help

## Examples

```julia-repl
julia> eop = fetch_iers_eop();

julia> eop = fetch_iers_eop(Val(:IAU2000A));
```
"""
fetch_iers_eop(; kwargs...) = fetch_iers_eop(Val(:IAU1980); kwargs...)

function fetch_iers_eop(
    ::Val{:IAU1980};
    force_download::Bool = false,
    url::String = "https://datacenter.iers.org/data/csv/finals.all.csv",
)
    # Download the file, if necessary, and obtain its path.
    eop_file = _download_eop(url, "eop_iau1980", "finals.all.csv"; force_download)

    # Read and parse the file.
    return read_iers_eop(eop_file, Val(:IAU1980))
end

function fetch_iers_eop(
    ::Val{:IAU2000A};
    force_download::Bool = false,
    url::String = "https://datacenter.iers.org/data/csv/finals2000A.all.csv",
)
    # Download the file, if necessary, and obtain its path.
    eop_file = _download_eop(url, "eop_iau2000A", "finals2000A.all.csv"; force_download)

    # Read and parse the file.
    return read_iers_eop(eop_file, Val(:IAU2000A))
end
