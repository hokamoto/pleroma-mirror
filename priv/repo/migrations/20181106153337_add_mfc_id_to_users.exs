defmodule Pleroma.Repo.Migrations.AddMfcIdToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :mfc_id, :string
    end

    create index(:users, [:mfc_id])
  end
end
