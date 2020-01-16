defmodule Pleroma.Repo.Migrations.AddWithMediaToActivities do
  use Ecto.Migration
  @disable_ddl_transaction true
  @disable_migration_lock true

  def change do
    alter table(:activities) do
      add_if_not_exists(:with_media, :boolean, default: false, null: false)
    end

    create(index(:activities, [:with_media], concurrently: true))
  end
end
