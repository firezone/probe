defmodule Probe.RunsRun do
  use Probe.DataCase, async: true
  import Probe.Runs

  describe "start_run/1" do
    test "returns error on empty attrs" do
      assert {:error, %Ecto.Changeset{} = changeset} = start_run(%{})

      assert errors_on(changeset) == %{
               remote_ip_location_country: ["can't be blank"]
             }
    end

    test "creates a test" do
      attrs = Fixtures.Runs.run_attrs()

      assert {:ok, %Probe.Runs.Run{} = run} = start_run(attrs)

      assert run.remote_ip_location_country == attrs.remote_ip_location_country
      assert run.remote_ip_location_region == attrs.remote_ip_location_region
      assert run.remote_ip_location_city == attrs.remote_ip_location_city
      assert run.remote_ip_location_lat == attrs.remote_ip_location_lat
      assert run.remote_ip_location_lon == attrs.remote_ip_location_lon
      assert run.remote_ip_provider == attrs.remote_ip_provider
    end

    test "creates run checks" do
      attrs = Fixtures.Runs.run_attrs()

      assert {:ok, %Probe.Runs.Run{} = run} = start_run(attrs)

      assert Enum.count(run.checks) == 4

      assert Enum.map(run.checks, & &1.adapter) == [
               :vanilla,
               :non_standard_port,
               :random_initial_mac2,
               :variable_message_length
             ]

      assert Enum.all?(run.checks, &(&1.status == :pending))
    end
  end

  describe "update_check/3" do
    test "updates the status of a check" do
      run = Fixtures.Runs.start_run()
      check = Enum.at(run.checks, 0)

      :ok = subscribe_to_run_updates(run)

      assert {:ok, %Probe.Runs.Check{} = updated_check} = update_check(check.id, :completed)

      assert updated_check.id == check.id
      assert updated_check.run_id == run.id
      assert updated_check.adapter == check.adapter
      assert updated_check.status == :completed

      assert_receive {:check_updated, %{adapter: adapter, status: status}}
      assert adapter == check.adapter
      assert status == :completed
    end
  end
end
