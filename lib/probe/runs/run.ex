defmodule Probe.Runs.Run do
  use Probe, :schema

  @checks %{
    "handshake_initiation" => false,
    "handshake_response" => false,
    "cookie_reply" => false,
    "data_message" => false
  }

  schema "runs" do
    field :remote_ip_location_country, :string
    field :remote_ip_location_region, :string
    field :remote_ip_location_city, :string
    field :remote_ip_location_lat, :float
    field :remote_ip_location_lon, :float
    field :remote_ip_provider, :string

    field :topic, :string
    field :port, :integer

    field :checks, :map, default: @checks

    # TODO: we need to store hash or remote_ip or something similar to prevent one person from submitting too many runs

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(%__MODULE__{} = run \\ %__MODULE__{}, attrs) do
    run
    |> cast(attrs, [
      :remote_ip_location_country,
      :remote_ip_location_region,
      :remote_ip_location_city,
      :remote_ip_location_lat,
      :remote_ip_location_lon,
      :remote_ip_provider,
      :topic,
      :port,
      :checks
    ])
    |> validate_required([
      :remote_ip_location_country,
      :topic,
      :port,
      :checks
    ])
  end
end
