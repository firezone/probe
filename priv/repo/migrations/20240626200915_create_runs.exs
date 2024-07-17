defmodule Probe.Repo.Migrations.CreateRuns do
  use Ecto.Migration

  def change do
    create table(:runs, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :remote_ip_location_country, :string, null: false
      add :remote_ip_location_region, :string
      add :remote_ip_location_city, :string
      add :remote_ip_location_lat, :float
      add :remote_ip_location_lon, :float
      add :remote_ip_provider, :string

      add :port, :integer, null: false
      add :checks, :map, null: false

      add :anonymized_id, :string, null: false

      timestamps(type: :utc_datetime_usec, inserted_at: :started_at)
      add :canceled_at, :utc_datetime_usec
      add :completed_at, :utc_datetime_usec
    end

    create index(:runs, [:started_at], where: "completed_at IS NULL AND canceled_at IS NULL")
  end
end
