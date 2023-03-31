# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Description
# ==============================================================================
#
#   Functions to fetch the EOP data from the IERS website.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export fetch_iers_eop

"""
    fetch_iers_eop([data_type]; kwargs...)

Download and parse the IERS EOP C04 data. The data type is specified by
`data_type`. Supported values are:

- `Val(:IAU1980)`: Get IERS EOP C04 IAU1980 data.
- `Val(:IAU2000A)`: Get IERS EOP C04 IAU2000A data.

If `data_type` is omitted, then it defaults to `Val(:IAU1980)`.

This function returns a structure ([`EopIau1980`](@ref) or
[`EopIau2000A`](@ref), depending on `data_type`) with the interpolations of the
EOP parameters. Notice that the interpolation indexing is set to the Julian Day.

# Keywords

- `force_download::Bool`: If the EOP file exists and is less than 7 days old, it
    will not be downloaded again. A new download can be forced by setting this
    keyword to `true`. (**Default** = `false`)
- `url::String`: URL of the EOP file.

```julia-repl
julia> eop = fetch_iers_eop()
[ Info: Downloading file 'EOP_IAU1980.TXT' from 'https://datacenter.iers.org/data/csv/finals.all.csv'...
EopIau1980:
     Data │ Timespan
 ─────────┼──────────────────────────────────────────────
        x │ 1973-01-02T00:00:00 -- 2022-05-28T00:00:00
        y │ 1973-01-02T00:00:00 -- 2022-05-28T00:00:00
  UT1-UTC │ 1973-01-02T00:00:00 -- 2022-05-28T00:00:00
      LOD │ 1973-01-02T00:00:00 -- 2021-05-19T00:00:00
       dψ │ 1973-01-02T00:00:00 -- 2021-08-05T00:00:00
       dϵ │ 1973-01-02T00:00:00 -- 2021-08-05T00:00:00

julia> eop = fetch_iers_eop(Val(:IAU2000A))
[ Info: Downloading file 'EOP_IAU2000A.TXT' from 'https://datacenter.iers.org/data/csv/finals2000A.all.csv'...
EopIau2000A:
     Data │ Timespan
 ─────────┼──────────────────────────────────────────────
        x │ 1973-01-02T00:00:00 -- 2022-05-28T00:00:00
        y │ 1973-01-02T00:00:00 -- 2022-05-28T00:00:00
  UT1-UTC │ 1973-01-02T00:00:00 -- 2022-05-28T00:00:00
      LOD │ 1973-01-02T00:00:00 -- 2021-05-19T00:00:00
       dX │ 1973-01-02T00:00:00 -- 2021-08-05T00:00:00
       dY │ 1973-01-02T00:00:00 -- 2021-08-05T00:00:00
```
"""
fetch_iers_eop(;kwargs...) = fetch_iers_eop(Val(:IAU1980); kwargs...)

function fetch_iers_eop(
    ::Val{:IAU1980};
    force_download::Bool = false,
    url::String = "https://datacenter.iers.org/data/csv/finals.all.csv"
)
    # Download the file, if necessary, and obtain its path.
    eop_file = _download_eop(url, "eop_iau1980", "finals.all.csv"; force_download)

    # Read and parse the file.
    return read_iers_eop(eop_file, Val(:IAU1980))
end

function fetch_iers_eop(
    ::Val{:IAU2000A};
    force_download::Bool = false,
    url::String = "https://datacenter.iers.org/data/csv/finals2000A.all.csv"
)
    # Download the file, if necessary, and obtain its path.
    eop_file = _download_eop(url, "eop_iau2000A", "finals2000A.all.csv"; force_download)

    # Read and parse the file.
    return read_iers_eop(eop_file, Val(:IAU2000A))
end
