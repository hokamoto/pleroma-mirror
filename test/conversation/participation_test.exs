# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Conversation.ParticipationTest do
  use Pleroma.DataCase
  import Pleroma.Factory
  alias Pleroma.Conversation.Participation
  alias Pleroma.Web.CommonAPI

  test "it creates a participation for a conversation and a user" do
    user = insert(:user)
    conversation = insert(:conversation)

    {:ok, %Participation{} = participation} =
      Participation.create_for_user_and_conversation(user, conversation)

    assert participation.user_id == user.id
    assert participation.conversation_id == conversation.id

    :timer.sleep(1000)
    # Creating again returns the same participation
    {:ok, %Participation{} = participation_two} =
      Participation.create_for_user_and_conversation(user, conversation)

    assert participation.id == participation_two.id
    refute participation.updated_at == participation_two.updated_at
  end

  test "recreating an existing participations sets it to unread" do
    participation = insert(:participation, %{read: true})

    {:ok, participation} =
      Participation.create_for_user_and_conversation(
        participation.user,
        participation.conversation
      )

    refute participation.read
  end

  test "it marks a participation as read" do
    participation = insert(:participation, %{read: false})
    {:ok, participation} = Participation.mark_as_read(participation)

    assert participation.read
  end

  test "it marks a participation as unread" do
    participation = insert(:participation, %{read: true})
    {:ok, participation} = Participation.mark_as_unread(participation)

    refute participation.read
  end

  test "gets all the participations for a user, ordered by updated at descending" do
    [user, user_two] = insert_pair(:user)

    {:ok, activity_one} = CommonAPI.post(user, %{"status" => "x1", "visibility" => "direct"})
    :timer.sleep(1000)
    {:ok, activity_two} = CommonAPI.post(user, %{"status" => "x2", "visibility" => "direct"})
    :timer.sleep(1000)

    {:ok, activity_three} =
      CommonAPI.post(user_two, %{
        "status" => "x3",
        "visibility" => "direct",
        "in_reply_to_status_id" => activity_one.id
      })

    {:ok, activity_four} =
      CommonAPI.post(user_two, %{
        "status" => "x4",
        "visibility" => "direct",
        "in_reply_to_status_id" => activity_two.id
      })

    user = Repo.get(Pleroma.User, user.id)

    assert participation_one.conversation.ap_id == object3.data["context"]
    assert participation_two.conversation.ap_id == object2.data["context"]
    assert participation_one.conversation.users == [user]

    # Pagination
    [participation_one] = Participation.for_user(user, %{"limit" => 1})
    assert participation_one.conversation.ap_id == activity_two.data["context"]

    # All participations with last activities
    [participation_one, participation_two] = Participation.for_user_with_last_activities(user)
    assert participation_one.last_activity.id == activity_four.id
    assert participation_two.last_activity.id == activity_three.id

    # Find the last activity for the participation
    participation_one = Participation.for_user_with_last_activity(participation_one, user)
    assert participation_one.last_activity.id == activity_four.id
  end

  test "Doesn't die when the conversation gets empty" do
    user = insert(:user)

    {:ok, activity} = CommonAPI.post(user, %{"status" => ".", "visibility" => "direct"})
    [participation] = Participation.for_user_with_last_activity_id(user)

    assert participation.last_activity_id == activity.id

    {:ok, _} = CommonAPI.delete(activity.id, user)

    [] = Participation.for_user_with_last_activity_id(user)
  end
end
