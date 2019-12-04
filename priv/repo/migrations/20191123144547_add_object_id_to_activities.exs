defmodule Pleroma.Repo.Migrations.AddObjectIdToActivities do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      add(:object_id, :integer)
    end
  end
end
