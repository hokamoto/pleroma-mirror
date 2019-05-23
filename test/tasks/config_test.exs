defmodule Mix.Tasks.Pleroma.ConfigTest do
  use Pleroma.DataCase
  alias Pleroma.Repo
  alias Pleroma.Web.AdminAPI.Config

  setup_all do
    Mix.shell(Mix.Shell.Process)
    temp_path = "config/temp.secret"
    temp_file = temp_path <> ".exs"
    temp_back = temp_path <> ".bak"

    on_exit(fn ->
      Mix.shell(Mix.Shell.IO)
      Application.delete_env(:pleroma, :first_setting)
      Application.delete_env(:pleroma, :second_setting)
      :ok = File.rm(temp_file)
      :ok = File.rm(temp_back)
    end)

    {:ok, temp_file: temp_file, temp_back: temp_back}
  end

  test "settings are migrated to db" do
    assert Repo.all(Config) == []

    Application.put_env(:pleroma, :first_setting, key: "value", key2: [Pleroma.Repo])
    Application.put_env(:pleroma, :second_setting, key: "value2", key2: [Pleroma.Activity])

    Mix.Tasks.Pleroma.Config.run(["migrate_to_db"])

    first_db = Config.get_by_key("first_setting")
    second_db = Config.get_by_key("second_setting")

    assert Config.from_binary(first_db.value) == [key: "value", key2: [Pleroma.Repo]]
    assert Config.from_binary(second_db.value) == [key: "value2", key2: [Pleroma.Activity]]
  end

  test "settings are migrated to file and deleted from db", %{
    temp_file: temp_file,
    temp_back: temp_back
  } do
    Config.create(%{key: "setting_first", value: [key: "value", key2: [Pleroma.Activity]]})
    Config.create(%{key: "setting_second", value: [key: "valu2", key2: [Pleroma.Repo]]})

    Mix.Tasks.Pleroma.Config.run(["migrate_from_db", "temp"])

    assert Repo.all(Config) == []
    assert File.exists?(temp_file)
    assert File.exists?(temp_back)
    {:ok, file} = File.read(temp_file)

    assert file =~ "config :pleroma, setting_first:"
    assert file =~ "config :pleroma, setting_second:"
  end
end
