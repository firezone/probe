defmodule Probe.Runs.Run do
  use Probe, :schema

  schema "runs" do
    field :remote_ip_location_country, :string
    field :remote_ip_location_region, :string
    field :remote_ip_location_city, :string
    field :remote_ip_location_lat, :float
    field :remote_ip_location_lon, :float
    field :remote_ip_provider, :string

    # We have to store the some anonymized identifier to prevent the user from submitting
    # multiple runs and skewing the statistics. We can't use the IP address directly because
    # it's PII. So instead we store sum of IP address components along with a unique string
    # stored in the user's browser.
    field :anonymized_id, :string

    field :port, :integer
    embeds_one :checks, Probe.Runs.Checks, on_replace: :delete

    timestamps(type: :utc_datetime_usec, inserted_at: :started_at)
    field :completed_at, :utc_datetime_usec
    field :canceled_at, :utc_datetime_usec
  end

  def create_changeset(attrs) do
    %__MODULE__{checks: %Probe.Runs.Checks{}}
    |> changeset(attrs)
    |> put_change(:started_at, DateTime.utc_now())
  end

  def complete_changeset(%__MODULE__{} = run) do
    change(run,
      completed_at: DateTime.utc_now(),
      canceled_at: nil,
      checks: fail_rest_checks(run.checks)
    )
  end

  def cancel_changeset(%__MODULE__{} = run) do
    change(run,
      completed_at: nil,
      canceled_at: DateTime.utc_now(),
      checks: fail_rest_checks(run.checks)
    )
  end

  defp fail_rest_checks(%Probe.Runs.Checks{} = checks) do
    checks
    |> Map.from_struct()
    |> Enum.map(fn
      {k, nil} -> {k, false}
      {k, v} -> {k, v}
    end)
    |> Map.new()
  end

  defp changeset(%__MODULE__{} = run, attrs) do
    run
    |> cast(attrs, [
      :remote_ip_location_country,
      :remote_ip_location_region,
      :remote_ip_location_city,
      :remote_ip_location_lat,
      :remote_ip_location_lon,
      :remote_ip_provider,
      :anonymized_id,
      :port,
      :started_at,
      :completed_at
    ])
    |> cast_embed(:checks, required: true)
    |> validate_required([
      :anonymized_id,
      :remote_ip_location_country,
      :port
    ])
  end
end
