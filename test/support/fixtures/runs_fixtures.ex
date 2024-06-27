defmodule Probe.Fixtures.Runs do
  def run_attrs(attrs \\ %{}) do
    Enum.into(attrs, %{
      remote_ip_location_country: "US",
      remote_ip_location_region: "CA",
      remote_ip_location_city: "San Francisco",
      remote_ip_location_lat: 37.7749,
      remote_ip_location_lon: -122.4194,
      remote_ip_provider: "AT&T"
    })
  end

  def start_run(attrs \\ %{}) do
    {:ok, run} =
      attrs
      |> run_attrs()
      |> Probe.Runs.start_run()

    run
  end
end
