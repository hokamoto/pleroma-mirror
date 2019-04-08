# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.MfcFollowerSync do
  import Ecto.Query
  alias Pleroma.Repo
  alias Pleroma.User

  # 6 hours
  @sleep_time 60 * 60 * 6

  def start_link do
    agent = Agent.start_link(fn -> {[], %{}} end, name: __MODULE__)
    spawn(fn -> schedule_update() end)
    agent
  end

  def schedule_update do
    spawn(fn ->
      Process.sleep(@sleep_time * 1000)
      schedule_update()
    end)

    sync_follows()
  end

  def sync_follows do
    time =
      DateTime.utc_now()
      |> DateTime.to_unix()
      |> (&(&1 - @sleep_time)).()
      |> to_string()

    from(
      u in User,
      where: u.local == true
    )
    |> Repo.all()
    |> Enum.each(fn user -> Pleroma.Web.Mfc.Utils.sync_follows(user, %{since: time}) end)
  end
end
