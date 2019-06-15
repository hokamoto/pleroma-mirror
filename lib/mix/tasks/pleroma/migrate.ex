defmodule Mix.Tasks.Pleroma.Migrate do
  use Mix.Task
  require Logger
  @shortdoc "Wrapper on `ecto.migrate` task."
  @moduledoc """
  Changes `Logger` level to `:info` before start migration.
  Changes level back when migration ends.

  ## Start migration
      mix pleroma.migrate [OPTIONS]

  Options:
    - see https://hexdocs.pm/ecto/2.0.0/Mix.Tasks.Ecto.Migrate.html
  """

  defdelegate run_migration(args, migrator), to: Mix.Tasks.Ecto.Migrate, as: :run

  @impl true
  def run(args \\ [], migrator \\ &Ecto.Migrator.run/4) do
    level = Logger.level()
    Logger.configure(level: :info)
    run_migration(args, migrator)
    Logger.configure(level: level)
  end
end
