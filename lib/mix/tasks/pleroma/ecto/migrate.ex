# Pleroma: A lightweight social networking server
# Copyright © 2017-2018 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-onl

defmodule Mix.Tasks.Pleroma.Ecto.Migrate do
  use Mix.Task
  require Logger
  @shortdoc "Wrapper on `ecto.migrate` task."
  @moduledoc """
  Changes `Logger` level to `:info` before start migration.
  Changes level back when migration ends.

  ## Start migration

      mix pleroma.ecto.migrate [OPTIONS]

  Options:
    - see https://hexdocs.pm/ecto/2.0.0/Mix.Tasks.Ecto.Migrate.html
  """

  defdelegate run_migrations(args, migrator), to: Mix.Tasks.Ecto.Migrate, as: :run

  @impl true
  def run(args \\ [], migrator \\ &Ecto.Migrator.run/4) do
    level = Logger.level()
    Logger.configure(level: :info)

    if Pleroma.Config.get(:env) == :test do
      Logger.info("[info] Already up!!!")
    else
      run_migrations(args, migrator)
    end

    Logger.configure(level: level)
  end
end
