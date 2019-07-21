defmodule Pleroma.Repo.Migrations.CreateFederationFailures do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:federation_failures) do
      add(:activity_id, references(:activities, type: :uuid, on_delete: :delete_all))
      add(:recipient, :string, null: false)
      add(:transport, :string, null: false)
      add(:retries_count, :integer, default: 0)

      timestamps()
    end

    create_if_not_exists(unique_index(:federation_failures, [:activity_id, :recipient, :transport]))
  end
end
