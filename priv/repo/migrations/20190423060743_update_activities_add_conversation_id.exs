defmodule Pleroma.Repo.Migrations.UpdateActivitiesAddConversationId do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      add(:conversation_id, references(:conversations, on_delete: :nothing),
        default: nil,
        null: true
      )
    end

    create(index(:activities, [:conversation_id]))
  end
end
