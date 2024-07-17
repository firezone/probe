defmodule Probe.Repo.Migrations.AddStats do
  use Ecto.Migration

  def change do
    # TODO: those should be materialized views
    create table(:country_stats, primary_key: false) do
      add :country, :string, primary_key: true
      add :num_completed, :integer
      add :num_succeeded, :integer

      timestamps(type: :utc_datetime_usec)
    end

    create table(:region_stats, primary_key: false) do
      add :region, :string, primary_key: true
      add :num_completed, :integer
      add :num_succeeded, :integer

      timestamps(type: :utc_datetime_usec)
    end

    create table(:city_stats, primary_key: false) do
      add :city, :string, primary_key: true
      add :num_completed, :integer
      add :num_succeeded, :integer

      timestamps(type: :utc_datetime_usec)
    end

    create table(:provider_stats, primary_key: false) do
      add :provider, :string, primary_key: true
      add :num_completed, :integer
      add :num_succeeded, :integer

      timestamps(type: :utc_datetime_usec)
    end
  end
end
