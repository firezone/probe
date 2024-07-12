defmodule Probe.Repo.Migrations.AddStartCompletedTimestampsToRuns do
  use Ecto.Migration

  def change do
    alter table(:runs) do
      add :started_at, :utc_datetime_usec
      add :completed_at, :utc_datetime_usec
    end
  end
end
