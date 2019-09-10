defmodule PleromaWeb.Streamer.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(args) do
    children = [
      {PleromaWeb.Streamer.State, args},
      {PleromaWeb.Streamer.Ping, args},
      {PleromaWeb.Streamer.Worker, args},
      {PleromaWeb.Streamer, args},
  #    :poolboy.child_spec(:streamer_worker, poolboy_config())
    ]

    opts = [strategy: :one_for_one, name: PleromaWeb.Streamer.Supervisor]
    Supervisor.init(children, opts)
  end


#  defp poolboy_config do
#    [
#      {:name, {:local, :streamer_worker}},
#      {:worker_module, PleromaWeb.Streamer.Worker},
#      {:size, 10},
#      {:max_overflow, 2}
#    ]
#  end
end
