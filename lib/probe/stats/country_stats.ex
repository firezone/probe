defmodule Probe.Stats.CountryStats do
  use Probe, :schema

  @primary_key {:country, :string, []}
  schema "country_stats" do
    field :num_completed, :integer
    field :num_succeeded, :integer

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:country, :num_completed, :num_succeeded])
    |> validate_required([:country, :num_succeeded])
    |> unique_constraint(:country)
  end
end
