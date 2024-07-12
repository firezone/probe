defmodule Probe.Stats.ProviderStats do
  use Probe, :schema

  schema "provider_stats" do
    field :provider, :string
    field :num_runs, :integer
    field :num_succeeded, :integer

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:provider, :num_runs, :num_succeeded])
    |> validate_required([:provider, :num_succeeded])
    |> unique_constraint(:provider)
  end
end
