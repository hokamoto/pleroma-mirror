# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.InstanceTest do
  use ExUnit.Case, async: true

  setup do
    File.mkdir_p!(tmp_path())

    config =
      Application.loaded_applications()
      |> Enum.map(fn {application, _, _} ->
        {application, Application.get_all_env(application)}
      end)

    on_exit(fn ->
      File.rm_rf(tmp_path())
      Application.put_all_env(config)
    end)

    :ok
  end

  defp tmp_path do
    "/tmp/generated_files/"
  end

  test "running gen" do
    mix_task = fn ->
      Mix.Tasks.Pleroma.Instance.run([
        "gen",
        "--output",
        tmp_path() <> "generated_config.exs",
        "--output-psql",
        tmp_path() <> "setup.psql",
        "--domain",
        "test.pleroma.social",
        "--instance-name",
        "Pleroma",
        "--admin-email",
        "admin@example.com",
        "--notify-email",
        "notify@example.com",
        "--dbhost",
        "dbhost",
        "--dbname",
        "dbname",
        "--dbuser",
        "dbuser",
        "--dbpass",
        "dbpass",
        "--indexable",
        "n",
        "--db-configurable",
        "y",
        "--rum",
        "y",
        "--listen-port",
        "4000",
        "--listen-ip",
        "127.0.0.1",
        "--uploads-dir",
        "test/uploads",
        "--static-dir",
        tmp_path() <> "/static/"
      ])
    end

    ExUnit.CaptureIO.capture_io(fn ->
      mix_task.()
    end)

    generated_config = File.read!(tmp_path() <> "generated_config.exs")
    assert generated_config =~ "host: \"test.pleroma.social\""
    assert generated_config =~ "name: \"Pleroma\""
    assert generated_config =~ "email: \"admin@example.com\""
    assert generated_config =~ "notify_email: \"notify@example.com\""
    assert generated_config =~ "hostname: \"dbhost\""
    assert generated_config =~ "database: \"dbname\""
    assert generated_config =~ "username: \"dbuser\""
    assert generated_config =~ "password: \"dbpass\""
    assert generated_config =~ "dynamic_configuration: true"
    assert generated_config =~ "http: [ip: {127, 0, 0, 1}, port: 4000]"
    assert File.read!(tmp_path() <> "setup.psql") == generated_setup_psql()
    assert File.exists?(tmp_path() <> "static/robots.txt")
  end

  defp generated_setup_psql do
    ~s(CREATE USER dbuser WITH ENCRYPTED PASSWORD 'dbpass';\nCREATE DATABASE dbname OWNER dbuser;\n\\c dbname;\n--Extensions made by ecto.migrate that need superuser access\nCREATE EXTENSION IF NOT EXISTS citext;\nCREATE EXTENSION IF NOT EXISTS pg_trgm;\nCREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";\nCREATE EXTENSION IF NOT EXISTS rum;\n)
  end
end
