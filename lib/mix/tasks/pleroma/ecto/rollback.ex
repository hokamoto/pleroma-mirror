# Pleroma: A lightweight social networking server
# Copyright © 2017-2018 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-onl

defmodule Mix.Tasks.Pleroma.Ecto.Rollback do
  use Mix.Task
  require Logger
  @shortdoc "Wrapper on `ecto.rollback` task"
  @moduledoc """
  Changes `Logger` level to `:info` before start rollback.
  Changes level back when rollback ends.

  ## Start rollback

      mix pleroma.ecto.rollback

  Options:
    - see https://hexdocs.pm/ecto/2.0.0/Mix.Tasks.Ecto.Rollback.html
  """

  defdelegate run_rollback(args, migrator), to: Mix.Tasks.Ecto.Rollback, as: :run

  @impl true
  def run(args \\ [], migrator \\ &Ecto.Migrator.run/4) do
    level = Logger.level()
    Logger.configure(level: :info)

    if Pleroma.Config.get(:env) == :test do
      Logger.info("[info] Rollback succesfully")
    else
      run_rollback(args, migrator)
    end

    Logger.configure(level: level)
  end
end
