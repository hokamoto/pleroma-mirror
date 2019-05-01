# Pleroma: A lightweight social networking server
# Copyright © 2017-2018 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.ActivityTest do
  use Pleroma.DataCase
  alias Pleroma.Activity
  alias Pleroma.Web.CommonAPI
  import Pleroma.Factory

  test "returns an activity by it's AP id" do
    activity = insert(:note_activity)
    found_activity = Activity.get_by_ap_id(activity.data["id"])

    assert activity == found_activity
  end

  test "returns activities by it's objects AP ids" do
    activity = insert(:note_activity)
    [found_activity] = Activity.get_all_create_by_object_ap_id(activity.data["object"]["id"])

    assert activity == found_activity
  end

  test "returns the activity that created an object" do
    activity = insert(:note_activity)

    found_activity = Activity.get_create_by_object_ap_id(activity.data["object"]["id"])

    assert activity == found_activity
  end

  test "activity load with cursor" do
    user = insert(:user)
    {:ok, activity1} = CommonAPI.post(user, %{"status" => "first activity"})
    {:ok, activity2} = CommonAPI.post(user, %{"status" => "second activity"})
    {:ok, activity3} = CommonAPI.post(user, %{"status" => "thtird activity"})
    {:ok, activity4} = CommonAPI.post(user, %{"status" => "fourth activity"})

    activities =
      Activity.query_by_actor_with_limit(user.ap_id, 2, nil)
      |> Activity.load_query_with_preloaded_object()

    assert [activity1, activity2] == activities

    last = List.last(activities)

    next_activities =
      Activity.query_by_actor_with_limit(user.ap_id, 2, last.id)
      |> Activity.load_query_with_preloaded_object()

    assert [activity3, activity4] == next_activities
  end
end
