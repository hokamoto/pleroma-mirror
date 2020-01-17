# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Plugs.ModerationLogPlug do
  alias Pleroma.ModerationLog
  alias Plug.Conn

  @doc false
  def init(opts \\ []), do: opts

  @doc false
  def call(%Conn{} = conn, _ \\ []) do
    Conn.register_before_send(conn, &__MODULE__.moderation_log/1)
  end

  def moderation_log(
        %Conn{assigns: %{user: user} = _, private: %{moderation_log: log_entry} = _} = conn
      )
      when is_map(log_entry) do
    log_entry
    |> Map.put_new(:actor, user)
    |> Map.put_new(:action, to_string(conn.private[:phoenix_action]))
    |> insert_log()

    conn
  end

  def moderation_log(conn), do: conn

  defp insert_log(entry) do
    Pleroma.Async.start(fn -> ModerationLog.insert_log(entry) end)
  end
end
