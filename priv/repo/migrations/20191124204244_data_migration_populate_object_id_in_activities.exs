defmodule Pleroma.Repo.Migrations.DataMigrationPopulateObjectIdInActivities do
  use Ecto.Migration

  def up do
    execute("""
    UPDATE activities
    SET object_id = objects.id
    FROM objects
    WHERE objects.data->>'id' =
      COALESCE(activities.data->'object'->>'id', activities.data->>'object')
    """)
  end

  def down, do: :noop
end
