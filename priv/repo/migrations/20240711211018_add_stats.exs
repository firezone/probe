defmodule Probe.Repo.Migrations.AddStats do
  use Ecto.Migration

  def change do
    create table(:country_stats) do
      add :country, :string, null: false, unique: true
      add :num_runs, :integer
      add :num_succeeded, :integer

      timestamps(type: :utc_datetime_usec)
    end

    create table(:region_stats) do
      add :region, :string, null: false, unique: true
      add :num_runs, :integer
      add :num_succeeded, :integer

      timestamps(type: :utc_datetime_usec)
    end

    create table(:city_stats) do
      add :city, :string, null: false, unique: true
      add :num_runs, :integer
      add :num_succeeded, :integer

      timestamps(type: :utc_datetime_usec)
    end

    create table(:provider_stats) do
      add :provider, :string, null: false, unique: true
      add :num_runs, :integer
      add :num_succeeded, :integer

      timestamps(type: :utc_datetime_usec)
    end
  end
end
