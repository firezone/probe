defmodule Probe.Runs.Adapters.ServerTest do
  use ExUnit.Case, async: true
  alias Probe.Runs.Server

  @ping <<1::size(8)>>
  @pong <<2::size(8)>>

  setup do
    server_opts = [port: 0, adapter: __MODULE__, adapter_config: [test_pid: self()]]
    {:ok, server_pid} = start_supervised({Server, server_opts})
    server_port = GenServer.call(server_pid, :get_port)

    {:ok, client_socket} = :gen_udp.open(0, [:binary, {:active, true}, {:reuseaddr, true}])
    :gen_udp.connect(client_socket, {127, 0, 0, 1}, server_port)

    on_exit(fn ->
      :gen_udp.close(client_socket)
    end)

    {:ok, %{server_pid: server_pid, server_port: server_port, client_socket: client_socket}}
  end

  test "initiates to WireGuard connection and receives data packet", %{
    client_socket: client_socket,
    server_port: server_port
  } do
    # Send
    :gen_udp.send(client_socket, {127, 0, 0, 1}, server_port, @ping)
    assert_receive {:client_packet, @ping}

    # Receive
    assert_receive {:udp, ^client_socket, {127, 0, 0, 1}, _client_port, @pong}
  end

  def handle_packet(packet, test_pid: test_pid) do
    send(test_pid, {:client_packet, packet})
    @pong
  end
end
