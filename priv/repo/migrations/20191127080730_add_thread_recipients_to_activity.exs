defmodule Pleroma.Repo.Migrations.AddThreadRecipientsToActivity do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      add(:thread_recipients, {:array, :string})
    end

    create_if_not_exists(index(:activities, [:thread_recipients], using: :gin))
  end
end
