defmodule Probe.Repo.Migrations.CreateRunChecks do
  use Ecto.Migration

  def change do
    create table(:run_checks, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :adapter, :string, null: false
      add :status, :string, null: false

      add :run_id, references(:runs, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:run_checks, [:status])
  end
end
