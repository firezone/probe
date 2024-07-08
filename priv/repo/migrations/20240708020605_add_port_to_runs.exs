defmodule Probe.Repo.Migrations.AddPortToRuns do
  use Ecto.Migration

  def change do
    alter table(:runs) do
      add :port, :integer, null: false
    end
  end
end
