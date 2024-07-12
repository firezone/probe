defmodule Probe.Stats.RegionStats do
  use Probe, :schema

  schema "region_stats" do
    field :region, :string
    field :num_runs, :integer
    field :num_succeeded, :integer

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:region, :num_runs, :num_succeeded])
    |> validate_required([:region, :num_succeeded])
    |> unique_constraint(:region)
  end
end
