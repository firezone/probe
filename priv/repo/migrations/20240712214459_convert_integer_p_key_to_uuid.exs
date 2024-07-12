defmodule Probe.Repo.Migrations.ConvertIntegerPKeyToUUID do
  use Ecto.Migration

  @tables ~w[
    country_stats
    region_stats
    city_stats
    provider_stats
  ]

  def change do
    for table <- @tables do
      alter table(table) do
        add :uuid, :uuid, null: false
      end

      rename table(table), :id, to: :integer_id
      rename table(table), :uuid, to: :id

      execute "ALTER TABLE #{table} DROP CONSTRAINT #{table}_pkey"
      execute "ALTER TABLE #{table} ADD PRIMARY KEY (id)"

      alter table(table) do
        remove :integer_id
      end

      execute "DROP SEQUENCE IF EXISTS #{table}_id_seq"
    end
  end
end
