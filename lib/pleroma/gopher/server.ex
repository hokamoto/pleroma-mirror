# Pleroma: A lightweight social networking server
# Copyright © 2017-2020 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Gopher.Server do
  use GenServer
  require Logger

  def start_link(_) do
    config = Pleroma.Config.get(:gopher, [])
    ip = Keyword.get(config, :ip, {0, 0, 0, 0})
    port = Keyword.get(config, :port, 1234)

    if Keyword.get(config, :enabled, false) do
      GenServer.start_link(__MODULE__, [ip, port], [])
    else
      Logger.info("Gopher server disabled")
      :ignore
    end
  end

  def init([ip, port]) do
    Logger.info("Starting gopher server on #{port}")

    :ranch.start_listener(
      :gopher,
      100,
      :ranch_tcp,
      [ip: ip, port: port],
      __MODULE__.ProtocolHandler,
      []
    )

    {:ok, %{ip: ip, port: port}}
  end
end
