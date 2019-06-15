defmodule Mix.Tasks.Pleroma.MigrateTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog
  require Logger

  test "ecto.migrate info messages" do
    level = Logger.level()
    Logger.configure(level: :warn)

    assert capture_log(fn ->
             Mix.Tasks.Pleroma.Migrate.run()
           end) =~ "[info] Already up"

    Logger.configure(level: level)
  end
end
