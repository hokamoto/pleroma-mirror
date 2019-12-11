defmodule Pleroma.Repo.Migrations.AddActivityApIdField do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      add(:object_ap_id, :varchar)
    end

    create(index(:activities, [:object_ap_id]))
  end
end
