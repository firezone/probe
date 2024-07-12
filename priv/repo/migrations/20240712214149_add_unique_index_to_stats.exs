defmodule Probe.Repo.Migrations.AddUniqueIndexToStats do
  use Ecto.Migration

  def change do
    create unique_index(:country_stats, [:country])
    create unique_index(:region_stats, [:region])
    create unique_index(:city_stats, [:city])
    create unique_index(:provider_stats, [:provider])
  end
end
