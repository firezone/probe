defmodule Probe.Runs do
  use Supervisor
  import Ecto.Query
  alias Probe.{Repo, PubSub}
  alias Probe.Runs.{Adapters, Run, Check}

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__.Supervisor)
  end

  def init(_opts) do
    children = [
      Adapters
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def start_run(attrs) do
    # checks =
    #   Ecto.Enum.values(Check, :adapter)
    #   |> Enum.map(&Check.changeset(%{adapter: &1}))

    %Run{}
    |> Run.changeset(attrs)
    # |> Ecto.Changeset.put_assoc(:checks, checks)
    |> Repo.insert()
  end

  def list_aggregates_by_country do
  end

  def update_check(check_id, status) do
    from(check in Check, as: :checks)
    |> where([checks: checks], checks.id == ^check_id)
    |> Repo.fetch()
    |> case do
      {:ok, check} ->
        check =
          check
          |> Check.changeset(%{status: status})
          |> Repo.update!()

        :ok = broadcast_check_update(check)

        {:ok, check}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def fetch_run(id) do
    from(run in Run, as: :runs)
    |> where([runs: runs], runs.id == ^id)
    |> preload(:checks)
    |> Repo.fetch()
  end

  def fetch_run_by_topic!(topic) do
    from(run in Run, as: :runs)
    |> where([runs: runs], runs.topic == ^topic)
    |> Repo.one!()
  end

  defp run_topic(%Run{} = run), do: run_topic(run.id)
  defp run_topic(run_id), do: "runs:#{run_id}"

  defp broadcast_check_update(%Check{} = check) do
    run_topic(check.run_id)
    |> PubSub.broadcast({:check_updated, %{adapter: check.adapter, status: check.status}})
  end

  def subscribe_to_run_updates(run_or_id) do
    run_topic(run_or_id)
    |> PubSub.subscribe()
  end
end