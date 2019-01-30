# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.MfcFollowerSync do
  import Ecto.Query
  alias Pleroma.{User, Repo}

  def start_link do
    agent = Agent.start_link(fn -> {[], %{}} end, name: __MODULE__)
    spawn(fn -> schedule_update() end)
    agent
  end

  def schedule_update do
    spawn(fn ->
      # 6 hours
      Process.sleep(1000 * 60 * 60 * 6)
      schedule_update()
    end)

    sync_follows()
  end

  def sync_follows do
    from(
      u in User,
      where: u.local == true
    )
    |> Repo.all()
    |> Enum.each(fn user -> Pleroma.Web.Mfc.Utils.sync_follows(user) end)
  end
end
