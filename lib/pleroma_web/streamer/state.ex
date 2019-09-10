defmodule PleromaWeb.Streamer.State do
  use GenServer
  require Logger

  alias PleromaWeb.Streamer.StreamerSocket

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{sockets: %{}, streams: []}, name: __MODULE__)
  end

  def add_socket(topic, socket) do
    GenServer.call(__MODULE__, %{action: :add, socket: socket, topic: topic})
  end

  def remove_socket(topic, socket) do
    GenServer.call(__MODULE__, %{action: :remove, socket: socket, topic: topic})
  end

  def get_sockets() do
    %{sockets: stream_sockets} = GenServer.call(__MODULE__, :get_state)
    stream_sockets
  end

  def add_stream_item(topic, item) do
    GenServer.call(__MODULE__, %{action: :add, item: item, topic: topic})
  end



  def init(init_arg) do
    {:ok, init_arg}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call(
        %{action: :add, topic: topic, socket: socket},
        _from,
        %{sockets: sockets} = state
      ) do
    internal_topic = internal_topic(topic, socket)
    stream_socket = StreamerSocket.from_socket(socket)

    sockets_for_topic =
      sockets
      |> Map.get(internal_topic, [])
      |> List.insert_at(0, stream_socket)
      |> Enum.uniq()

    state = Kernel.put_in(state, [:sockets, internal_topic], sockets_for_topic)
    Logger.debug("Got new conn for #{topic}")
    {:reply, state, state}
  end

  def handle_call(
        %{action: :add, topic: topic, item: _item},
        _from,
        %{streams: _streams} = state
      ) do


    state = Map.put(state, :streams, [])
    Logger.debug("Got new conn for #{topic}")
    {:reply, state, state}
  end

  def handle_call(
        %{action: :remove, topic: topic, socket: socket},
        _from,
        %{sockets: sockets} = state
      ) do
    internal_topic = internal_topic(topic, socket)
    stream_socket = PleromaWeb.Streamer.StreamerSocket.from_socket(socket)

    sockets_for_topic =
      sockets
      |> Map.get(internal_topic, [])
      |> List.delete(stream_socket)

    state = Kernel.put_in(state, [:sockets, internal_topic], sockets_for_topic)
    {:reply, state, state}
  end

  defp internal_topic(topic, socket)
       when topic in ~w[user user:notification direct] do
    "#{topic}:#{socket.assigns[:user].id}"
  end

  defp internal_topic(topic, _) do
    topic
  end
end
