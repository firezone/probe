defmodule Probe.Runs.Adapters do
  use Supervisor
  alias Probe.Runs
  alias Probe.Runs.Adapters

  @modules %{
    vanilla: Adapters.Vanilla
  }

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__.Supervisor)
  end

  def init(_opts) do
    children = Map.values(@modules)
    Supervisor.init(children, strategy: :one_for_one)
  end

  def client_packets(%Runs.Check{} = check) do
    adapter_module!(check.adapter).client_packets(check)
  end

  def port(%Runs.Check{} = check) do
    adapter_module!(check.adapter).port()
  end

  defp adapter_module!(adapter) do
    Map.fetch!(@modules, adapter)
  end
end
