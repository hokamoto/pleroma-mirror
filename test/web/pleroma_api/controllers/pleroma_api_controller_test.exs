# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.PleromaAPI.PleromaAPIControllerTest do
  use Pleroma.Web.ConnCase

  alias Pleroma.Activity
  alias Pleroma.ActivityExpiration
  alias Pleroma.Conversation.Participation
  alias Pleroma.Notification
  alias Pleroma.Object
  alias Pleroma.Repo
  alias Pleroma.User
  alias Pleroma.Web.CommonAPI

  import Pleroma.Factory

  test "/api/v1/pleroma/conversations/:id", %{conn: conn} do
    user = insert(:user)
    other_user = insert(:user)

    {:ok, _activity} =
      CommonAPI.post(user, %{"status" => "Hi @#{other_user.nickname}!", "visibility" => "direct"})

    [participation] = Participation.for_user(other_user)

    result =
      conn
      |> assign(:user, other_user)
      |> get("/api/v1/pleroma/conversations/#{participation.id}")
      |> json_response(200)

    assert result["id"] == participation.id |> to_string()
  end

  test "/api/v1/pleroma/conversations/:id/statuses", %{conn: conn} do
    user = insert(:user)
    other_user = insert(:user)
    third_user = insert(:user)

    {:ok, _activity} =
      CommonAPI.post(user, %{"status" => "Hi @#{third_user.nickname}!", "visibility" => "direct"})

    {:ok, activity} =
      CommonAPI.post(user, %{"status" => "Hi @#{other_user.nickname}!", "visibility" => "direct"})

    [participation] = Participation.for_user(other_user)

    {:ok, activity_two} =
      CommonAPI.post(other_user, %{
        "status" => "Hi!",
        "in_reply_to_status_id" => activity.id,
        "in_reply_to_conversation_id" => participation.id
      })

    result =
      conn
      |> assign(:user, other_user)
      |> get("/api/v1/pleroma/conversations/#{participation.id}/statuses")
      |> json_response(200)

    assert length(result) == 2

    id_one = activity.id
    id_two = activity_two.id
    assert [%{"id" => ^id_one}, %{"id" => ^id_two}] = result
  end

  test "PATCH /api/v1/pleroma/conversations/:id", %{conn: conn} do
    user = insert(:user)
    other_user = insert(:user)

    {:ok, _activity} = CommonAPI.post(user, %{"status" => "Hi", "visibility" => "direct"})

    [participation] = Participation.for_user(user)

    participation = Repo.preload(participation, :recipients)

    user = User.get_cached_by_id(user.id)
    assert [user] == participation.recipients
    assert other_user not in participation.recipients

    result =
      conn
      |> assign(:user, user)
      |> patch("/api/v1/pleroma/conversations/#{participation.id}", %{
        "recipients" => [user.id, other_user.id]
      })
      |> json_response(200)

    assert result["id"] == participation.id |> to_string

    [participation] = Participation.for_user(user)
    participation = Repo.preload(participation, :recipients)

    assert user in participation.recipients
    assert other_user in participation.recipients
  end

  test "POST /api/v1/pleroma/conversations/read", %{conn: conn} do
    user = insert(:user)
    other_user = insert(:user)

    {:ok, _activity} =
      CommonAPI.post(user, %{"status" => "Hi @#{other_user.nickname}", "visibility" => "direct"})

    {:ok, _activity} =
      CommonAPI.post(user, %{"status" => "Hi @#{other_user.nickname}", "visibility" => "direct"})

    [participation2, participation1] = Participation.for_user(other_user)
    assert Participation.get(participation2.id).read == false
    assert Participation.get(participation1.id).read == false
    assert User.get_cached_by_id(other_user.id).info.unread_conversation_count == 2

    [%{"unread" => false}, %{"unread" => false}] =
      conn
      |> assign(:user, other_user)
      |> post("/api/v1/pleroma/conversations/read", %{})
      |> json_response(200)

    [participation2, participation1] = Participation.for_user(other_user)
    assert Participation.get(participation2.id).read == true
    assert Participation.get(participation1.id).read == true
    assert User.get_cached_by_id(other_user.id).info.unread_conversation_count == 0
  end

  describe "POST /api/v1/pleroma/notifications/read" do
    test "it marks a single notification as read", %{conn: conn} do
      user1 = insert(:user)
      user2 = insert(:user)
      {:ok, activity1} = CommonAPI.post(user2, %{"status" => "hi @#{user1.nickname}"})
      {:ok, activity2} = CommonAPI.post(user2, %{"status" => "hi @#{user1.nickname}"})
      {:ok, [notification1]} = Notification.create_notifications(activity1)
      {:ok, [notification2]} = Notification.create_notifications(activity2)

      response =
        conn
        |> assign(:user, user1)
        |> post("/api/v1/pleroma/notifications/read", %{"id" => "#{notification1.id}"})
        |> json_response(:ok)

      assert %{"pleroma" => %{"is_seen" => true}} = response
      assert Repo.get(Notification, notification1.id).seen
      refute Repo.get(Notification, notification2.id).seen
    end

    test "it marks multiple notifications as read", %{conn: conn} do
      user1 = insert(:user)
      user2 = insert(:user)
      {:ok, _activity1} = CommonAPI.post(user2, %{"status" => "hi @#{user1.nickname}"})
      {:ok, _activity2} = CommonAPI.post(user2, %{"status" => "hi @#{user1.nickname}"})
      {:ok, _activity3} = CommonAPI.post(user2, %{"status" => "HIE @#{user1.nickname}"})

      [notification3, notification2, notification1] = Notification.for_user(user1, %{limit: 3})

      [response1, response2] =
        conn
        |> assign(:user, user1)
        |> post("/api/v1/pleroma/notifications/read", %{"max_id" => "#{notification2.id}"})
        |> json_response(:ok)

      assert %{"pleroma" => %{"is_seen" => true}} = response1
      assert %{"pleroma" => %{"is_seen" => true}} = response2
      assert Repo.get(Notification, notification1.id).seen
      assert Repo.get(Notification, notification2.id).seen
      refute Repo.get(Notification, notification3.id).seen
    end

    test "it returns error when notification not found", %{conn: conn} do
      user1 = insert(:user)

      response =
        conn
        |> assign(:user, user1)
        |> post("/api/v1/pleroma/notifications/read", %{"id" => "22222222222222"})
        |> json_response(:bad_request)

      assert response == %{"error" => "Cannot get notification"}
    end
  end

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
        |> post(pleroma_api_path(conn, :create_story), %{
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

    test "reading a user story", %{conn1: conn1, conn2: conn2} do
      # Create a story by user1
      post(conn1, pleroma_api_path(conn1, :create_story), %{"status" => @content})
      # Create a regular status by user1
      post(conn1, status_path(conn1, :create), %{"status" => "cofe"})

      conn2 = get(conn2, pleroma_api_path(conn2, :list_user_stories, conn1.assigns.user.id))

      assert response = json_response(conn2, 200)

      assert length(response) == 1

      [story] = response

      assert story["content"] == @content
    end

    test "List stories", %{conn1: conn1, conn2: conn2, conn3: conn3} do
      user2_status = "You take the red pill"
      user3_status = "You take the blue pill"
      # Create a story by user2
      post(conn2, pleroma_api_path(conn2, :create_story), %{"status" => user2_status})
      # Create a story by user3
      post(conn3, pleroma_api_path(conn3, :create_story), %{"status" => user3_status})

      {:ok, user1} = User.follow(conn1.assigns.user, conn2.assigns.user)

      conn1 =
        conn1
        |> assign(:user, user1)
        |> get(pleroma_api_path(conn1, :list_stories))

      assert response = json_response(conn1, 200)

      assert length(response) == 1

      [story] = response

      assert story["content"] == user2_status
    end
  end
end
