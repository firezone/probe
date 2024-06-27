defmodule Probe.Controllers.RunJSON do
  use Probe, :controller
  alias Probe.Runs

  def show(%{run: run, address: address}) do
    %{
      run_id: run.id,
      address: address,
      checks: Enum.map(run.checks, &show_check/1)
    }
  end

  defp show_check(check) do
    packets =
      for {type, binary} <- Runs.Adapters.client_packets(check), into: %{} do
        {type, Base.encode64(binary)}
      end

    %{
      adapter: check.adapter,
      port: Runs.Adapters.port(check),
      packets: packets
    }
  end
end
