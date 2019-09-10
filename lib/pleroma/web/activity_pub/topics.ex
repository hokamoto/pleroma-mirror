# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.ActivityPub.Topics do

  alias Pleroma.Object
  alias Pleroma.Web.ActivityPub.Visibility

  def get_activity_topics(activity) do
    activity
    |> Object.normalize
    |> generate_topics(activity)
    |> List.flatten
  end

  defp generate_topics(%{data: %{type: "Answer"}}, _) do
    []
  end

  defp generate_topics(object, activity) do
    ["user", "list"] ++ visibility_tags(object, activity)
  end

  defp visibility_tags(object, activity) do
    case Visibility.get_visibility(activity) do
      "public" ->
        if activity.local do
          ["public", "public:local"]
        else
          ["public"]
        end
        |> item_creation_tags(object, activity)

      "direct" ->
        ["direct"]

      _ ->
        []
    end
  end

  defp item_creation_tags(tags, %{data: %{type: "Create"}} = object, activity) do
    tags ++ hashtags_to_topics(object) ++ attachment_topics(object, activity)
  end

  defp item_creation_tags(tags, _, _) do
    tags
  end

  defp hashtags_to_topics(obj) do
    obj.data
    |> Map.get("tag", [])
    |> Enum.filter(fn tag -> is_bitstring(tag) end)
    |> Enum.map(fn tag -> "hashtag:" <> tag end)
  end

  defp attachment_topics(%{data: %{"attachment" => []}}, _activity) do
    []
  end

  defp attachment_topics(_object, activity) do
    if activity.local do
      ["public:media", "public:local:media"]
    else
      ["public:media"]
    end
  end

end
