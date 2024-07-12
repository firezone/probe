defmodule Probe.Runs.Adapters.Vanilla do
  use Supervisor
  alias Probe.Runs

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__.Supervisor)
  end

  def init(_opts) do
    # Start a child for each port 
    children =
      Application.fetch_env!(:probe, :port_options)
      |> Enum.map(fn {_, {_external_port, internal_port}} ->
        {Probe.Runs.UdpServer, [port: internal_port]}
      end)

    Supervisor.init(children, strategy: :one_for_one)
  end

  def client_packets(%Runs.Check{} = check) do
    sender_index = :crypto.strong_rand_bytes(4)
    initiator_packet = generate_initiator_packet(check.id, sender_index)
    data_packet = generate_data_packet(check.id, sender_index)

    %{
      initiator: initiator_packet,
      data: data_packet
    }
  end

  defp generate_initiator_packet(check_id, sender_index) do
    unencrypted_ephemeral = Ecto.UUID.dump!(check_id) <> :crypto.strong_rand_bytes(16)
    encrypted_static = :crypto.strong_rand_bytes(32)
    encrypted_timestamp = :crypto.strong_rand_bytes(12)
    mac1 = :crypto.strong_rand_bytes(16)

    <<
      1::size(8),
      0::size(24),
      sender_index::binary,
      unencrypted_ephemeral::binary,
      encrypted_static::binary,
      encrypted_timestamp::binary,
      mac1::binary,
      0::size(128)
    >>
  end

  defp generate_data_packet(check_id, sender_index) do
    counter = :rand.uniform(:math.pow(2, 64) |> trunc()) - 1
    counter_binary = :binary.encode_unsigned(counter, :little)
    receiver_index = :rand.uniform(:math.pow(2, 64) |> trunc()) - 1
    encrypted_encapsulated_packet = Ecto.UUID.dump!(check_id) <> :crypto.strong_rand_bytes(128)

    <<4::size(8), 0::size(24), receiver_index::size(32), sender_index::binary-size(4),
      counter_binary::binary-size(8), encrypted_encapsulated_packet::binary>>
  end

  # Handle handshake initiation packet
  def handle_packet(
        <<1::size(8), _reserved::size(24), sender_index::size(32), check_id::binary-size(16),
          _rest_unencrypted_ephemeral::binary-size(16), _encrypted_static::binary-size(32),
          _encrypted_timestamp::binary-size(12), _mac1::binary-size(16), _mac2::binary-size(16)>>
      ) do
    {:ok, check_id} = Ecto.UUID.load(check_id)
    {:ok, _check} = Runs.update_check(check_id, :in_progress)

    receiver_index = :rand.uniform(:math.pow(2, 64) |> trunc()) - 1
    unencrypted_ephemeral = :crypto.strong_rand_bytes(32)
    mac1 = :crypto.strong_rand_bytes(16)

    <<2::size(8), 0::size(24), sender_index::size(32), receiver_index::size(32),
      unencrypted_ephemeral::binary-size(32), 0::size(128), mac1::binary-size(16), 0::size(128)>>
  end

  # Handle handshake response packet
  def handle_packet(
        <<2::size(8), _reserved::size(24), sender_index::size(32), check_id::binary-size(16),
          _rest_unencrypted_ephemeral::binary-size(16), _encrypted_static::binary-size(32),
          _encrypted_timestamp::binary-size(12), _mac1::binary-size(16), _mac2::binary-size(16)>>
      ) do
    {:ok, check_id} = Ecto.UUID.load(check_id)
    {:ok, _check} = Runs.update_check(check_id, :in_progress)

    receiver_index = :rand.uniform(:math.pow(2, 64) |> trunc()) - 1
    unencrypted_ephemeral = :crypto.strong_rand_bytes(32)
    mac1 = :crypto.strong_rand_bytes(16)

    <<2::size(8), 0::size(24), sender_index::size(32), receiver_index::size(32),
      unencrypted_ephemeral::binary-size(32), 0::size(128), mac1::binary-size(16), 0::size(128)>>
  end

  # Handle cookie reply packet
  def handle_packet(
        <<3::size(8), _reserved::size(24), sender_index::size(32), check_id::binary-size(16),
          _rest_unencrypted_ephemeral::binary-size(16), _encrypted_static::binary-size(32),
          _encrypted_timestamp::binary-size(12), _mac1::binary-size(16), _mac2::binary-size(16)>>
      ) do
    {:ok, check_id} = Ecto.UUID.load(check_id)
    {:ok, _check} = Runs.update_check(check_id, :in_progress)

    receiver_index = :rand.uniform(:math.pow(2, 64) |> trunc()) - 1
    unencrypted_ephemeral = :crypto.strong_rand_bytes(32)
    mac1 = :crypto.strong_rand_bytes(16)

    <<2::size(8), 0::size(24), sender_index::size(32), receiver_index::size(32),
      unencrypted_ephemeral::binary-size(32), 0::size(128), mac1::binary-size(16), 0::size(128)>>
  end

  # Handle data packet
  def handle_packet(
        <<4::size(8), 0::size(24), _receiver_index::size(32), counter_binary::binary-size(8),
          sender_index::binary-size(4), check_id::binary-size(16),
          rest_encrypted_encapsulated_packet::binary>>
      ) do
    {:ok, check_id} = Ecto.UUID.load(check_id)
    {:ok, _check} = Runs.update_check(check_id, :completed)

    <<4::size(8), 0::size(24), sender_index::binary-size(4), counter_binary::binary-size(8),
      rest_encrypted_encapsulated_packet::binary>>
  end

  # Handle other packets
  def handle_packet(<<_type::size(8), _rest::binary>>) do
    <<>>
  end
end
