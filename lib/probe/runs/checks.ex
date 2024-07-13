defmodule Probe.Runs.Checks do
  use Probe, :schema

  @primary_key false
  embedded_schema do
    field :handshake_initiation, :boolean, default: false
    field :handshake_response, :boolean, default: false
    field :cookie_reply, :boolean, default: false
    field :data_message, :boolean, default: false
  end

  def changeset(%__MODULE__{} = checks, attrs) do
    checks
    |> cast(attrs, [:handshake_initiation, :handshake_response, :cookie_reply, :data_message])
  end
end
