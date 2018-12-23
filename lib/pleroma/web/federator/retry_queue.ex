defmodule Pleroma.Web.Federator.RetryQueue do
  @moduledoc """
  """

  use GenServer

  require Logger

  alias Pleroma.Web.ActivityPub.ActivityPub
  alias Pleroma.Web.Websub

  # initial timeout, 5 min
  @initial_timeout 30_000
  @max_retries 5

  #####
  # External API

  def init(args) do
    {:ok, args}
  end

  def start_link() do
    enabled = Pleroma.Config.get([:retry_queue, :enabled], false)

    if enabled do
      Logger.info("Starting retry queue")
      GenServer.start_link(__MODULE__, %{delivered: 0, dropped: 0}, name: __MODULE__)
    else
      Logger.info("Retry queue disabled")
      :ignore
    end
  end

  @doc "Adds to queue."
  @spec enqueue(map(), ActivityPub.t() | Websub.t(), integer()) :: none()
  def enqueue(data, transport, retries \\ 0) do
    GenServer.cast(__MODULE__, {:maybe_enqueue, data, transport, retries + 1})
  end

  #####
  # GenServer implementation

  def handle_cast({:maybe_enqueue, data, transport, retries}, %{dropped: drop_count} = state) do
    case get_retry_params(retries) do
      {:retry, timeout} ->
        Process.send_after(
          __MODULE__,
          {:send, data, transport, retries},
          timeout
        )

        {:noreply, state}

      {:drop, message} ->
        Logger.debug(message)
        {:noreply, %{state | dropped: drop_count + 1}}
    end
  end

  def handle_info({:send, data, transport, retries}, %{delivered: delivery_count} = state) do
    case transport.publish_one(data) do
      {:ok, _} ->
        {:noreply, %{state | delivered: delivery_count + 1}}

      {:error, _reason} ->
        enqueue(data, transport, retries)
        {:noreply, state}
    end
  end

  def handle_info(unknown, state) do
    Logger.debug("RetryQueue: don't know what to do with #{inspect(unknown)}, ignoring")
    {:noreply, state}
  end

  def get_retry_params(retries) do
    if retries > @max_retries do
      {:drop, "Max retries reached"}
    else
      {:retry, growth_function(retries)}
    end
  end

  defp growth_function(retries) do
    round(@initial_timeout * :math.pow(retries, 3))
  end
end
