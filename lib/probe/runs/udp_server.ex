defmodule Probe.Runs.UdpServer do
  use GenServer
  alias Probe.Runs

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

    <<1::size(8), 0::size(24), 0::size(32), run_id_bytes::binary, r(16)::binary, r(32)::binary,
      r(12)::binary, r(16)::binary, r(16)::binary>>
  end

  def generate_handshake_response_payload(%Runs.Run{} = run) do
    {:ok, run_id_bytes} = Ecto.UUID.dump(run.id)

    <<2::size(8), 0::size(24), 0::size(32), 0::size(32), run_id_bytes::binary, r(16)::binary,
      r(16)::binary, r(16)::binary, r(16)::binary>>
  end

  def generate_cookie_reply_payload(%Runs.Run{} = run) do
    {:ok, run_id_bytes} = Ecto.UUID.dump(run.id)

    <<3::size(8), 0::size(24), 0::size(32), run_id_bytes::binary, r(176)::binary, r(16)::binary,
      r(16)::binary>>
  end

  def generate_data_payload(%Runs.Run{} = run) do
    {:ok, run_id_bytes} = Ecto.UUID.dump(run.id)

    <<4::size(8), 0::size(24), 0::size(32), 0::size(64), run_id_bytes::binary, r(1024)::binary>>
  end

  # Handle handshake initiation packet
  def handle_packet(
        <<1::size(8), _reserved::size(24), _sender_index::size(32), run_id::binary-size(16),
          _rest_unencrypted_ephemeral::binary-size(16), _encrypted_static::binary-size(32),
          _encrypted_timestamp::binary-size(12), _mac1::binary-size(16), _mac2::binary-size(16),
          _rest::binary>>
      ) do
    with {:ok, run_id} <- Ecto.UUID.load(run_id),
         {:ok, run} <- Runs.fetch_run(run_id) do
      Probe.PubSub.broadcast("run:#{run.topic}", :handshake_initiation)
    else
      _ -> {:error, :invalid_run_id}
    end
  end

  # Handle handshake response packet
  def handle_packet(
        <<2::size(8), _reserved::size(24), _sender_index::size(32), _receiver_index::size(32),
          run_id::binary-size(16), _rest_unencrypted_ephemeral::binary-size(16), _empty::size(0),
          _mac1::binary-size(16), _mac2::binary-size(16), _rest::binary>>
      ) do
    with {:ok, run_id} <- Ecto.UUID.load(run_id),
         {:ok, run} <- Runs.fetch_run(run_id) do
      Probe.PubSub.broadcast("run:#{run.topic}", :handshake_response)
    else
      _ -> {:error, :invalid_run_id}
    end
  end

  # Handle cookie reply packet
  def handle_packet(
        <<3::size(8), _reserved::size(24), _receiver_index::size(32), run_id::binary-size(16),
          _remaining_nonce::size(176), _cookie::binary-size(16), _rest::binary>>
      ) do
    with {:ok, run_id} <- Ecto.UUID.load(run_id),
         {:ok, run} <- Runs.fetch_run(run_id) do
      Probe.PubSub.broadcast("run:#{run.topic}", :cookie_reply)
    else
      _ -> {:error, :invalid_run_id}
    end
  end

  # Handle data packet
  def handle_packet(
        <<4::size(8), _reserved::size(24), _receiver_index::size(32), _counter::size(64),
          run_id::binary-size(16), _remaining_encapsulated_packet::binary>>
      ) do
    with {:ok, run_id} <- Ecto.UUID.load(run_id),
         {:ok, run} <- Runs.fetch_run(run_id) do
      Probe.PubSub.broadcast("run:#{run.topic}", :data_message)
    else
      _ -> {:error, :invalid_run_id}
    end
  end

  # Handle other packets
  def handle_packet(_packet) do
    {:error, :invalid_packet}
  end

  defp r(size) do
    :crypto.strong_rand_bytes(size)
  end
end
