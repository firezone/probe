defmodule Probe.Runs.Adapters.VanillaTest do
  use ExUnit.Case, async: true
  # import Probe.Runs.Adapters.Vanilla

  # setup do
  #   server_port = port()

  #   {:ok, client_socket} = :gen_udp.open(0, [:binary, {:active, true}, {:reuseaddr, true}])
  #   :gen_udp.connect(client_socket, {127, 0, 0, 1}, server_port)

  #   on_exit(fn ->
  #     :gen_udp.close(client_socket)
  #   end)

  #   {:ok, %{server_port: server_port, client_socket: client_socket}}
  # end

  # test "initiates to WireGuard connection and receives data packet", %{
  #   client_socket: client_socket,
  #   server_port: server_port
  # } do
  #   dbg(self())

  #   {sender_index, initiation_packet} = generate_initiator_packet()
  #   assert byte_size(initiation_packet) == 116

  #   # Send wireguard handshake initiation
  #   :gen_udp.send(client_socket, {127, 0, 0, 1}, server_port, initiation_packet)

  #   # Wait for the response
  #   assert_receive {:udp, ^client_socket, {127, 0, 0, 1}, _client_port, response_packet}
  #   assert byte_size(response_packet) == 92

  #   assert <<2::size(8), 0::size(24), ^sender_index::binary-size(4),
  #            receiver_index::binary-size(4), _unencrypted_ephemeral::binary-size(32),
  #            0::size(128), _mac1::binary-size(16), 0::size(128)>> = response_packet

  #   # Send data packet
  #   counter = :rand.uniform(:math.pow(2, 64) |> trunc()) - 1
  #   counter_binary = :binary.encode_unsigned(counter, :little)
  #   encrypted_encapsulated_packet = :crypto.strong_rand_bytes(128)

  #   data_packet =
  #     <<4::size(8), 0::size(24), receiver_index::binary-size(4), counter_binary::binary-size(8),
  #       sender_index::binary-size(4), encrypted_encapsulated_packet::binary>>

  #   :gen_udp.send(client_socket, {127, 0, 0, 1}, server_port, data_packet)

  #   # Receive the response
  #   assert_receive {:udp, ^client_socket, {127, 0, 0, 1}, _client_port, response_data_packet}

  #   assert <<4::size(8), 0::size(24), ^sender_index::binary-size(4),
  #            ^counter_binary::binary-size(8),
  #            ^encrypted_encapsulated_packet::binary>> = response_data_packet
  # end

  # def generate_initiator_packet do
  #   sender_index = :crypto.strong_rand_bytes(4)
  #   unencrypted_ephemeral = :crypto.strong_rand_bytes(32)
  #   encrypted_static = :crypto.strong_rand_bytes(32)
  #   encrypted_timestamp = :crypto.strong_rand_bytes(12)
  #   mac1 = :crypto.strong_rand_bytes(16)
  #   mac2 = :crypto.strong_rand_bytes(16)

  #   {sender_index,
  #    <<
  #      1::size(8),
  #      0::size(24),
  #      sender_index::binary,
  #      unencrypted_ephemeral::binary,
  #      encrypted_static::binary,
  #      encrypted_timestamp::binary,
  #      mac1::binary,
  #      mac2::binary
  #    >>}
  # end
end
