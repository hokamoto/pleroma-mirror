defmodule Pleroma.Repo.Migrations.AddNotNullConstraints do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      modify(:data, :map, null: false)
      modify(:local, :boolean, null: false, default: true)
    end

    alter table(:activity_expirations) do
      modify(:activity_id, references(:activities, type: :uuid, on_delete: :delete_all))
    end

    alter table(:apps) do
    end
  end
end
