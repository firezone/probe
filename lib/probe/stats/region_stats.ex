defmodule Probe.Stats.RegionStats do
  use Probe, :schema

  @primary_key {:region, :string, []}
  schema "region_stats" do
    field :num_completed, :integer
    field :num_succeeded, :integer

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:region, :num_completed, :num_succeeded])
    |> validate_required([:region, :num_succeeded])
    |> unique_constraint(:region)
  end
end
