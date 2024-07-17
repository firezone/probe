defmodule Probe.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    :logger.add_handler(:sentry_handler, Sentry.LoggerHandler, %{
      config: %{metadata: [:file, :line]}
    })

    children = [
      Probe.Telemetry,
      Probe.Repo,
      Probe.Cluster,
      Probe.PubSub,
      Probe.Runs,
      Probe.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Probe.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    Probe.Endpoint.config_change(changed, removed)
    :ok
  end
end
