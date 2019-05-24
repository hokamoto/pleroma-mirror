defmodule Pleroma.Config.TransferTask do
  use Task
  alias Pleroma.Web.AdminAPI.Config

  def start_link do
    load_and_update_env()
    if Mix.env() == :test, do: Ecto.Adapters.SQL.Sandbox.checkin(Pleroma.Repo)
    :ignore
  end

  def load_and_update_env do
    Pleroma.Repo.all(Config)
    |> Enum.each(&update_env(&1))
  end

  defp update_env(setting) do
    try do
      key =
        if String.starts_with?(setting.key, "Pleroma.") do
          "Elixir." <> setting.key
        else
          setting.key
        end

      Application.put_env(
        :pleroma,
        String.to_existing_atom(key),
        Config.from_binary(setting.value)
      )
    rescue
      e ->
        require Logger

        Logger.warn(
          "updating env causes error, key: #{inspect(setting.key)}, error: #{inspect(e)}"
        )
    end
  end
end
