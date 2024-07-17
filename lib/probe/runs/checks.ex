defmodule Probe.Runs.Checks do
  use Probe, :schema

  @primary_key false
  embedded_schema do
    # Vanilla checks
    field :handshake_initiation, :boolean
    field :handshake_response, :boolean
    field :cookie_reply, :boolean
    field :data_message, :boolean

    # WireGuard behind TURN (Firezone) checks
    field :turn_handshake_initiation, :boolean
    field :turn_handshake_response, :boolean
    field :turn_cookie_reply, :boolean
    field :turn_data_message, :boolean
  end

  def changeset(%__MODULE__{} = checks, attrs) do
    checks
    |> cast(attrs, [
      :handshake_initiation,
      :handshake_response,
      :cookie_reply,
      :data_message,
      :turn_handshake_initiation,
      :turn_handshake_response,
      :turn_cookie_reply,
      :turn_data_message
    ])
  end
end
