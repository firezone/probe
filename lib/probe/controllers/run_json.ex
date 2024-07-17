defmodule Probe.Controllers.RunJSON do
  use Probe, :controller

  def show(%{run: run, address: address}) do
    %{
      run_id: run.id,
      address: address,
      port: run.port,
      checks: run.checks
    }
  end
end
