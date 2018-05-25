defmodule Pleroma.Web.ActivityPub.MRF.SimplePolicy do
  alias Pleroma.User
  @behaviour Pleroma.Web.ActivityPub.MRF

  defp check_reject(actor_info, object, config) do
    if Enum.member?(Keyword.get(config, :reject), actor_info.host) do
      {:reject, nil}
    else
      {:ok, object}
    end
  end

  defp check_media_removal(actor_info, object, config) do
    if Enum.member?(Keyword.get(config, :media_removal), actor_info.host) do
      child_object = Map.delete(object["object"], "attachment")
      object = Map.put(object, "object", child_object)
      {:ok, object}
    else
      {:ok, object}
    end
  end

  defp check_media_nsfw(actor_info, object, config) do
    child_object = object["object"]

    if Enum.member?(Keyword.get(config, :media_nsfw), actor_info.host)
      and child_object["attachment"] != nil and length(child_object["attachment"]) > 0 do
      tags = (child_object["tag"] || []) ++ ["nsfw"]
      child_object = Map.put(child_object, "tags", tags)
      child_object = Map.put(child_object, "sensitive", true)
      object = Map.put(object, "object", child_object)
      {:ok, object}
    else
      {:ok, object}
    end
  end

  defp check_ftl_removal(actor_info, object, config) do
    if Enum.member?(Keyword.get(config, :federated_timeline_removal), actor_info.host) do
      user = User.get_by_ap_id(object["actor"])

      # flip to/cc relationship to make the post unlisted
      object =
        if "https://www.w3.org/ns/activitystreams#Public" in object["to"] and
             user.follower_address in object["cc"] do
          to =
            List.delete(object["to"], "https://www.w3.org/ns/activitystreams#Public") ++
              [user.follower_address]

          cc =
            List.delete(object["cc"], user.follower_address) ++
              ["https://www.w3.org/ns/activitystreams#Public"]

          object
          |> Map.put("to", to)
          |> Map.put("cc", cc)
        else
          object
        end

      {:ok, object}
    else
      {:ok, object}
    end
  end

  @impl true
  def filter(object) do
    actor_info = URI.parse(object["actor"])
    config = Application.get_env(:pleroma, :mrf_simple)

    with {:ok, object} <- check_reject(actor_info, object, config),
         {:ok, object} <- check_media_removal(actor_info, object, config),
         {:ok, object} <- check_media_nsfw(actor_info, object, config),
         {:ok, object} <- check_ftl_removal(actor_info, object, config) do
      {:ok, object}
    else
      _e -> {:reject, nil}
    end
  end
end
