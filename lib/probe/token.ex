defmodule Probe.Token do
  # 1 hour
  @token_max_age_seconds 3600

  def sign(payload) do
    Phoenix.Token.sign(Probe.Endpoint, "run", payload)
  end

  def verify(token) do
    Phoenix.Token.verify(Probe.Endpoint, "run", token, max_age: @token_max_age_seconds)
  end

  def expiration_ms do
    :timer.seconds(@token_max_age_seconds)
  end
end
