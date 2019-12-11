defmodule Pleroma.Repo.Migrations.DropObjectIdJsonIndex do
  use Ecto.Migration

  def change do
    drop_if_exists(unique_index(:objects, ["(data->>'id')"], name: :objects_unique_apid_index))
  end
end
