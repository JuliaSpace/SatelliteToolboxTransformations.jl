## Description #############################################################################
#
# Private functions related to the EOP data.
#
############################################################################################

# An interpolation of UT1-UTC which removes the leap-second discontinuity before
# interpolation.  The values outside the data span retain the usual constant
# extrapolation semantics of the EOP reader.
struct _EopInterpolation{T,I,V<:AbstractVector{T}} <:
    DataInterpolations.AbstractInterpolation{T}
    interpolation::I
    t::V
    first_value::T
    last_value::T
    leap_safe::Bool
    values::V
end

# Preserve the native interpolation fields (in particular `.u`) for the
# wrapped interpolation as well.
function Base.getproperty(itp::_EopInterpolation, name::Symbol)
    name == :u && return getfield(itp, :values)
    name in (:interpolation, :t, :first_value, :last_value, :leap_safe, :values) &&
        return getfield(itp, name)
    return getproperty(getfield(itp, :interpolation), name)
end

Base.propertynames(itp::_EopInterpolation, private::Bool = false) =
    propertynames(getfield(itp, :interpolation), private)

function (itp::_EopInterpolation)(JD::Number)
    itp.leap_safe || return itp.interpolation(JD)

    if JD < itp.t[1]
        return itp.first_value
    elseif JD > itp.t[end]
        return itp.last_value
    end

    # Interpolate UT1-TAI, which is continuous at a UTC leap boundary, then
    # restore the UTC-dependent offset at the requested epoch.
    return itp.interpolation(JD) + get_Δat(JD)
end

# Keep the EOP display code (which uses `itp.t`) working for the private wrapper.
_itp_timespan(itp::_EopInterpolation) = begin
    tstart, tend = extrema(itp.t)
    string(julian2datetime(tstart)) * " -- " * string(julian2datetime(tend))
end

# Create the interpolation object for the `knots` and `field` from IERS.
function _create_iers_eop_interpolation(
    knots::AbstractVector,
    field::AbstractVector;
    leap_safe::Bool = false
)
    # Obtain the last available index of the field.
    last_id = findlast(!isempty, field)
    last_id === nothing && (last_id = length(field))

    # Convert the field to a `Vector{Float64}`.
    field_float::Vector{Float64} = Vector{Float64}(field[1:last_id])

    # Create the interpolation object.  UT1-UTC is discontinuous in UTC at a
    # leap second, so interpolate UT1-TAI instead of interpolating the raw
    # field across that boundary.
    interp_field = leap_safe ? field_float .- get_Δat.(knots[1:last_id]) : field_float
    interp = DataInterpolations.LinearInterpolation(
        interp_field,
        knots[1:last_id],
        extrapolation = DataInterpolations.ExtrapolationType.Constant
    )

    return _EopInterpolation(
        interp,
        knots[1:last_id],
        field_float[1],
        field_float[end],
        leap_safe,
        field_float
    )
end

# Function to download the EOP from `url` into `filename`, if necessary. It uses a scratch
# space `key` to store the files.
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
                @debug "We found an EOP file that is less than 7 days old (timestamp = $timestamp). Hence, we will use it."
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

# Get the timestamp of an interpolation.
function _itp_timespan(itp::DataInterpolations.LinearInterpolation)
    tstart, tend = extrema(itp.t)
    str = string(julian2datetime(tstart)) * " -- " * string(julian2datetime(tend))
    return str
end

# Parse the IERS EOP IAU 1980 data in the matrix `eop`, which must have been obtained from
# the file `finals.all.csv`.
function _parse_iers_eop_iau_1980(eop::Matrix)
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

# Parse the IERS EOP IAU 2000A data in the matrix `eop`, which must have been obtained from
# the file `finals2000A.all.csv`.
function _parse_iers_eop_iau_2000A(eop::Matrix)
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
