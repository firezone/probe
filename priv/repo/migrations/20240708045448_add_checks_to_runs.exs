defmodule Probe.Repo.Migrations.AddChecksToRuns do
  use Ecto.Migration

  def change do
    alter table(:runs) do
      add :checks, :map, null: false
    end
  end
end
