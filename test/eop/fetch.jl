## Description #############################################################################
#
# Tests related to fetching EOP data from IERS website.
#
############################################################################################

# == File: ./src/eop/fetch.jl ==============================================================

# -- Function: fetch_iers_eop --------------------------------------------------------------

@testset "Fetching EOP for IAU-76 / FK5 theory" begin
    # Make sure the scratch space is clean.
    delete_scratch!(SatelliteToolboxTransformations, "eop_iau1980")

    # Fetch the EOP for the first time.
    eop_iau1980 = (
        @test_logs (
            :info,
            "Downloading the file 'finals.all.csv' from 'https://datacenter.iers.org/data/csv/finals.all.csv'..."
        ) fetch_iers_eop()
    )

    # Test the some data.
    @test eop_iau1980.x(date_to_jd(1986, 6, 19, 18, 35, 00)) ≈ -0.08982701041673635
    @test eop_iau1980.y(date_to_jd(1986, 6, 19, 18, 35, 00)) ≈ +0.29843172569433274

    # Obtain the timestamp for the following tests.
    eop_cache_dir      = get_scratch!(SatelliteToolboxTransformations, "eop_iau1980")
    eop_file_timestamp = joinpath(eop_cache_dir, "finals.all.csv_timestamp")
    timestamp          = split(read(eop_file_timestamp, String), '\n') |> first |> DateTime

    # If we fetch again, we should not download the file.
    eop_iau1980 = (
        @test_logs (
            :debug,
            "We found an EOP file that is less than 7 days old (timestamp = $timestamp). Hence, we will use it."
        ) min_level = Logging.Debug fetch_iers_eop()
    )

    # Test the some data.
    @test eop_iau1980.x(date_to_jd(1986, 6, 19, 18, 35, 00)) ≈ -0.08982701041673635
    @test eop_iau1980.y(date_to_jd(1986, 6, 19, 18, 35, 00)) ≈ +0.29843172569433274

    # Let's change the timestamp do verify if we download the file again after 7 days.
    open(eop_file_timestamp, "w") do f
        write(f, string(timestamp - Day(7)))
    end

    eop_iau1980 = (
        @test_logs (
            :info,
            "Downloading the file 'finals.all.csv' from 'https://datacenter.iers.org/data/csv/finals.all.csv'..."
        ) fetch_iers_eop()
    )

    # Test the some data.
    @test eop_iau1980.x(date_to_jd(1986, 6, 19, 18, 35, 00)) ≈ -0.08982701041673635
    @test eop_iau1980.y(date_to_jd(1986, 6, 19, 18, 35, 00)) ≈ +0.29843172569433274

    # If the timestamp file is invalid, we should download the EOP.
    open(eop_file_timestamp, "w") do f
        write(f, "THIS CANNOT BE CONVERTED TO DATATIME")
    end

    eop_iau1980 = (
        @test_logs (
            :info,
            "Downloading the file 'finals.all.csv' from 'https://datacenter.iers.org/data/csv/finals.all.csv'..."
        ) fetch_iers_eop()
    )

    # Test the some data.
    @test eop_iau1980.x(date_to_jd(1986, 6, 19, 18, 35, 00)) ≈ -0.08982701041673635
    @test eop_iau1980.y(date_to_jd(1986, 6, 19, 18, 35, 00)) ≈ +0.29843172569433274
end

@testset "Fetching EOP for IAU-2006 / 2010A theory" begin
    # Make sure the scratch space is clean.
    delete_scratch!(SatelliteToolboxTransformations, "eop_iau2000A")

    # Fetch the EOP for the first time.
    eop_iau2000a = (
        @test_logs (
            :info,
            "Downloading the file 'finals2000A.all.csv' from 'https://datacenter.iers.org/data/csv/finals2000A.all.csv'..."
        ) fetch_iers_eop(Val(:IAU2000A))
    )

    # Test the some data.
    @test eop_iau2000a.x(date_to_jd(1986, 6, 19, 18, 35, 00)) ≈ -0.08982701041673635
    @test eop_iau2000a.y(date_to_jd(1986, 6, 19, 18, 35, 00)) ≈ +0.29843172569433274

    # Obtain the timestamp for the following tests.
    eop_cache_dir      = get_scratch!(SatelliteToolboxTransformations, "eop_iau2000A")
    eop_file_timestamp = joinpath(eop_cache_dir, "finals2000A.all.csv_timestamp")
    timestamp          = split(read(eop_file_timestamp, String), '\n') |> first |> DateTime

    # If we fetch again, we should not download the file.
    eop_iau2000a = (
        @test_logs (
            :debug,
            "We found an EOP file that is less than 7 days old (timestamp = $timestamp). Hence, we will use it."
        ) min_level = Logging.Debug fetch_iers_eop(Val(:IAU2000A))
    )

    # Test the some data.
    @test eop_iau2000a.x(date_to_jd(1986, 6, 19, 18, 35, 00)) ≈ -0.08982701041673635
    @test eop_iau2000a.y(date_to_jd(1986, 6, 19, 18, 35, 00)) ≈ +0.29843172569433274

    # Let's change the timestamp do verify if we download the file again after 7 days.
    open(eop_file_timestamp, "w") do f
        write(f, string(timestamp - Day(7)))
    end

    eop_iau2000a = (
        @test_logs (
            :info,
            "Downloading the file 'finals2000A.all.csv' from 'https://datacenter.iers.org/data/csv/finals2000A.all.csv'..."
        ) fetch_iers_eop(Val(:IAU2000A))
    )

    # Test the some data.
    @test eop_iau2000a.x(date_to_jd(1986, 6, 19, 18, 35, 00)) ≈ -0.08982701041673635
    @test eop_iau2000a.y(date_to_jd(1986, 6, 19, 18, 35, 00)) ≈ +0.29843172569433274

    # If the timestamp file is invalid, we should download the EOP.
    open(eop_file_timestamp, "w") do f
        write(f, "THIS CANNOT BE CONVERTED TO DATATIME")
    end

    eop_iau2000a = (
        @test_logs (
            :info,
            "Downloading the file 'finals2000A.all.csv' from 'https://datacenter.iers.org/data/csv/finals2000A.all.csv'..."
        ) fetch_iers_eop(Val(:IAU2000A))
    )

    # Test the some data.
    @test eop_iau2000a.x(date_to_jd(1986, 6, 19, 18, 35, 00)) ≈ -0.08982701041673635
    @test eop_iau2000a.y(date_to_jd(1986, 6, 19, 18, 35, 00)) ≈ +0.29843172569433274
end
