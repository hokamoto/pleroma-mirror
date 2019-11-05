defmodule Pleroma.Repo.Migrations.CreateExNicknames do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:ex_nicknames) do
      add(:user_id, references(:users, type: :uuid, on_delete: :delete_all))
      add(:nickname, :string, null: false)
      timestamps()
    end

    create_if_not_exists(unique_index(:ex_nicknames, [:nickname]))
  end
end
