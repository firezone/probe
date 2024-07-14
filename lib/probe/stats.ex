defmodule Probe.Stats do
  import Ecto.Query
  alias Probe.Stats.{CountryStats, RegionStats, CityStats, ProviderStats}

  def country_stats do
    from(s in CountryStats, order_by: [asc: :country])
    |> Probe.Repo.all()
  end

  def upsert(%Probe.Runs.Run{} = run) do
    num_succeeded = num_succeeded_incrementer(run.checks)

    [
      {CountryStats, :country, run.remote_ip_location_country},
      {RegionStats, :region, run.remote_ip_location_region},
      {CityStats, :city, run.remote_ip_location_city},
      {ProviderStats, :provider, run.remote_ip_provider}
    ]
    |> Enum.map(fn {schema, key, val} -> upsert_stats(schema, key, val, num_succeeded) end)
  end

  defp upsert_stats(schema, key, val, num_succeeded) do
    changeset = schema.changeset(%{key => val, num_runs: 1, num_succeeded: num_succeeded})

    {:ok, _stat} =
      Probe.Repo.insert(changeset,
        on_conflict: on_conflict_query(schema),
        conflict_target: [key]
      )
  end

  defp num_succeeded_incrementer(%{
         handshake_initiation: true,
         handshake_response: true,
         cookie_reply: true,
         data_message: true
         # If TURN is blocked but not WireGuard, it's still a success
         # turn_handshake_initiation: true,
         # turn_handshake_response: true,
         # turn_cookie_reply: true,
         # turn_data_message: true,
       }),
       do: 1

  defp num_succeeded_incrementer(_), do: 0

  defp on_conflict_query(schema) do
    from s in schema,
      update: [
        set: [updated_at: ^DateTime.utc_now()],
        inc: [
          num_runs: 1,
          num_succeeded: fragment("CASE WHEN EXCLUDED.num_succeeded > 0 THEN 1 ELSE 0 END")
        ]
      ]
  end
end
