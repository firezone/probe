defmodule Probe.PubSub do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(_opts) do
    children = [
      {Phoenix.PubSub, name: __MODULE__}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def broadcast(topic, payload) do
    Phoenix.PubSub.broadcast(__MODULE__, topic, payload)
  end

  def subscribe(topic) do
    Phoenix.PubSub.subscribe(__MODULE__, topic)
  end

  def unsubscribe(topic) do
    Phoenix.PubSub.unsubscribe(__MODULE__, topic)
  end
end
