defmodule Pleroma.Repo.Migrations.AddAttachmentIndexToObjects do
  use Ecto.Migration

  def change do
    create_if_not_exists(
      index(:objects, ["(data->'attachment')"], using: :gin, name: :objects_attachments)
    )
  end
end
