defmodule Probe.Runs.TimeoutServer do
  use GenServer
  alias Probe.Runs

  @tick 1_000

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_) do
    :ok = schedule_tick()
    {:ok, %{}}
  end

  defp schedule_tick do
    Process.send_after(self(), :tick, @tick)
    :ok
  end

  def handle_info(:tick, state) do
    :ok = Runs.cancel_stale_runs!()
    :ok = schedule_tick()
    {:noreply, state}
  end
end
