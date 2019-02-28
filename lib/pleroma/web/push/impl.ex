# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.Push.Impl do
  alias Pleroma.Repo
  alias Pleroma.User
  alias Pleroma.Web.Push.Subscription
  alias Pleroma.Activity

  require Logger
  import Ecto.Query

  @types ["Create", "Follow", "Announce", "Like"]

  def perform_send(%{activity: %{data: %{"type" => type}}, user_id: user_id} = notification)
      when type in @types do
    actor = User.get_cached_by_ap_id(notification.activity.data["actor"])

    type = Activity.mastodon_notification_type(notification.activity)
    gcm_api_key = Application.get_env(:web_push_encryption, :gcm_api_key)
    avatar_url = User.avatar_url(actor)

    for subscription <- fetch_subsriptions(user_id),
        get_in(subscription.data, ["alerts", type]) do
      sub = build_sub(subscription)

      body =
        Jason.encode!(%{
          title: format_title(notification),
          access_token: subscription.token.token,
          body: format_body(notification, actor),
          notification_id: notification.id,
          notification_type: type,
          icon: avatar_url,
          preferred_locale: "en"
        })

      case WebPushEncryption.send_web_push(body, sub, gcm_api_key) do
        {:ok, %{status_code: code}} when 400 <= code and code < 500 ->
          Logger.debug("Removing subscription record")
          Repo.delete!(subscription)
          :ok

        {:ok, %{status_code: code}} when 200 <= code and code < 300 ->
          :ok

        {:ok, %{status_code: code}} ->
          Logger.error("Web Push Notification failed with code: #{code}")
          :error

        _ ->
          Logger.error("Web Push Notification failed with unknown error")
          :error
      end
    end
  end

  def perform_send(_) do
    Logger.warn("Unknown notification type")
    :error
  end

  def fetch_subsriptions(user_id) do
    Subscription
    |> where(user_id: ^user_id)
    |> preload(:token)
    |> Repo.all()
  end

  defp build_sub(subscription) do
    %{
      keys: %{
        p256dh: subscription.key_p256dh,
        auth: subscription.key_auth
      },
      endpoint: subscription.endpoint
    }
  end

  defp format_title(%{activity: %{data: %{"type" => type}}}) do
    case type do
      "Create" -> "New Mention"
      "Follow" -> "New Follower"
      "Announce" -> "New Repeat"
      "Like" -> "New Favorite"
    end
  end

  defp format_body(%{activity: %{data: %{"type" => type}}}, actor) do
    case type do
      "Create" -> "@#{actor.nickname} has mentioned you"
      "Follow" -> "@#{actor.nickname} has followed you"
      "Announce" -> "@#{actor.nickname} has repeated your post"
      "Like" -> "@#{actor.nickname} has favorited your post"
    end
  end
end
