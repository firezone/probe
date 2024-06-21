defmodule Probe.UDPServer do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init(opts) do
    port = Keyword.fetch!(opts, :port)
    {:ok, socket} = :gen_udp.open(port, [:binary, :active, {:reuseaddr, true}])
    {:ok, %{socket: socket}}
  end

  @impl true
  def handle_info({:inet, socket, {ip, port}, data}, %{socket: socket} = state) do
    handle_packet(data, ip, port, socket)
    {:noreply, state}
  end

  # Handle initiation packet
  defp handle_packet(
         <<1::size(8), sender_index::size(32)-big, _rest::binary-size(256)>>,
         ip,
         port,
         socket
       ) do
    random_receiver_index = :rand.uniform(0xFFFFFFFF) - 1

    # Type (1 byte), Sender Index (4 bytes), Receiver Index (4 bytes), Empty Payload (16 bytes)
    response_packet =
      <<
        2::size(8),
        sender_index::size(32)-big,
        random_receiver_index::size(32)-big,
        0::size(16)
      >>

    :gen_udp.send(socket, ip, port, response_packet)
  end

  # Handle response packet
  defp handle_packet(<<type::size(8), rest::binary>>, ip, port, _socket) do
    dbg({"Received an unknown packet type", ip, port, type, rest})
  end

  @impl true
  def handle_call(:get_port, _from, %{socket: socket} = state) do
    {:reply, socket.port, state}
  end
end
