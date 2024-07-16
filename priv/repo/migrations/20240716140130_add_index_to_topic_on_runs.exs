defmodule Probe.Repo.Migrations.AddIndexToTopicOnRuns do
  use Ecto.Migration

  def change do
    create index(:runs, [:topic])
  end
end
