defmodule Probe.Repo.Migrations.CreateRuns do
  use Ecto.Migration

  def change do
    create table(:runs, primary_key: false) do
      add :id, :uuid, primary_key: true

      add :remote_ip_location_country, :string, null: false
      add :remote_ip_location_region, :string
      add :remote_ip_location_city, :string
      add :remote_ip_location_lat, :float, null: false
      add :remote_ip_location_lon, :float, null: false
      add :remote_ip_provider, :string

      timestamps(type: :utc_datetime_usec)
    end
  end
end
