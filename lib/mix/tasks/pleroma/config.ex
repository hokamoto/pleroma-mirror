defmodule Mix.Tasks.Pleroma.Config do
  use Mix.Task
  alias Mix.Tasks.Pleroma.Common
  alias Pleroma.Repo
  alias Pleroma.Web.AdminAPI.Config
  @shortdoc "Manages the location of the config"
  @moduledoc """
  Manages the location of the config.

  ## Transfers config from file to DB.

      mix pleroma.config migrate_to_db

  ## Transfers config from DB to file.

      mix pleroma.config migrate_from_db ENV
  """

  @compile_time_settings [Pleroma.Repo, Pleroma.Captcha, :hackney_pools]

  def run(["migrate_to_db"]) do
    Common.start_pleroma()

    Application.get_all_env(:pleroma)
    |> Enum.reject(fn {k, _v} -> k in @compile_time_settings end)
    |> Enum.each(fn {k, v} ->
      key = to_string(k) |> String.replace("Elixir.", "")
      {:ok, _} = Config.update_or_create(%{key: key, value: v})
      Mix.shell().info("#{key} is migrated.")
    end)

    Mix.shell().info("Settings migrated.")
  end

  def run(["migrate_from_db", env]) do
    Common.start_pleroma()

    path = "config/#{env}.secret"
    backup_path = path <> ".bak"
    config_path = path <> ".exs"
    File.cp(config_path, backup_path, fn _, _ -> false end)

    {:ok, file} = File.open(config_path, [:append])

    Repo.all(Config)
    |> Enum.each(fn config ->
      mark = if String.starts_with?(config.key, "Pleroma."), do: ",", else: ":"

      IO.write(
        file,
        "config :pleroma, #{config.key}#{mark} #{inspect(Config.from_binary(config.value))}\r\n"
      )

      {:ok, _} = Repo.delete(config)
      Mix.shell().info("#{config.key} deleted from DB.")
    end)

    File.close(file)
    System.cmd("mix", ["format", config_path])
  end
end
