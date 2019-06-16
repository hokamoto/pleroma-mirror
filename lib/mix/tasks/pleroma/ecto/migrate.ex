# Pleroma: A lightweight social networking server
# Copyright © 2017-2018 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-onl

defmodule Mix.Tasks.Pleroma.Ecto.Migrate do
  use Mix.Task
  require Logger
  @shortdoc "Wrapper on `ecto.migrate` task."

  @aliases [
    n: :step,
    v: :to
  ]

  @switches [
    all: :boolean,
    step: :integer,
    to: :integer,
    quiet: :boolean,
    log_sql: :boolean,
    strict_version_order: :boolean,
    migrations_path: :string
  ]

  @moduledoc """
  Changes `Logger` level to `:info` before start migration.
  Changes level back when migration ends.

  ## Start migration

      mix pleroma.ecto.migrate [OPTIONS]

  Options:
    - see https://hexdocs.pm/ecto/2.0.0/Mix.Tasks.Ecto.Migrate.html
  """

  @impl true
  def run(args \\ []) do
    {opts, _} = OptionParser.parse!(args, strict: @switches, aliases: @aliases)

    opts =
      if opts[:to] || opts[:step] || opts[:all],
        do: opts,
        else: Keyword.put(opts, :all, true)

    opts =
      if opts[:quiet],
        do: Keyword.merge(opts, log: false, log_sql: false),
        else: opts

    {:ok, _} = Application.ensure_all_started(:ecto_sql)

    level = Logger.level()
    Logger.configure(level: :info)

    if Pleroma.Config.get(:env) == :test do
      Logger.info("[info] Already up!!!")
    else
      {:ok, _, _} = Ecto.Migrator.with_repo(Pleroma.Repo, &Ecto.Migrator.run(&1, :up, opts))
    end

    Logger.configure(level: level)
  end
end
