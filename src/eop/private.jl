## Description #############################################################################
#
# Private functions related to the EOP data.
#
############################################################################################

"""
    EopInterpolation{T, I, V, W} <: DataInterpolations.AbstractInterpolation{T}

Interpolation wrapper for EOP data, optionally removing the leap-second
discontinuity before interpolation.

# Fields

- `interpolation::I`: Wrapped interpolation object.
- `t::V`: Interpolation knots.
- `first_value::T`: First value used for lower extrapolation.
- `last_value::T`: Last value used for upper extrapolation.
- `leap_safe::Bool`: Whether the wrapped data is adjusted for leap seconds.
- `values::W`: Original data values, exposed as the `u` property.
"""
struct EopInterpolation{T,I,V<:AbstractVector{T},W<:AbstractVector{T}} <:
    DataInterpolations.AbstractInterpolation{T}
    interpolation::I
    t::V
    first_value::T
    last_value::T
    leap_safe::Bool
    values::W
end

"""
    Base.getproperty(itp::EopInterpolation, name::Symbol)::Any

Get a field of an EOP interpolation or delegate an unknown property to the
wrapped interpolation.

# Arguments

- `itp`: EOP interpolation wrapper.
- `name`: Property name to retrieve.
"""
function Base.getproperty(itp::EopInterpolation, name::Symbol)::Any
    name == :u && return getfield(itp, :values)
    name in (:interpolation, :t, :first_value, :last_value, :leap_safe, :values) &&
        return getfield(itp, name)
    return getproperty(getfield(itp, :interpolation), name)
end

"""
    Base.propertynames(itp::EopInterpolation, private::Bool = false)::Any

Return the property names supported by the wrapped interpolation.

# Arguments

- `itp`: EOP interpolation wrapper.
- `private`: Whether private properties should be included.
"""
Base.propertynames(itp::EopInterpolation, private::Bool = false)::Any =
    propertynames(getfield(itp, :interpolation), private)

"""
    (itp::EopInterpolation)(JD::Number)::T

Evaluate an EOP interpolation, preserving constant extrapolation and applying
the UTC leap-second offset when the interpolation is leap-safe.

# Arguments

- `itp`: EOP interpolation wrapper.
- `JD`: Julian date at which to evaluate the interpolation.
"""
function (itp::EopInterpolation)(JD::Number)
    leap_safe = getfield(itp, :leap_safe)
    interpolation = getfield(itp, :interpolation)
    leap_safe || return interpolation(JD)

    t = getfield(itp, :t)
    if JD < t[1]
        return getfield(itp, :first_value)
    elseif JD > t[end]
        return getfield(itp, :last_value)
    end

    # Interpolate UT1-TAI, which is continuous at a UTC leap boundary, then
    # restore the UTC-dependent offset at the requested epoch.
    return interpolation(JD) + get_Δat(JD)
end

# Keep the EOP display code (which uses `itp.t`) working for the private wrapper.
"""
    _itp_timespan(itp::EopInterpolation)::String

Format the knot span of an EOP interpolation for display.

# Arguments

- `itp`: EOP interpolation wrapper.
"""
_itp_timespan(itp::EopInterpolation)::String = begin
    tstart, tend = extrema(itp.t)
    string(julian2datetime(tstart)) * " -- " * string(julian2datetime(tend))
end

"""
    _create_iers_eop_interpolation(knots::AbstractVector, field::AbstractVector;
                                   leap_safe::Bool = false)::EopInterpolation

Create an EOP interpolation from IERS knots and field values.

# Arguments

- `knots`: Julian-date interpolation knots.
- `field`: EOP field values, possibly with trailing missing values.

# Keywords

- `leap_safe`: Adjust UT1-UTC values around leap seconds when `true`.
"""
function _create_iers_eop_interpolation(
    knots::AbstractVector,
    field::AbstractVector;
    leap_safe::Bool = false
)
    # Obtain the last available index of the field.
    last_id = findlast(!isempty, field)
    last_id === nothing && (last_id = length(field))

    # Convert the field to a `Vector{Float64}`. Construct the shortened
    # vector directly from a view so the intermediate slice is not copied.
    field_float::Vector{Float64} = if field isa Vector{Float64} && last_id == length(field)
        field
    else
        Vector{Float64}(@view field[1:last_id])
    end

    # Keep one knot array for both the interpolation and its wrapper. Using a
    # view here is important for fields with trailing missing values.
    knots_view = @view knots[1:last_id]

    # Create the interpolation object. UT1-UTC is discontinuous in UTC at a
    # leap second, so interpolate UT1-TAI instead of interpolating the raw
    # field across that boundary.
    interp_field = leap_safe ? field_float .- get_Δat.(knots_view) : field_float
    interp = DataInterpolations.LinearInterpolation(
        interp_field,
        knots_view,
        extrapolation = DataInterpolations.ExtrapolationType.Constant
    )

    return EopInterpolation(
        interp,
        interp.t,
        field_float[1],
        field_float[end],
        leap_safe,
        field_float
    )
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
    url::String,
    key::String,
    filename::String;
    force_download::Bool = false
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
            write(f, string(now()))
        end
    end

    # Return the EOP file path.
    return eop_file
end

"""
    _itp_timespan(itp::DataInterpolations.LinearInterpolation)::String

Format the knot span of a linear interpolation for display.

# Arguments

- `itp`: Linear interpolation object.
"""
function _itp_timespan(itp::DataInterpolations.LinearInterpolation)::String
    tstart, tend = extrema(itp.t)
    str = string(julian2datetime(tstart)) * " -- " * string(julian2datetime(tend))
    return str
end

"""
    _parse_iers_eop_iau_1980(eop::Matrix)::EopIau1980

Parse IERS IAU 1980 EOP data from a `finals.all.csv` matrix.

# Arguments

- `eop`: Matrix containing the IERS EOP columns.
"""
function _parse_iers_eop_iau_1980(eop::Matrix)::EopIau1980
    # Create the EOP Data structure by creating the interpolations.
    #
    # The interpolation will be linear between two points in the grid. The extrapolation
    # will be flat, considering the nearest point.
    knots::Vector{Float64} = Vector{Float64}(eop[:, 1] .+ 2400000.5)

    if size(eop)[2] == 37
        return EopIau1980(
            _create_iers_eop_interpolation(knots, eop[:, 6]),
            _create_iers_eop_interpolation(knots, eop[:, 8]),
            _create_iers_eop_interpolation(knots, eop[:, 15]; leap_safe = true),
            _create_iers_eop_interpolation(knots, eop[:, 17]),
            _create_iers_eop_interpolation(knots, eop[:, 20]),
            _create_iers_eop_interpolation(knots, eop[:, 22]),
            _create_iers_eop_interpolation(knots, eop[:, 7]),
            _create_iers_eop_interpolation(knots, eop[:, 9]),
            _create_iers_eop_interpolation(knots, eop[:, 16]),
            _create_iers_eop_interpolation(knots, eop[:, 18]),
            _create_iers_eop_interpolation(knots, eop[:, 21]),
            _create_iers_eop_interpolation(knots, eop[:, 23]),
        )
    else
        return EopIau1980(
            _create_iers_eop_interpolation(knots, eop[:, 6]),
            _create_iers_eop_interpolation(knots, eop[:, 8]),
            _create_iers_eop_interpolation(knots, eop[:, 11]; leap_safe = true),
            _create_iers_eop_interpolation(knots, eop[:, 13]),
            _create_iers_eop_interpolation(knots, eop[:, 16]),
            _create_iers_eop_interpolation(knots, eop[:, 18]),
            _create_iers_eop_interpolation(knots, eop[:, 7]),
            _create_iers_eop_interpolation(knots, eop[:, 9]),
            _create_iers_eop_interpolation(knots, eop[:, 12]),
            _create_iers_eop_interpolation(knots, eop[:, 14]),
            _create_iers_eop_interpolation(knots, eop[:, 17]),
            _create_iers_eop_interpolation(knots, eop[:, 19]),
        )
    end
end

"""
    _parse_iers_eop_iau_2000A(eop::Matrix)::EopIau2000A

Parse IERS IAU 2000A EOP data from a `finals2000A.all.csv` matrix.

# Arguments

- `eop`: Matrix containing the IERS EOP columns.
"""
function _parse_iers_eop_iau_2000A(eop::Matrix)::EopIau2000A
    # Create the EOP Data structure by creating the interpolations.
    #
    # The interpolation will be linear between two points in the grid. The extrapolation
    # will be flat, considering the nearest point.
    knots::Vector{Float64} = Vector{Float64}(eop[:, 1] .+ 2400000.5)

    if size(eop)[2] == 37
        EopIau2000A(
            _create_iers_eop_interpolation(knots, eop[:, 6]),
            _create_iers_eop_interpolation(knots, eop[:, 8]),
            _create_iers_eop_interpolation(knots, eop[:, 15]; leap_safe = true),
            _create_iers_eop_interpolation(knots, eop[:, 17]),
            _create_iers_eop_interpolation(knots, eop[:, 24]),
            _create_iers_eop_interpolation(knots, eop[:, 26]),
            _create_iers_eop_interpolation(knots, eop[:, 7]),
            _create_iers_eop_interpolation(knots, eop[:, 9]),
            _create_iers_eop_interpolation(knots, eop[:, 16]),
            _create_iers_eop_interpolation(knots, eop[:, 18]),
            _create_iers_eop_interpolation(knots, eop[:, 25]),
            _create_iers_eop_interpolation(knots, eop[:, 27]),
        )
    else
        EopIau2000A(
            _create_iers_eop_interpolation(knots, eop[:, 6]),
            _create_iers_eop_interpolation(knots, eop[:, 8]),
            _create_iers_eop_interpolation(knots, eop[:, 11]; leap_safe = true),
            _create_iers_eop_interpolation(knots, eop[:, 13]),
            _create_iers_eop_interpolation(knots, eop[:, 20]),
            _create_iers_eop_interpolation(knots, eop[:, 22]),
            _create_iers_eop_interpolation(knots, eop[:, 7]),
            _create_iers_eop_interpolation(knots, eop[:, 9]),
            _create_iers_eop_interpolation(knots, eop[:, 12]),
            _create_iers_eop_interpolation(knots, eop[:, 14]),
            _create_iers_eop_interpolation(knots, eop[:, 21]),
            _create_iers_eop_interpolation(knots, eop[:, 23]),
        )
    end
end
