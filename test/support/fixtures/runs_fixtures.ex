defmodule Probe.Fixtures.Runs do
  def run_attrs(attrs \\ %{}) do
    Enum.into(attrs, %{
      remote_ip_location_country: "US",
      remote_ip_location_region: "CA",
      remote_ip_location_city: "San Francisco",
      remote_ip_location_lat: 37.7749,
      remote_ip_location_lon: -122.4194,
      remote_ip_provider: "AT&T",
      topic: Ecto.UUID.generate(),
      port: 4002
    })
  end

  def start_run(attrs \\ %{}) do
    pid = self()
    {:ok, run} = Probe.Runs.start_run(pid, run_attrs(attrs))
    run
  end
end
