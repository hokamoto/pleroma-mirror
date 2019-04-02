# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.MfcOnlineStateSync do
  def start_link do
    agent = Agent.start_link(fn -> {[], %{}} end, name: __MODULE__)
    spawn(fn -> schedule_update() end)
    agent
  end

  def schedule_update do
    spawn(fn ->
      # 5 Minutes
      Process.sleep(1000 * 60 * 5)
      schedule_update()
    end)

    Pleroma.Web.Mfc.Utils.update_online_status()
  end
end
