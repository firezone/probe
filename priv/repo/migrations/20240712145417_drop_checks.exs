defmodule Probe.Repo.Migrations.DropChecks do
  use Ecto.Migration

  def change do
    drop table(:run_checks)
  end
end
