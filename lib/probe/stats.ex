defmodule Probe.Stats do
  import Ecto.Query
  alias Probe.Stats.{CountryStats, RegionStats, CityStats, ProviderStats}

  def upsert(%Probe.Runs.Run{} = run) do
    num_succeeded = num_succeeded_incrementer(run.checks)

    [
      {CountryStats, :country},
      {RegionStats, :region},
      {CityStats, :city},
      {ProviderStats, :provider}
    ]
    |> Enum.map(fn {schema, key} -> upsert_stats(schema, key, num_succeeded) end)
  end

  defp upsert_stats(schema, key, num_succeeded) do
    changeset = schema.changeset(%{num_succeeded: num_succeeded})

    Probe.Repo.insert(changeset,
      on_conflict: on_conflict_query(schema),
      conflict_target: [key]
    )
  end

  defp num_succeeded_incrementer(%{
         "handshake_initiation" => true,
         "handshake_response" => true,
         "cookie_reply" => true,
         "data_message" => true
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
