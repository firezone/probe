defmodule Probe.Stats.CountryStats do
  use Probe, :schema

  schema "country_stats" do
    field :country, :string
    field :num_runs, :integer
    field :num_succeeded, :integer

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:country, :num_runs, :num_succeeded])
    |> validate_required([:country, :num_succeeded])
    |> unique_constraint(:country)
  end
end
