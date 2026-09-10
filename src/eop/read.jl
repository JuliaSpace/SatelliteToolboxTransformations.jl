## Description #############################################################################
#
# Functions to read EOP files.
#
############################################################################################

export read_iers_eop

"""
    read_iers_eop(filename::AbstractString[, data_type]) -> Union{EopIau1980, EopIau2000A}

Read the IERS EOP data from the file `filename` related to the model selected by
`data_type`, which can be `Val(:IAU1980)` for the IAU 1980 model (file `finals.all.csv`) or
`Val(:IAU2000A)` for the IAU 2000A model (file `finals2000A.all.csv`). If `data_type` is
omitted, it defaults to `Val(:IAU1980)`. The function throws if the file does not follow the
layout of the IERS files.

See also: [`fetch_iers_eop`](@ref)

!!! note

    The input file **must be exactly the same** as provided by IERS in CSV format. One can
    download it using the following commands:

    - IAU 1980

        curl -O https://datacenter.iers.org/data/csv/finals.all.csv
        wget https://datacenter.iers.org/data/csv/finals.all.csv

    - IAU 2000A

        curl -O https://datacenter.iers.org/data/csv/finals2000A.all.csv
        wget https://datacenter.iers.org/data/csv/finals2000A.all.csv

# Returns

- `Union{EopIau1980, EopIau2000A}`: [`EopIau1980`](@ref) or [`EopIau2000A`](@ref), depending
    on `data_type`, with the interpolations of the EOP fields indexed by the Julian Day
    [UTC].

# Extended help

## Throws

- `ArgumentError`: The file does not contain a header and at least one data row, its number
    of columns is neither 33 nor 37, or a field has no valid value or a missing value that
    is not at its end.
"""
read_iers_eop(filename::AbstractString) = read_iers_eop(filename, Val(:IAU1980))

function read_iers_eop(filename::AbstractString, ::Val{:IAU1980})
    return _parse_iers_eop(EopIau1980, _read_iers_eop_csv(filename))
end

function read_iers_eop(filename::AbstractString, ::Val{:IAU2000A})
    return _parse_iers_eop(EopIau2000A, _read_iers_eop_csv(filename))
end
