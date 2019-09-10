# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule PleromaWeb.Streamer do
  use GenServer

  alias PleromaWeb.Streamer.State
  alias PleromaWeb.Streamer.Worker

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def add_socket(topic, socket) do
    State.add_socket(topic, socket)
  end

  def remove_socket(topic, socket) do
    State.remove_socket(topic, socket)
  end

  def get_sockets do
    State.get_sockets()
  end

  def direct_push(topics, topic, activity) do
    Worker.push_to_socket(topics, topic, activity)
  end

  def stream(topics, items) do
    GenServer.cast(Worker, %{action: :stream, topic: topics, item: items})
  end

  def supervisor, do: PleromaWeb.Streamer.Supervisor

  def init(args) do
    {:ok, args}
  end
end
