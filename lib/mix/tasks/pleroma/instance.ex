# Pleroma: A lightweight social networking server
# Copyright © 2017-2020 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Mix.Tasks.Pleroma.Instance do
  use Mix.Task
  import Mix.Pleroma
  alias Pleroma.Crypto

  alias Pleroma.Config

  @shortdoc "Manages Pleroma instance"
  @moduledoc File.read!("docs/administration/CLI_tasks/instance.md")

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
          notify_email: :string,
          dbhost: :string,
          dbname: :string,
          dbuser: :string,
          dbpass: :string,
          rum: :string,
          indexable: :string,
          db_configurable: :string,
          uploads_dir: :string,
          static_dir: :string,
          listen_ip: :string,
          listen_port: :string
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

    if proceed? do
      [domain, port | _] =
        String.split(
          get_option(
            options,
            :domain,
            "What domain will your instance use? (e.g pleroma.soykaf.com)"
          ),
          ":"
        ) ++ [443]

      name =
        get_option(
          options,
          :instance_name,
          "What is the name of your instance? (e.g. The Corndog Emporium)",
          domain
        )

      email = get_option(options, :admin_email, "What is your admin email address?")

      notify_email =
        get_option(
          options,
          :notify_email,
          "What email address do you want to use for sending email notifications?",
          email
        )

      indexable =
        get_option(
          options,
          :indexable,
          "Do you want search engines to index your site? (y/n)",
          "y"
        ) === "y"

      db_configurable? =
        get_option(
          options,
          :db_configurable,
          "Do you want to store the configuration in the database (allows controlling it from admin-fe)? (y/n)",
          "n"
        ) === "y"

      dbhost = get_option(options, :dbhost, "What is the hostname of your database?", "localhost")

      dbname = get_option(options, :dbname, "What is the name of your database?", "pleroma")

      dbuser =
        get_option(
          options,
          :dbuser,
          "What is the user used to connect to your database?",
          "pleroma"
        )

      dbpass =
        get_option(
          options,
          :dbpass,
          "What is the password used to connect to your database?",
          64 |> Crypto.random_string() |> binary_part(0, 64),
          "autogenerated"
        )

      rum_enabled =
        get_option(
          options,
          :rum,
          "Would you like to use RUM indices?",
          "n"
        ) === "y"

      listen_port =
        get_option(
          options,
          :listen_port,
          "What port will the app listen to (leave it if you are using the default setup with nginx)?",
          4000
        )

      listen_ip =
        get_option(
          options,
          :listen_ip,
          "What ip will the app listen to (leave it if you are using the default setup with nginx)?",
          "127.0.0.1"
        )

      uploads_dir =
        get_option(
          options,
          :uploads_dir,
          "What directory should media uploads go in (when using the local uploader)?",
          Pleroma.Config.get([Pleroma.Upload.Uploader.Local, :uploads])
        )

      static_dir =
        get_option(
          options,
          :static_dir,
          "What directory should custom public files be read from (custom emojis, frontend bundle overrides, robots.txt, etc.)?",
          Pleroma.Config.get([:instance, :static_dir])
        )

      Config.put([:instance, :static_dir], static_dir)

      secret = 64 |> Crypto.random_string() |> binary_part(0, 64)
      jwt_secret = 64 |> Crypto.random_string() |> binary_part(0, 64)
      signing_salt = 8 |> Crypto.random_string() |> binary_part(0, 8)

      {web_push_public_key, web_push_private_key} = :crypto.generate_key(:ecdh, :prime256v1)
      template_dir = Application.app_dir(:pleroma, "priv") <> "/templates"

      result_config =
        EEx.eval_file(
          template_dir <> "/sample_config.eex",
          domain: domain,
          port: port,
          email: email,
          notify_email: notify_email,
          name: name,
          dbhost: dbhost,
          dbname: dbname,
          dbuser: dbuser,
          dbpass: dbpass,
          secret: secret,
          jwt_secret: jwt_secret,
          signing_salt: signing_salt,
          web_push_public_key: Base.url_encode64(web_push_public_key, padding: false),
          web_push_private_key: Base.url_encode64(web_push_private_key, padding: false),
          db_configurable?: db_configurable?,
          static_dir: static_dir,
          uploads_dir: uploads_dir,
          rum_enabled: rum_enabled,
          listen_ip: listen_ip,
          listen_port: listen_port
        )

      result_psql =
        EEx.eval_file(
          template_dir <> "/sample_psql.eex",
          dbname: dbname,
          dbuser: dbuser,
          dbpass: dbpass,
          rum_enabled: rum_enabled
        )

      shell_info("Writing config to #{config_path}.")

      File.write(config_path, result_config)
      shell_info("Writing the postgres script to #{psql_path}.")
      File.write(psql_path, result_psql)

      write_robots_txt(indexable, template_dir)

      shell_info(
        "\n All files successfully written! Refer to the installation instructions for your platform for next steps."
      )

      if db_configurable? do
        shell_info(
          " Please transfer your config to the database after running database migrations. Refer to \"Transfering the config to/from the database\" section of the docs for more information."
        )
      end
    else
      shell_error(
        "The task would have overwritten the following files:\n" <>
          (Enum.map(paths, &"- #{&1}\n") |> Enum.join("")) <>
          "Rerun with `--force` to overwrite them."
      )
    end
  end

  defp write_robots_txt(indexable, template_dir) do
    robots_txt =
      EEx.eval_file(
        template_dir <> "/robots_txt.eex",
        indexable: indexable
      )

    static_dir = Pleroma.Config.get([:instance, :static_dir], "instance/static/")

    unless File.exists?(static_dir) do
      File.mkdir_p!(static_dir)
    end

    robots_txt_path = Path.join(static_dir, "robots.txt")

    if File.exists?(robots_txt_path) do
      File.cp!(robots_txt_path, "#{robots_txt_path}.bak")
      shell_info("Backing up existing robots.txt to #{robots_txt_path}.bak")
    end

    File.write(robots_txt_path, robots_txt)
    shell_info("Writing #{robots_txt_path}.")
  end
end
