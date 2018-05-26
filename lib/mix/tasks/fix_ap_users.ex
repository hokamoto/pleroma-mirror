defmodule Mix.Tasks.FixApUsers do
  use Mix.Task
  import Ecto.Query
  alias Pleroma.{Repo, User}

  @shortdoc "Grab all ap users again"
  def run([]) do
    Pleroma.CLI.FixApUsers.run()
  end
end
