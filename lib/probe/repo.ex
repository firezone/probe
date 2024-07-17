defmodule Probe.Repo do
  use Ecto.Repo,
    otp_app: :probe,
    adapter: Ecto.Adapters.Postgres

  @doc """
  Returns `true` when binary representation of `Ecto.UUID` is valid, otherwise - `false`.
  """
  def valid_uuid?(binary) when is_binary(binary),
    do: match?(<<_::64, ?-, _::32, ?-, _::32, ?-, _::32, ?-, _::96>>, binary)

  def valid_uuid?(_binary),
    do: false

  def fetch(queryable, opts \\ []) do
    case __MODULE__.one(queryable, opts) do
      nil -> {:error, :not_found}
      schema -> {:ok, schema}
    end
  end
end
