defmodule Probe.Repo do
  use Ecto.Repo,
    otp_app: :probe,
    adapter: Ecto.Adapters.Postgres

  def fetch(queryable, opts \\ []) do
    case __MODULE__.one(queryable, opts) do
      nil -> {:error, :not_found}
      schema -> {:ok, schema}
    end
  end
end
