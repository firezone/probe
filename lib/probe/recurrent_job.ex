defmodule Probe.RecurrentJob do
  use GenServer

  def start_link({every, run}) do
    GenServer.start_link(__MODULE__, {every, run})
  end

  def child_spec(opts) do
    every = Keyword.fetch!(opts, :every)
    run = Keyword.fetch!(opts, :run)

    %{
      id: {__MODULE__, every, run},
      start: {__MODULE__, :start_link, [{every, run}]}
    }
  end

  @impl true
  def init({every, run}) do
    :ok = schedule_tick(every)
    {:ok, %{every: every, run: run}}
  end

  defp schedule_tick(every) do
    Process.send_after(self(), :tick, every)
    :ok
  end

  @impl true
  def handle_info(:tick, %{every: every, run: run} = state) do
    :ok = run.()
    :ok = schedule_tick(every)
    {:noreply, state}
  end
end
