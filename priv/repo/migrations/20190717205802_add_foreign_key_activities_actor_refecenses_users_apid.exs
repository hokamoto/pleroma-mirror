defmodule Pleroma.Repo.Migrations.AddForeignKeyActivitiesActorReferencesUsersApid do
  use Ecto.Migration

  def up do
    execute "DELETE FROM activities WHERE activities.actor not in (SELECT ap_id FROM users)"

    alter table :activities do
      modify :actor, references(:users, type: :varchar, column: :ap_id, on_delete: :delete_all, on_update: :update_all)
    end
  end

  def down do
    drop constraint(:activities, "activities_actor_fkey")
  end
end
