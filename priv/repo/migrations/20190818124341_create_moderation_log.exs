defmodule Pleroma.Repo.Migrations.CreateModerationLog do
  use Ecto.Migration

  def change do
    create table(:moderation_log) do
      add(:data, :map)
      add(:user_id, references(:users, type: :uuid, on_delete: :delete_all))

      timestamps()
    end

    create(index(:moderation_log, [:user_id]))
  end
end
