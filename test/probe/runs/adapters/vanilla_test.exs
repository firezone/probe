defmodule Probe.Runs.Adapters.VanillaTest do
  use Probe.DataCase, async: true
  alias Probe.Runs.Check
  import Probe.Runs.Adapters.Vanilla

  test "generates and handles packets" do
    run = Fixtures.Runs.start_run()
    check = List.first(run.checks)

    assert %{
             initiator: initiator_packet,
             data: data_packet
           } = client_packets(check)

    assert byte_size(initiator_packet) == 116
    assert response_packet = handle_packet(initiator_packet)
    assert byte_size(response_packet) == 92
    assert check = Repo.get(Check, check.id)
    assert check.status == :in_progress

    assert <<2::size(8), 0::size(24), _sender_index::binary-size(4),
             _receiver_index::binary-size(4), _unencrypted_ephemeral::binary-size(32),
             0::size(128), _mac1::binary-size(16), 0::size(128)>> = response_packet

    assert data_response_packet = handle_packet(data_packet)
    assert check = Repo.get(Check, check.id)
    assert check.status == :completed

    assert <<4::size(8), 0::size(24), _sender_index::binary-size(4),
             _counter_binary::binary-size(8),
             _encrypted_encapsulated_packet::binary>> = data_response_packet
  end
end
