defmodule Pleroma.Storage.Repo.Migrations.DropLocalIndexOnActivities do
  use Ecto.Migration

  def change do
    drop_if_exists(index(:users, [:local]))
  end
end
