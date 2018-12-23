defmodule Pleroma.Repo.Migrations.CreateFederationQueue do
  use Ecto.Migration

  def change do
    create table(:federation_queues) do
      add :domain, :string
      add :success_at, :utc_datetime
    end

    create unique_index(:federation_queues, [:domain])
  end
end
