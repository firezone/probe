defmodule Probe.Repo do
  use Ecto.Repo,
    otp_app: :probe,
    adapter: Ecto.Adapters.Postgres
end
