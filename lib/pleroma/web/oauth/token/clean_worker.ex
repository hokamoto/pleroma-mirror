# Pleroma: A lightweight social networking server
# Copyright © 2017-2018 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.OAuth.Token.CleanWorker do
  @moduledoc """
  The genserver  to clean an expired oauth tokens.
  """

  use GenServer

  # 10 seconds
  @start_interval 10_000
  @interval Pleroma.Config.get(
              # 24 hours
              [:oauth2, :clean_expired_tokens_interval],
              86_400_000
            )

  alias Pleroma.Web.OAuth.Token

  def start_link do
    if Pleroma.Config.get([:oauth2, :clean_expired_tokens], false) do
      GenServer.start_link(__MODULE__, [])
    else
      :ignore
    end
  end

  def init([]) do
    Process.send_after(self(), :perform, @start_interval)
    {:ok, []}
  end

  def handle_info(:perform, state) do
    Token.delete_expired_tokens()
    Process.send_after(self(), :perform, @interval)
    {:noreply, state}
  end
end
