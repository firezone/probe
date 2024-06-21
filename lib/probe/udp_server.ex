defmodule Probe.UDPServer do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init(opts) do
    port = Keyword.fetch!(opts, :port)
    {:ok, socket} = :gen_udp.open(port, [:binary, {:active, true}, {:reuseaddr, true}])
    {:ok, %{socket: socket}}
  end

  @impl true
  def handle_info({:udp, socket, ip, port, data}, %{socket: socket} = state) do
    handle_packet(data, ip, port, socket)
    {:noreply, state}
  end

  # Handle initiation packet
  defp handle_packet(
         <<1::size(8), _reserved::size(24), sender_index::size(32),
           _unencrypted_ephemeral::binary-size(32), _encrypted_static::binary-size(32),
           _encrypted_timestamp::binary-size(12), _mac1::binary-size(16),
           _mac2::binary-size(16)>>,
         ip,
         port,
         socket
       ) do
    receiver_index = :crypto.strong_rand_bytes(4)
    unencrypted_ephemeral = :crypto.strong_rand_bytes(32)
    mac1 = :crypto.strong_rand_bytes(16)

    response_packet =
      <<2::size(8), 0::size(24), sender_index::size(32), receiver_index::binary-size(4),
        unencrypted_ephemeral::binary-size(32), 0::size(128), mac1::binary-size(16),
        0::size(128)>>

    :gen_udp.send(socket, ip, port, response_packet)
  end

  # Handle data packet
  defp handle_packet(
         <<4::size(8), 0::size(24), _receiver_index::binary-size(4),
           counter_binary::binary-size(8), sender_index::binary-size(4),
           encrypted_encapsulated_packet::binary>>,
         ip,
         port,
         socket
       ) do
    data_packet =
      <<4::size(8), 0::size(24), sender_index::binary-size(4), counter_binary::binary-size(8),
        encrypted_encapsulated_packet::binary>>

    :gen_udp.send(socket, ip, port, data_packet)
  end

  # Handle other packets
  defp handle_packet(<<type::size(8), rest::binary>>, ip, port, _socket) do
    dbg({"Received an unknown packet type", ip, port, type, rest})
  end

  @impl true
  def handle_call(:get_port, _from, %{socket: socket} = state) do
    {:ok, port} = :inet.port(socket)
    {:reply, port, state}
  end
end
