defmodule Mix.Tasks.User do
  use Mix.Task

  @shortdoc "Manages users"
  def run(args) do
    Pleroma.CLI.User.run(args)
  end
end
