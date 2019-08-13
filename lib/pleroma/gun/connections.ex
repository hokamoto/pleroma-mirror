# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Gun.Connections do
  use GenServer

  @type domain :: String.t()
  @type conn :: Gun.Conn.t()
  @type t :: %__MODULE__{
          conns: %{domain() => conn()}
        }

  defstruct conns: %{}

  def start_link(name \\ __MODULE__) do
    if Application.get_env(:tesla, :adapter) == Tesla.Adapter.Gun do
      GenServer.start_link(__MODULE__, [], name: name)
    else
      :ignore
    end
  end

  @impl true
  def init(_) do
    {:ok, %__MODULE__{conns: %{}}}
  end

  @spec get_conn(atom(), String.t(), keyword()) :: pid()
  def get_conn(name \\ __MODULE__, url, opts \\ []) do
    opts = Enum.into(opts, %{})
    uri = URI.parse(url)

    opts = if uri.scheme == "https", do: Map.put(opts, :transport, :tls), else: opts

    GenServer.call(
      name,
      {:conn, %{opts: opts, uri: uri}}
    )
  end

  @spec get_state(atom()) :: t()
  def get_state(name \\ __MODULE__) do
    GenServer.call(name, {:state})
  end

  @impl true
  def handle_call({:conn, %{opts: opts, uri: uri}}, from, state) do
    key = compose_key(uri)

    case state.conns[key] do
      %{conn: conn, state: conn_state} when conn_state == :up ->
        {:reply, conn, state}

      %{state: conn_state, waiting_pids: pids} when conn_state in [:open, :down] ->
        state = put_in(state.conns[key].waiting_pids, [from | pids])
        {:noreply, state}

      nil ->
        {:ok, conn} = Pleroma.Gun.API.open(to_charlist(uri.host), uri.port, opts)

        state =
          put_in(state.conns[key], %Pleroma.Gun.Conn{
            conn: conn,
            waiting_pids: [from],
            protocol: String.to_atom(uri.scheme)
          })

        {:noreply, state}
    end
  end

  @impl true
  def handle_call({:state}, _from, state), do: {:reply, state, state}

  @impl true
  def handle_info({:gun_up, conn_pid, protocol}, state) do
    {key, conn} = find_conn(state.conns, conn_pid, protocol)

    # Send to all waiting processes connection pid
    Enum.each(conn.waiting_pids, fn waiting_pid -> GenServer.reply(waiting_pid, conn_pid) end)

    # Update state of the current connection and set waiting_pids to empty list
    state = put_in(state.conns[key], %{conn | state: :up, waiting_pids: []})
    {:noreply, state}
  end

  @impl true
  # Do we need to do something with killed & unprocessed references?
  def handle_info({:gun_down, conn_pid, protocol, _reason, _killed, _unprocessed}, state) do
    {key, conn} = find_conn(state.conns, conn_pid, protocol)

    # We don't want to block requests to GenServer if gun send down message, return nil, so we can make some retries, while connection is not up
    Enum.each(conn.waiting_pids, fn waiting_pid -> GenServer.reply(waiting_pid, nil) end)

    state = put_in(state.conns[key].state, :down)
    {:noreply, state}
  end

  defp compose_key(uri), do: uri.host <> ":" <> to_string(uri.port)

  defp find_conn(conns, conn_pid, protocol),
    do: Enum.find(conns, fn {_, conn} -> conn.conn == conn_pid and conn.protocol == protocol end)
end
