defmodule Probe.Repo.Migrations.AddTopicToRuns do
  use Ecto.Migration

  def change do
    alter table(:runs) do
      add :topic, :string, null: false, index: true, unique: true
    end
  end
end
