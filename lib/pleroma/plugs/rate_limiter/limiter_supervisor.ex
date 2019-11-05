defmodule Pleroma.Plugs.RateLimiter.LimiterSupervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def add_limiter(limiter_name, expiration) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {ConCache,
       name: limiter_name,
       ttl_check_interval: Kernel.trunc(expiration / 2),
       global_ttl: expiration}
    )
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
