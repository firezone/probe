defmodule Probe.RunsRun do
  use Probe.DataCase, async: true
  import Probe.Runs

  describe "fetch_run/1" do
    test "returns error on invalid id" do
      assert fetch_run(Ecto.UUID.generate()) == {:error, :not_found}
      assert fetch_run("foo") == {:error, :not_found}
      assert fetch_run(1) == {:error, :not_found}
    end

    test "returns run" do
      run = Fixtures.Runs.start_run()
      assert fetch_run(run.id) == {:ok, run}
    end
  end

  describe "start_run/2" do
    test "returns error on empty attrs" do
      pid = self()

      assert {:error, %Ecto.Changeset{} = changeset} = start_run(pid, %{})

      assert errors_on(changeset) == %{
               port: ["can't be blank"],
               remote_ip_location_country: ["can't be blank"]
             }
    end

    test "creates a run" do
      pid = self()
      attrs = Fixtures.Runs.run_attrs()

      assert {:ok, %Probe.Runs.Run{} = run} = start_run(pid, attrs)

      assert run.remote_ip_location_country == attrs.remote_ip_location_country
      assert run.remote_ip_location_region == attrs.remote_ip_location_region
      assert run.remote_ip_location_city == attrs.remote_ip_location_city
      assert run.remote_ip_location_lat == attrs.remote_ip_location_lat
      assert run.remote_ip_location_lon == attrs.remote_ip_location_lon
      assert run.remote_ip_provider == attrs.remote_ip_provider

      assert run.checks == %Probe.Runs.Checks{}

      assert_receive {:run_started, ^run}
    end
  end

  describe "pass_run_check/2" do
    test "sets run check to true" do
      run = Fixtures.Runs.start_run()
      run_id = run.id
      subscribe_to_run_updates(run)

      assert pass_run_check(run.id, :turn_handshake_initiation) == :ok
      assert_receive {:check_passed, ^run_id, :turn_handshake_initiation}

      assert pass_run_check(run.id, :cookie_reply) == :ok
      assert_receive {:check_passed, ^run_id, :cookie_reply}

      assert {:ok, run} = fetch_run(run.id)

      assert run.checks == %Probe.Runs.Checks{
               cookie_reply: true,
               turn_handshake_initiation: true
             }
    end
  end

  describe "complete_run/1" do
    test "completes a run" do
      run = Fixtures.Runs.start_run()
      subscribe_to_run_updates(run)

      assert {:ok, %Probe.Runs.Run{} = completed_run} = complete_run(run)

      assert completed_run.completed_at
      refute completed_run.canceled_at

      assert_receive {:completed, ^completed_run}
    end
  end

  describe "cancel_run/1" do
    test "cancels a run" do
      run = Fixtures.Runs.start_run()
      subscribe_to_run_updates(run)

      assert {:ok, %Probe.Runs.Run{} = canceled_run} = cancel_run(run)

      assert canceled_run.canceled_at
      refute canceled_run.completed_at

      assert_receive {:canceled, ^canceled_run}
    end
  end

  describe "cancel_stale_runs!/0" do
    test "cancels runs that started more than 15 seconds ago" do
      run = Fixtures.Runs.start_run()
      subscribe_to_run_updates(run)

      assert cancel_stale_runs!() == :ok
      assert {:ok, %Probe.Runs.Run{} = run} = fetch_run(run.id)
      refute run.canceled_at
      refute_received {:canceled, ^run}

      run
      |> Ecto.Changeset.change(started_at: DateTime.utc_now() |> DateTime.add(-20, :second))
      |> Repo.update!()

      assert cancel_stale_runs!() == :ok
      assert {:ok, %Probe.Runs.Run{} = canceled_run} = fetch_run(run.id)
      assert canceled_run.canceled_at
      assert_receive {:canceled, ^canceled_run}
    end
  end
end
