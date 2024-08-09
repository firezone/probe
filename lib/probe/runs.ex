defmodule Probe.Runs do
  use Supervisor
  import Ecto.Query
  alias Probe.{Repo, PubSub, RecurrentJob}
  alias Probe.Runs.{Run, UDPServer, Views}

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__.Supervisor)
  end

  def init(_opts) do
    udp_servers =
      Application.fetch_env!(:probe, :port_options)
      |> Enum.map(fn {_, port} ->
        {UDPServer, [port: port]}
      end)

    recurrent_jobs = [
      {RecurrentJob, every: :timer.seconds(1), run: &cancel_stale_runs!/0},
      {RecurrentJob, every: :timer.minutes(5), run: &reset_materialized_views!/0}
    ]

    Supervisor.init(udp_servers ++ recurrent_jobs, strategy: :one_for_one)
  end

  def fetch_run(id) do
    if Repo.valid_uuid?(id) do
      from(run in Run, as: :runs)
      |> where([runs: runs], runs.id == ^id)
      |> Repo.fetch()
    else
      {:error, :not_found}
    end
  end

  def start_run(state_machine_pid, attrs) do
    if Process.alive?(state_machine_pid) do
      attrs
      |> Run.create_changeset()
      |> Repo.insert()
      |> case do
        {:ok, run} ->
          send(state_machine_pid, {:run_started, run})
          {:ok, run}

        {:error, reason} ->
          {:error, reason}
      end
    else
      {:error, :process_not_found}
    end
  end

  def pass_run_check(run_id, check) do
    from(run in Run, as: :runs)
    |> where([runs: runs], runs.id == ^run_id)
    |> where([runs: runs], is_nil(runs.completed_at) and is_nil(runs.canceled_at))
    |> update([runs: runs],
      set: [checks: fragment("jsonb_set(?, ?, 'true'::jsonb)", runs.checks, [^to_string(check)])]
    )
    |> Repo.update_all([])
    |> case do
      {1, _} ->
        broadcast_run_event(run_id, {:check_passed, run_id, check})
        :ok

      {0, _} ->
        {:error, :not_found}
    end
  end

  def complete_run(%Run{completed_at: nil, canceled_at: nil} = run) do
    run
    |> Run.complete_changeset()
    |> Repo.update()
    |> case do
      {:ok, run} ->
        broadcast_run_event(run, {:completed, run})
        {:ok, run}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def complete_run(%Run{} = run) do
    {:ok, run}
  end

  def cancel_run(%Run{completed_at: nil, canceled_at: nil} = run) do
    run
    |> Run.cancel_changeset()
    |> Repo.update()
    |> case do
      {:ok, run} ->
        broadcast_run_event(run, {:canceled, run})
        {:ok, run}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def cancel_run(%Run{} = run) do
    {:ok, run}
  end

  def cancel_stale_runs! do
    from(run in Run, as: :runs)
    |> where([runs: runs], is_nil(runs.completed_at))
    |> where([runs: runs], is_nil(runs.canceled_at))
    |> where([runs: runs], fragment("? < NOW() - INTERVAL '60 seconds'", runs.started_at))
    |> Repo.all()
    |> Enum.each(&cancel_run/1)
  end

  def country_stats do
    from(s in Views.CountryStats)
    |> Repo.all()
  end

  def reset_materialized_views! do
    Repo.query!("REFRESH MATERIALIZED VIEW CONCURRENTLY country_stats_mv;")
    :ok
  end

  defp run_topic(%Run{} = run), do: run_topic(run.id)
  defp run_topic(run_id), do: "runs:#{run_id}"

  defp broadcast_run_event(run_or_id, event) do
    run_or_id
    |> run_topic()
    |> PubSub.broadcast(event)
  end

  def subscribe_to_run_updates(run_or_id) do
    run_or_id
    |> run_topic()
    |> PubSub.subscribe()
  end
end
