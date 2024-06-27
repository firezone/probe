defmodule Probe.Runs.Server do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init(opts) do
    port = Keyword.fetch!(opts, :port)
    adapter = Keyword.fetch!(opts, :adapter)
    adapter_config = Keyword.get(opts, :adapter_config, [])

    {:ok, socket} = :gen_udp.open(port, [:binary, {:active, true}, {:reuseaddr, true}])
    {:ok, %{socket: socket, adapter: adapter, adapter_config: adapter_config}}
  end

  @impl true
  def handle_info({:udp, socket, ip, port, data}, state) do
    %{adapter: adapter, adapter_config: adapter_config} = state
    response_packet = adapter.handle_packet(data, adapter_config)
    :gen_udp.send(socket, ip, port, response_packet)
    {:noreply, state}
  end

  @impl true
  def handle_call(:get_port, _from, %{socket: socket} = state) do
    {:ok, port} = :inet.port(socket)
    {:reply, port, state}
  end
end
