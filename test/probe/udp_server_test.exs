defmodule Probe.UDPServerTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, client_socket} = :gen_udp.open(0, binary: true, active: true)
    {:ok, server_pid} = start_supervised(Probe.UDPServer, port: 0, handler: self())
    server_port = GenServer.call(server_pid, :get_port)
    {:ok, %{client_socket: client_socket, server_port: server_port, server_pid: server_pid}}
  end

  test "it starts a UDP server", %{client_socket: client_socket, server_port: server_port} do
    random_sender_index = :rand.uniform(0xFFFFFFFF) - 1
    random_unencrypted_ephemeral = :crypto.strong_rand_bytes(256)

    initiation_packet =
      <<
        1::size(8),
        random_sender_index::size(32)-big,
        random_unencrypted_ephemeral::binary-size(256)
      >>

    # Send wireguard handshake initiation
    :gen_udp.send(client_socket, {127, 0, 0, 1}, server_port, initiation_packet)

    # Wait for the response
    assert_receive {:udp, ^server_port, {127, 0, 0, 1}, response_packet}

    # assert byte_size(response_packet) == 92

    assert <<
             2::size(8),
             ^random_sender_index::size(32)-big,
             _receiver_index::size(32)-big,
             0::size(128)
           >> = response_packet
  end

  defp generate_packet(:initiation) do
    # Assuming a simplified packet structure for initiation
    # Type (1 byte), Sender Index (4 bytes), Unencrypted Ephemeral (32 bytes)
    <<1::size(8), 1234::size(32)-big, 32::binary-size(256)>>
  end

  defp generate_packet(:response) do
    # Type (1 byte), Sender Index (4 bytes), Receiver Index (4 bytes), Empty Payload (16 bytes)
    <<2::size(8), 1234::size(32)-big, 5678::size(32)-big, 16::binary-size(128)>>
  end

  defp generate_packet(:cookie) do
    # Type (1 byte), Receiver Index (4 bytes), Cookie (16 bytes)
    <<3::size(8), 5678::size(32)-big, 16::binary-size(128)>>
  end
end
