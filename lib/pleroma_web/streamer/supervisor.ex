defmodule PleromaWeb.Streamer.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(args) do
    children = [
      {PleromaWeb.Streamer.State, args},
      {PleromaWeb.Streamer.Ping, args},
      {PleromaWeb.Streamer, args}
    ]

    opts = [strategy: :one_for_one, name: PleromaWeb.Streamer.Supervisor]
    Supervisor.init(children, opts)
  end
end
