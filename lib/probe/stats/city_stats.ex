defmodule Probe.Stats.CityStats do
  use Probe, :schema

  schema "city_stats" do
    field :city, :string
    field :num_runs, :integer
    field :num_succeeded, :integer

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:city, :num_runs, :num_succeeded])
    |> validate_required([:city, :num_succeeded])
    |> unique_constraint(:city)
  end
end
