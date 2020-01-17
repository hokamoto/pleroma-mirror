# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Plugs.ModerationLogPlugTest do
  use Pleroma.Web.ConnCase, async: true

  import Pleroma.Factory

  alias Pleroma.Plugs.ModerationLogPlug
  alias Plug.Conn

  test "added moderation log to db", %{conn: _conn} do
    user = insert(:user)
    followed = insert(:user)
    follower = insert(:user)

    conn =
      build_conn(:get, "/")
      |> assign(:user, user)
      |> Conn.put_private(:moderation_log, %{
        followed: followed,
        follower: follower,
        action: "follow"
      })
      |> ModerationLogPlug.call([])

    send_resp(conn, 204, "")

    assert [log] = Pleroma.Repo.all(Pleroma.ModerationLog)

    assert log.data == %{
             "action" => "follow",
             "actor" => %{
               "id" => user.id,
               "nickname" => user.nickname,
               "type" => "user"
             },
             "followed" => %{
               "id" => followed.id,
               "nickname" => followed.nickname,
               "type" => "user"
             },
             "follower" => %{
               "id" => follower.id,
               "nickname" => follower.nickname,
               "type" => "user"
             },
             "message" =>
               "@#{user.nickname} made @#{follower.nickname} follow @#{followed.nickname}"
           }
  end
end
