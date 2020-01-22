defmodule Pleroma.Repo.Migrations.AddThreadRecipientsToActivity do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      add(:thread_recipients, {:array, :string}, default: [], null: false)
    end

    create_if_not_exists(index(:activities, [:thread_recipients], using: :gin))

    Mix.Pleroma.shell_error(
      "\nMigration to update pre-existing activities has been removed from automatic run due to long execution. If necessary, you can perform it manually with the choice of the period for updating.\n" <>
        "Details: https://docs-develop.pleroma.social/backend/administration/CLI_tasks/database/#fix-thread_recipients-for-pre-existing-activities"
    )
  end
end
