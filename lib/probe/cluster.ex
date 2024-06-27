defmodule Probe.Cluster do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__.Supervisor)
  end

  def init(_opts) do
    children = [
      {DNSCluster, query: Application.get_env(:probe, :dns_cluster_query) || :ignore}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
