defmodule Pleroma.Repo.Migrations.CreateMrfPolicies do
  use Ecto.Migration

  def change do
    create table(:mrf_policies, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :policy, :text, null: false
      add :data, :map, null: false

      timestamps()
    end

    create index(:mrf_policies, :policy, [unique: true])
    create index(:mrf_policies, :data, [unique: true])
  end
end
