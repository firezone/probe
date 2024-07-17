defmodule Probe.Runs.UDPServer do
  use GenServer
  alias Probe.Runs
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def child_spec(opts) do
    %{
      id: "#{__MODULE__}-#{opts[:port]}",
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  @impl true
  def init(opts) do
    port = Keyword.fetch!(opts, :port)

    {:ok, socket} =
      :gen_udp.open(port, [
        :binary,
        {:active, true},
        {:ip, Application.fetch_env!(:probe, :udp_bind_address)}
      ])

    {:ok, socket}
  end

  @impl true
  def handle_info({:udp, _socket, _ip, _port, packet}, socket) do
    handle_packet(packet)
    {:noreply, socket}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  def generate_handshake_initiation_payload(%Runs.Run{} = run) do
    {:ok, run_id_bytes} = Ecto.UUID.dump(run.id)

    # Use the first 4 bytes of the run ID as a consistent sender for
    # the duration of the test. This attempts to mimic WireGuard traffic
    # more accurately. This isn't used for lookups so doesn't need to
    # be globally unique.
    <<sender::binary-size(4), _remaining_id_bytes::binary-size(12)>> = run_id_bytes

    # Not intended for crypto operations, only for a more realistic payload
    {ephemeral, _private_key} = :crypto.generate_key(:ecdh, :x25519)

    <<1::size(8), 0::size(24), sender::binary, ephemeral::binary, r(48)::binary, r(28)::binary,
      run_id_bytes::binary, 0::size(128)>>
  end

  def generate_handshake_response_payload(%Runs.Run{} = run) do
    {:ok, run_id_bytes} = Ecto.UUID.dump(run.id)

    <<_remaining_id_bytes::binary-size(12), sender::binary-size(4)>> = run_id_bytes
    <<receiver::binary-size(4), _remaining_id_bytes::binary-size(12)>> = run_id_bytes

    # Not intended for crypto operations, only for a more realistic payload
    {ephemeral, _private_key} = :crypto.generate_key(:ecdh, :x25519)

    <<2::size(8), 0::size(24), sender::binary, receiver::binary, ephemeral::binary, r(16)::binary,
      run_id_bytes::binary, 0::size(128)>>
  end

  def generate_cookie_reply_payload(%Runs.Run{} = run) do
    {:ok, run_id_bytes} = Ecto.UUID.dump(run.id)

    <<receiver::binary-size(4), _remaining_id_bytes::binary-size(12)>> = run_id_bytes

    <<3::size(8), 0::size(24), receiver::binary, r(24)::binary, run_id_bytes::binary,
      r(16)::binary>>
  end

  def generate_data_message_payload(%Runs.Run{} = run) do
    {:ok, run_id_bytes} = Ecto.UUID.dump(run.id)

    <<receiver::binary-size(4), _remaining_id_bytes::binary-size(12)>> = run_id_bytes

    <<4::size(8), 0::size(24), receiver::binary, r(8)::binary, run_id_bytes::binary,
      r(64)::binary>>
  end

  def generate_turn_handshake_initiation_payload(%Runs.Run{} = run) do
    <<turn_header()::binary, generate_handshake_initiation_payload(run)::binary>>
  end

  def generate_turn_handshake_response_payload(%Runs.Run{} = run) do
    <<turn_header()::binary, generate_handshake_response_payload(run)::binary>>
  end

  def generate_turn_cookie_reply_payload(%Runs.Run{} = run) do
    <<turn_header()::binary, generate_cookie_reply_payload(run)::binary>>
  end

  def generate_turn_data_message_payload(%Runs.Run{} = run) do
    <<turn_header()::binary, generate_data_message_payload(run)::binary>>
  end

  # Handle handshake initiation packet
  def handle_packet(
        <<1::size(8), _reserved::size(24), _sender_index::size(32), _ephemeral::binary-size(32),
          _encrypted_static::binary-size(48), _encrypted_timestamp::binary-size(28),
          run_id::binary-size(16), _mac2::binary-size(16)>>
      ) do
    pass(run_id, :handshake_initiation)
  end

  # Handle handshake response packet
  def handle_packet(
        <<2::size(8), _reserved::size(24), _sender_index::size(32), _receiver_index::size(32),
          _ephemeral::binary-size(32), _encrypted_empty::binary-size(16), run_id::binary-size(16),
          _mac2::binary-size(16)>>
      ) do
    pass(run_id, :handshake_response)
  end

  # Handle cookie reply packet
  def handle_packet(
        <<3::size(8), _reserved::size(24), _receiver_index::size(32), _nonce::binary-size(24),
          run_id::binary-size(16), _remaining_encrypted_cookie::binary-size(16)>>
      ) do
    pass(run_id, :cookie_reply)
  end

  # Handle data packet
  def handle_packet(
        <<4::size(8), _reserved::size(24), _receiver_index::size(32), _counter::size(64),
          run_id::binary-size(16), _remaining_encapsulated_packet::binary>>
      ) do
    pass(run_id, :data_message)
  end

  # Handle TURN + handshake initiation packet
  def handle_packet(
        <<_turn_header::size(32), 1::size(8), _reserved::size(24), _sender_index::size(32),
          _ephemeral::binary-size(32), _encrypted_static::binary-size(48),
          _encrypted_timestamp::binary-size(28), run_id::binary-size(16), _mac2::binary-size(16)>>
      ) do
    pass(run_id, :turn_handshake_initiation)
  end

  # Handle TURN + handshake response packet
  def handle_packet(
        <<_turn_header::size(32), 2::size(8), _reserved::size(24), _sender_index::size(32),
          _receiver_index::size(32), _ephemeral::binary-size(32),
          _encrypted_empty::binary-size(16), run_id::binary-size(16), _mac2::binary-size(16)>>
      ) do
    pass(run_id, :turn_handshake_response)
  end

  # Handle TURN + cookie reply packet
  def handle_packet(
        <<_turn_header::size(32), 3::size(8), _reserved::size(24), _receiver_index::size(32),
          _nonce::binary-size(24), run_id::binary-size(16),
          _remaining_encrypted_cookie::binary-size(16)>>
      ) do
    pass(run_id, :turn_cookie_reply)
  end

  # Handle TURN + data packet
  def handle_packet(
        <<_turn_header::size(32), 4::size(8), _reserved::size(24), _receiver_index::size(32),
          _counter::size(64), run_id::binary-size(16), _remaining_encapsulated_packet::binary>>
      ) do
    pass(run_id, :turn_data_message)
  end

  # Handle other packets
  def handle_packet(packet) do
    Logger.info("Received invalid packet: #{Base.encode64(packet)}")
    {:error, :invalid_packet}
  end

  defp r(size) do
    :crypto.strong_rand_bytes(size)
  end

  defp pass(run_id, check) do
    with {:ok, run_id} <- Ecto.UUID.load(run_id),
         :ok <- Runs.pass_run_check(run_id, check) do
      :ok
    else
      _ ->
        {:error, :invalid_run_id}
    end
  end

  defp turn_header do
    # Channel number (2 bytes) + Length (2 bytes)
    <<r(2)::binary, r(2)::binary>>
  end
end
