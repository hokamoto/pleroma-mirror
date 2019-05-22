defmodule Pleroma.Config.TransferTask do
  use Task
  alias Pleroma.Web.AdminAPI.Config

  def start_link do
    Pleroma.Repo.all(Config)
    |> Enum.each(&update_env(&1))

    if Mix.env() == :test, do: Ecto.Adapters.SQL.Sandbox.checkin(Pleroma.Repo)
    :ignore
  end

  defp update_env(setting) do
    try do
      Application.put_env(
        :pleroma,
        String.to_existing_atom(setting.key),
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
