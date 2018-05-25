defmodule Pleroma.Release.MigrateTask do
  require Logger

  def migrate do
    {:ok, _} = Application.ensure_all_started(:pleroma)
    path = Application.app_dir(:pleroma, "priv/repo/migrations")
    Ecto.Migrator.run(Pleroma.Repo, path, :up, all: true)
    :ok
  end

end
