# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.PleromaAPI.StoryControllerTest do
  use Pleroma.Web.ConnCase

  alias Pleroma.Activity
  alias Pleroma.ActivityExpiration
  alias Pleroma.Object
  alias Pleroma.User

  import Pleroma.Factory

  describe "Stories" do
    setup do
      user1 = insert(:user)
      user2 = insert(:user)
      user3 = insert(:user)

      conn1 =
        build_conn()
        |> assign(:user, user1)

      conn2 =
        build_conn()
        |> assign(:user, user2)

      conn3 =
        build_conn()
        |> assign(:user, user3)

      [conn1: conn1, conn2: conn2, conn3: conn3]
    end

    @content "HELO stories"

    test "creating a story", %{conn1: conn} do
      conn =
        conn
        |> post(story_path(conn, :create), %{
          "status" => @content
        })

      assert %{"content" => @content, "id" => activity_id} = json_response(conn, 200)

      assert activity = Activity.get_by_id(activity_id)
      assert Object.normalize(activity).data["type"] == "Story"

      # Story expires in 24 hours
      expires_in = 24 * 60 * 60

      assert expiration = ActivityExpiration.get_by_activity_id(activity_id)

      estimated_expires_at =
        NaiveDateTime.utc_now()
        |> NaiveDateTime.add(expires_in)
        |> NaiveDateTime.truncate(:second)

      # This assert will fail if the test takes longer than a minute. I sure hope it never does:
      assert abs(NaiveDateTime.diff(expiration.scheduled_at, estimated_expires_at, :second)) < 60
    end

    test "List stories", %{conn1: conn1, conn2: conn2, conn3: conn3} do
      user2_status = "You take the red pill"
      user3_status = "You take the blue pill"
      # Create a story by user2
      post(conn2, story_path(conn2, :create), %{"status" => user2_status})
      # Create a story by user3
      post(conn3, story_path(conn3, :create), %{"status" => user3_status})

      {:ok, user1} = User.follow(conn1.assigns.user, conn2.assigns.user)

      conn1 =
        conn1
        |> assign(:user, user1)
        |> get(story_path(conn1, :list))

      assert response = json_response(conn1, 200)

      assert length(response) == 1

      [story] = response

      assert story["content"] == user2_status
    end
  end
end
