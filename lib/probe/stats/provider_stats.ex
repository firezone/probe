defmodule Probe.Stats.ProviderStats do
  use Probe, :schema

  @primary_key {:provider, :string, []}
  schema "provider_stats" do
    field :num_completed, :integer
    field :num_succeeded, :integer

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:provider, :num_completed, :num_succeeded])
    |> validate_required([:provider, :num_succeeded])
    |> unique_constraint(:provider)
  end
end
