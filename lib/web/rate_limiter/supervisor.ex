defmodule Pleroma.Web.RateLimiter.Supervisor do
  use Supervisor

  alias Pleroma.Web.RateLimiter

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_args) do
    children = [RateLimiter.LimiterSupervisor]

    opts = [strategy: :one_for_one, name: Pleroma.Web.Streamer.Supervisor]
    Supervisor.init(children, opts)
  end
end
