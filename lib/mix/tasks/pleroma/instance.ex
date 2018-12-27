# Pleroma: A lightweight social networking server
# Copyright © 2017-2018 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Mix.Tasks.Pleroma.Instance do
  use Mix.Task
  alias Mix.Tasks.Pleroma.Common

  @shortdoc "Manages Pleroma instance"
  @moduledoc """
  Manages Pleroma instance.

  ## Generate a new instance config.

    mix pleroma.instance gen [OPTION...]

  If any options are left unspecified, you will be prompted interactively

  ## Options

  - `-f`, `--force` - overwrite any output files
  - `-o PATH`, `--output PATH` - the output file for the generated configuration
  - `--output-psql PATH` - the output file for the generated PostgreSQL setup
  - `--domain DOMAIN` - the domain of your instance
  - `--instance-name INSTANCE_NAME` - the name of your instance
  - `--admin-email ADMIN_EMAIL` - the email address of the instance admin
  - `--dbhost HOSTNAME` - the hostname of the PostgreSQL database to use
  - `--dbname DBNAME` - the name of the database to use
  - `--dbuser DBUSER` - the user (aka role) to use for the database connection
  - `--dbpass DBPASS` - the password to use for the database connection
  """

  def run(["gen" | rest]) do
    {options, [], []} =
      OptionParser.parse(
        rest,
        strict: [
          force: :boolean,
          output: :string,
          output_psql: :string,
          domain: :string,
          instance_name: :string,
          admin_email: :string,
          dbhost: :string,
          dbname: :string,
          dbuser: :string,
          dbpass: :string
        ],
        aliases: [
          o: :output,
          f: :force
        ]
      )

    paths =
      [config_path, psql_path] = [
        Keyword.get(options, :output, "config/generated_config.exs"),
        Keyword.get(options, :output_psql, "config/setup_db.psql")
      ]

    will_overwrite = Enum.filter(paths, &File.exists?/1)
    proceed? = Enum.empty?(will_overwrite) or Keyword.get(options, :force, false)

    unless not proceed? do
      [domain, port | _] =
        String.split(
          Common.get_option(
            options,
            :domain,
            "What domain will your instance use? (e.g pleroma.soykaf.com)"
          ),
          ":"
        ) ++ [443]

      name =
        Common.get_option(
          options,
          :name,
          "What is the name of your instance? (e.g. Pleroma/Soykaf)"
        )

      email = Common.get_option(options, :admin_email, "What is your admin email address?")

      dbhost =
        Common.get_option(options, :dbhost, "What is the hostname of your database?", "localhost")

      dbname =
        Common.get_option(options, :dbname, "What is the name of your database?", "pleroma_dev")

      dbuser =
        Common.get_option(
          options,
          :dbuser,
          "What is the user used to connect to your database?",
          "pleroma"
        )

      dbpass =
        Common.get_option(
          options,
          :dbpass,
          "What is the password used to connect to your database?",
          :crypto.strong_rand_bytes(64) |> Base.encode64() |> binary_part(0, 64),
          "autogenerated"
        )

      secret = :crypto.strong_rand_bytes(64) |> Base.encode64() |> binary_part(0, 64)
      {web_push_public_key, web_push_private_key} = :crypto.generate_key(:ecdh, :prime256v1)

      result_config =
        EEx.eval_file(
          "sample_config.eex" |> Path.expand(__DIR__),
          domain: domain,
          port: port,
          email: email,
          name: name,
          dbhost: dbhost,
          dbname: dbname,
          dbuser: dbuser,
          dbpass: dbpass,
          version: Pleroma.Mixfile.project() |> Keyword.get(:version),
          secret: secret,
          web_push_public_key: Base.url_encode64(web_push_public_key, padding: false),
          web_push_private_key: Base.url_encode64(web_push_private_key, padding: false)
        )

      result_psql =
        EEx.eval_file(
          "sample_psql.eex" |> Path.expand(__DIR__),
          dbname: dbname,
          dbuser: dbuser,
          dbpass: dbpass
        )

      Mix.shell().info(
        "Writing config to #{config_path}. You should rename it to config/prod.secret.exs or config/dev.secret.exs."
      )

      File.write(config_path, result_config)
      Mix.shell().info("Writing #{psql_path}.")
      File.write(psql_path, result_psql)

      Mix.shell().info(
        "\n" <>
          """
          To get started:
          1. Verify the contents of the generated files.
          2. Run `sudo -u postgres psql -f #{Common.escape_sh_path(psql_path)}`.
          """ <>
          if config_path in ["config/dev.secret.exs", "config/prod.secret.exs"] do
            ""
          else
            "3. Run `mv #{Common.escape_sh_path(config_path)} 'config/prod.secret.exs'`."
          end
      )
    else
      Mix.shell().error(
        "The task would have overwritten the following files:\n" <>
          (Enum.map(paths, &"- #{&1}\n") |> Enum.join("")) <>
          "Rerun with `--force` to overwrite them."
      )
    end
  end
end
