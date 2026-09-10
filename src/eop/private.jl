## Description #############################################################################
#
# Private functions related to the EOP data.
#
############################################################################################

"""
    struct EopInterpolation{T, I, V <: AbstractVector{T}} <: DataInterpolations.AbstractInterpolation{T}

Linear interpolation of one EOP field indexed by the Julian Day [UTC], constant outside the
tabulated span. When `leap_safe` is `true`, the wrapped interpolation holds UT1-TAI, which is
continuous across the leap seconds, and the UTC offset is restored when the interpolation is
evaluated.

Only the evaluation is supported. `DataInterpolations.derivative` and
`DataInterpolations.integral` are not implemented for this type. Unknown properties are
forwarded to `interpolation`, so that `t` and `u` behave as in **DataInterpolations.jl**,
`u` being the tabulated values of the field.

# Fields

- `interpolation::I`: Wrapped **DataInterpolations.jl** interpolation.
- `values::V`: Tabulated values of the field, exposed as the property `u` [same unit as the
    field].
- `leap_safe::Bool`: Whether `interpolation` holds UT1-TAI instead of UT1-UTC.
"""
struct EopInterpolation{T, I, V <: AbstractVector{T}} <:
       DataInterpolations.AbstractInterpolation{T}
    interpolation::I
    values::V
    leap_safe::Bool

    # == Constructors ======================================================================

    function EopInterpolation(
        interpolation::I, values::V, leap_safe::Bool
    ) where {I, V <: AbstractVector}
        return new{eltype(V), I, V}(interpolation, values, leap_safe)
    end
end

"""
    Base.getproperty(itp::EopInterpolation, name::Symbol) -> Any

Return the property `name` of the EOP interpolation `itp`. The property `u` returns the
tabulated values, the fields are returned directly, and any other property is forwarded to
the wrapped interpolation.
"""
function Base.getproperty(itp::EopInterpolation, name::Symbol)
    name === :u && return getfield(itp, :values)
    hasfield(typeof(itp), name) && return getfield(itp, name)
    return getproperty(getfield(itp, :interpolation), name)
end

"""
    Base.propertynames(itp::EopInterpolation, private::Bool = false) -> Tuple

Return the property names of the EOP interpolation `itp`, which are its fields followed by
the properties of the wrapped interpolation.
"""
function Base.propertynames(itp::EopInterpolation, private::Bool = false)
    return (
        fieldnames(EopInterpolation)...,
        propertynames(getfield(itp, :interpolation), private)...,
    )
end

"""
    (itp::EopInterpolation{T})(JD::Number) -> promote_type(T, float(typeof(JD)))

Evaluate the EOP interpolation `itp` at the Julian Day `JD` [UTC]. The value is constant
outside the tabulated span and, for leap-safe interpolations, the UTC leap-second offset is
restored at `JD`.
"""
function (itp::EopInterpolation{T})(JD::Number) where {T}
    interpolation = getfield(itp, :interpolation)
    getfield(itp, :leap_safe) || return interpolation(JD)

    # Outside the tabulated span, we return the tabulated UTC end values, which is the
    # constant extrapolation of UT1-UTC instead of UT1-TAI. `oftype` gives both branches the
    # same type of the in-range result for any `JD` type.
    values = getfield(itp, :values)
    t      = interpolation.t

    JD < first(t) && return oftype(zero(T) * JD, first(values))
    JD > last(t) && return oftype(zero(T) * JD, last(values))

    # Interpolate UT1-TAI, which is continuous at a UTC leap boundary, then restore the
    # UTC-dependent offset at the requested epoch.
    return interpolation(JD) + get_Δat(JD)
end

"""
    _itp_timespan(itp::EopInterpolation) -> String

Format the knot span of the EOP interpolation `itp` for display.
"""
function _itp_timespan(itp::EopInterpolation)
    t = itp.t
    return string(julian2datetime(first(t)), " -- ", julian2datetime(last(t)))
end

# Delimiter used by the IERS EOP files in CSV format.
const _IERS_EOP_DELIMITER = ';'

"""
    _read_iers_eop_csv(filename::AbstractString) -> Matrix{Float64}

Read the IERS EOP file `filename` in CSV format and return its data rows as a
`Matrix{Float64}`, discarding the header.

Fields that are empty, and the textual `Type` columns, are returned as `NaN`, marking them
as unavailable.

!!! note

    This replaces `DelimitedFiles.readdlm`, which cannot infer a concrete element type for
    these files because of their empty trailing fields and therefore returns a `Matrix{Any}`.
    For the ~20,000-row `finals.all.csv` that meant boxing roughly 740,000 elements, at a cost
    of about 100 MiB of transient allocation per call.
"""
function _read_iers_eop_csv(filename::AbstractString)
    lines = readlines(filename)

    length(lines) < 2 && throw(
        ArgumentError("The IERS EOP file must contain a header and at least one data row."),
    )

    # The header fixes the number of columns.
    num_cols = count(==(_IERS_EOP_DELIMITER), first(lines)) + 1
    num_rows = length(lines) - 1

    eop = fill(NaN, num_rows, num_cols)

    @inbounds for i in 1:num_rows
        line = lines[i + 1]
        isempty(line) && continue

        col = 1
        first_id = firstindex(line)

        while col ≤ num_cols
            delimiter_id = findnext(==(_IERS_EOP_DELIMITER), line, first_id)
            last_id =
                delimiter_id === nothing ? lastindex(line) : prevind(line, delimiter_id)

            # An empty field is left as `NaN`, and so is a field that does not hold a number,
            # which is the case of the `Type` columns.
            if last_id ≥ first_id
                v = tryparse(Float64, SubString(line, first_id, last_id))
                v !== nothing && (eop[i, col] = v)
            end

            delimiter_id === nothing && break

            first_id = nextind(line, delimiter_id)
            col += 1
        end
    end

    return eop
end

"""
    _create_iers_eop_interpolation(knots::AbstractVector{<:Real}, field::AbstractVector{<:Real}; kwargs...) -> EopInterpolation

Create the interpolation of the EOP `field` indexed by the Julian Day `knots` [UTC], which
must be sorted. Missing values, represented by `NaN`, are allowed only at the end of
`field`, in which case the interpolation is created only up to the last available value. The
function throws if the data cannot be interpolated.

# Keywords

- `leap_safe::Bool`: If `true`, the field is the UT1-UTC difference [s], which is
    interpolated as UT1-TAI so that it does not jump across the leap seconds.
    (**Default**: `false`)

# Extended help

## Throws

- `ArgumentError`: `field` has no valid value, has a missing value that is not at its end, or
    the knots up to the last available value contain `NaN`.
"""
function _create_iers_eop_interpolation(
    knots::AbstractVector{<:Real}, field::AbstractVector{<:Real}; leap_safe::Bool = false
)
    # Obtain the last available index of the field.
    last_id = findlast(!isnan, field)

    last_id === nothing && throw(
        ArgumentError(
            "The EOP field does not contain any valid value. The IERS file is likely " *
            "corrupted or truncated.",
        ),
    )

    # Convert the field to a `Vector{Float64}`, constructing the shortened vector directly
    # from a view so that the intermediate slice is not copied.
    field_float = Vector{Float64}(@view field[1:last_id])

    # Only *trailing* gaps are trimmed above. A gap in the middle of the field would silently
    # poison the interpolation with `NaN`, so reject it with a descriptive message instead.
    gap_id = findfirst(isnan, field_float)
    gap_id === nothing || throw(
        ArgumentError(
            "The EOP field has a missing value at index $gap_id, which is not at its end. " *
            "The IERS file is likely corrupted or truncated.",
        ),
    )

    # Keep one knot array for both the interpolation and its wrapper. Using a view here is
    # important for fields with trailing missing values.
    knots_view = @view knots[1:last_id]

    # A blank line in the file leaves `NaN` in the MJD column, which would poison the
    # interpolation. We check it after trimming so that a trailing blank line is tolerated.
    any(isnan, knots_view) && throw(
        ArgumentError(
            "The MJD column of the EOP data has a missing value inside the tabulated span. " *
            "The IERS file is likely corrupted.",
        ),
    )

    # Create the interpolation object. UT1-UTC is discontinuous in UTC at a
    # leap second, so interpolate UT1-TAI instead of interpolating the raw
    # field across that boundary.
    interp_field = leap_safe ? field_float .- get_Δat.(knots_view) : field_float
    interp = DataInterpolations.LinearInterpolation(
        interp_field,
        knots_view;
        extrapolation = DataInterpolations.ExtrapolationType.Constant,
    )

    return EopInterpolation(interp, field_float, leap_safe)
end

"""
    _download_eop(url::String, key::String, filename::String;
                  force_download::Bool = false)::String

Download an EOP file into the scratch space when it is missing, stale, or
explicitly requested.

# Arguments

- `url`: URL of the EOP file.
- `key`: Scratch-space key.
- `filename`: Cached filename.

# Keywords

- `force_download`: Download even when a current cached file exists.
"""
function _download_eop(
    url::String, key::String, filename::String; force_download::Bool = false
)
    # Get the scratch space where the files are located.
    eop_cache_dir      = @get_scratch!(key)
    eop_file           = joinpath(eop_cache_dir, filename)
    eop_file_timestamp = joinpath(eop_cache_dir, filename * "_timestamp")

    # We need to verify if we must re-download the data.
    download_eop = false

    if force_download ||
        isempty(readdir(eop_cache_dir)) ||
        !isfile(eop_file) ||
        !isfile(eop_file_timestamp)
        download_eop = true

    else
        # In this case, we should read the time stamp and verify if the file
        # must be re-downloaded.
        try
            str       = read(eop_file_timestamp, String)
            tokens    = split(str, '\n')
            timestamp = tokens |> first |> DateTime

            if now() >= timestamp + Day(7)
                download_eop = true
            else
                @debug "We found an EOP file that is less than 7 days old " *
                    "(timestamp = $timestamp). Hence, we will use it."
            end
        catch
            # If any error occurred, we will download the data again.
            download_eop = true
        end
    end

    # If we need to re-download, we will rebuild the scratch space.
    if download_eop
        @info "Downloading the file '$filename' from '$url'..."
        download(url, eop_file)
        open(eop_file_timestamp, "w") do f
            return write(f, string(now()))
        end
    end

    # Return the EOP file path.
    return eop_file
end

"""
    _parse_iers_eop(::Type{Eop}, eop::AbstractMatrix{<:Real}) -> Eop

Parse the IERS EOP matrix `eop`, read from the file `finals.all.csv` when `Eop` is
`EopIau1980` or from the file `finals2000A.all.csv` when `Eop` is `EopIau2000A`, into the
interpolations indexed by the Julian Day [UTC]. Both the 33- and the 37-column layouts of
the IERS files are supported, and any other width is rejected.

The interpolation is linear between two points of the grid and constant outside it.

# Extended help

## Throws

- `ArgumentError`: The matrix does not have 33 or 37 columns.
"""
function _parse_iers_eop(
    ::Type{Eop}, eop::AbstractMatrix{<:Real}
) where {Eop <: Union{EopIau1980, EopIau2000A}}
    num_cols = size(eop, 2)

    num_cols ∉ (33, 37) && throw(
        ArgumentError(
            "The IERS EOP matrix must have 33 or 37 columns, but it has $num_cols. Only " *
            "the layouts of the files `finals.all.csv` and `finals2000A.all.csv` are " *
            "supported.",
        ),
    )

    # The 37-column layout inserts four columns after the polar motion, shifting the
    # remaining ones.
    Δ = num_cols == 37 ? 4 : 0

    # Column of the first celestial pole offset, which is (δΔψ, δΔϵ) for the IAU 1980 model
    # and (δx, δy), four columns later, for the IAU 2000A model.
    δ_col = _iers_eop_pole_offset_column(Eop) + Δ

    # Convert the knots from Modified Julian Day to Julian Day.
    knots = @view(eop[:, 1]) .+ _MJD_EPOCH_JD

    itp(col; kwargs...) =
        _create_iers_eop_interpolation(knots, @view(eop[:, col]); kwargs...)

    return Eop(
        itp(6),
        itp(8),
        itp(11 + Δ; leap_safe = true),
        itp(13 + Δ),
        itp(δ_col),
        itp(δ_col + 2),
        itp(7),
        itp(9),
        itp(12 + Δ),
        itp(14 + Δ),
        itp(δ_col + 1),
        itp(δ_col + 3),
    )
end

"""
    _iers_eop_pole_offset_column(::Type{Eop}) -> Int

Return the column of the first celestial pole offset in the 33-column layout of the IERS EOP
file related to the model `Eop`.
"""
_iers_eop_pole_offset_column(::Type{EopIau1980}) = 16
_iers_eop_pole_offset_column(::Type{EopIau2000A}) = 20
