defmodule Probe.Stats.CityStats do
  use Probe, :schema

  @primary_key {:city, :string, []}
  schema "city_stats" do
    field :num_completed, :integer
    field :num_succeeded, :integer

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:city, :num_completed, :num_succeeded])
    |> validate_required([:city, :num_succeeded])
    |> unique_constraint(:city)
  end
end
