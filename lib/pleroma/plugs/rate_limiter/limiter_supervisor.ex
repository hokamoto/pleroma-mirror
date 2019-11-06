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
       ttl_check_interval: check_interval(expiration),
       global_ttl: expiration}
    )
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  defp check_interval(exp) do
    (exp / 2)
    |> Kernel.trunc()
    |> Kernel.min(5000)
  end
end
