# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.ActivityPub.ObjectViewTest do
  use Pleroma.DataCase
  import Pleroma.Factory

  alias Pleroma.Object
  alias Pleroma.Web.ActivityPub.ObjectView
  alias Pleroma.Web.CommonAPI

  describe "likes.json" do
    test "render OrderedCollection for likes" do
      note = insert(:note_activity)
      [like | _] = likes = insert_list(10, :like_activity, note_activity: note)
      result = ObjectView.render("likes.json", %{ap_id: "test_ap_id", likes: likes, total: 11})

      assert result["@context"] == [
               "https://www.w3.org/ns/activitystreams",
               "http://localhost:4001/schemas/litepub-0.1.jsonld",
               %{"@language" => "und"}
             ]

      assert result["id"] == "test_ap_id/likes"
      assert result["totalItems"] == 11
      assert result["type"] == "OrderedCollection"
      assert result["first"]["id"] == "test_ap_id/likes?page=1"
      assert result["first"]["next"] == "test_ap_id/likes?page=2"
      assert result["first"]["partOf"] == "test_ap_id/likes"
      assert result["first"]["totalItems"] == 11
      assert result["first"]["type"] == "OrderedCollectionPage"
      assert length(result["first"]["orderedItems"]) == 10
      [item | _] = result["first"]["orderedItems"]

      assert item == %{
               "actor" => like.data["actor"],
               "attachment" => [],
               "attributedTo" => like.data["actor"],
               "conversation" => nil,
               "id" => like.data["id"],
               "object" => like.data["object"],
               "published_at" => like.data["published_at"],
               "sensitive" => false,
               "tag" => [],
               "type" => "Like"
             }
    end
  end

  test "renders a note object" do
    note = insert(:note)

    result = ObjectView.render("object.json", %{object: note})
    assert result["id"] == note.data["id"]
    assert result["to"] == note.data["to"]
    assert result["content"] == note.data["content"]
    assert result["type"] == "Note"
    assert result["@context"]
  end

  test "renders a note activity" do
    note = insert(:note_activity)
    object = Object.normalize(note)

    result = ObjectView.render("object.json", %{object: note})

    assert result["id"] == note.data["id"]
    assert result["to"] == note.data["to"]
    assert result["object"]["type"] == "Note"
    assert result["object"]["content"] == object.data["content"]
    assert result["type"] == "Create"
    assert result["@context"]
  end

  test "renders a like activity" do
    note = insert(:note_activity)
    object = Object.normalize(note)
    user = insert(:user)

    {:ok, like_activity, _} = CommonAPI.favorite(note.id, user)

    result = ObjectView.render("object.json", %{object: like_activity})

    assert result["id"] == like_activity.data["id"]
    assert result["object"] == object.data["id"]
    assert result["type"] == "Like"
  end

  test "renders an announce activity" do
    note = insert(:note_activity)
    object = Object.normalize(note)
    user = insert(:user)

    {:ok, announce_activity, _} = CommonAPI.repeat(note.id, user)

    result = ObjectView.render("object.json", %{object: announce_activity})

    assert result["id"] == announce_activity.data["id"]
    assert result["object"] == object.data["id"]
    assert result["type"] == "Announce"
  end
end
