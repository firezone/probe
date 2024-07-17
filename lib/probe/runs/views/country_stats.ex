defmodule Probe.Runs.Views.CountryStats do
  use Probe, :schema

  @primary_key {:country, :string, []}
  schema "country_stats_mv" do
    field :num_completed, :integer
    field :num_succeeded, :integer

    timestamps(type: :utc_datetime_usec, inserted_at: false)
  end
end
