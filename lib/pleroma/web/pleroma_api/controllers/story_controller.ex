# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.PleromaAPI.StoryController do
  use Pleroma.Web, :controller

  import Pleroma.Web.ControllerHelper, only: [add_link_headers: 2, try_render: 3]

  alias Pleroma.Plugs.OAuthScopesPlug
  alias Pleroma.Web.ActivityPub.ActivityPub
  alias Pleroma.Web.CommonAPI

  plug(
    OAuthScopesPlug,
    %{scopes: ["read:statuses"]} when action in [:conversation, :conversation_statuses]
  )

  plug(
    OAuthScopesPlug,
    %{scopes: ["write:conversations"]} when action == :update_conversation
  )

  plug(OAuthScopesPlug, %{scopes: ["write:notifications"]} when action == :read_notification)

  plug(Pleroma.Plugs.EnsurePublicOrAuthenticatedPlug)

  plug(:put_view, Pleroma.Web.MastodonAPI.StatusView)

  def create(%{assigns: %{user: user}} = conn, %{"status" => _} = params) do
    # Stories exprires in 24 hours
    expires_in = 24 * 60 * 60

    params =
      params
      |> Map.put("expires_in", expires_in)
      |> Map.put("type", "Story")

    with {:ok, activity} <- CommonAPI.post(user, params) do
      conn
      |> try_render("show.json",
        activity: activity,
        for: user,
        as: :activity,
        with_direct_conversation_id: true
      )
    else
      {:error, message} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: message})
    end
  end

  def list(%{assigns: %{user: user}} = conn, params) do
    params =
      params
      |> Map.put("type", ["Create", "Announce"])
      |> Map.put("blocking_user", user)
      |> Map.put("muting_user", user)
      |> Map.put("user", user)

    recipients = [user.ap_id | Pleroma.User.following(user)]

    activities =
      recipients
      |> ActivityPub.fetch_stories(params)
      |> Enum.reverse()

    conn
    |> add_link_headers(activities)
    |> render("index.json", activities: activities, for: user, as: :activity)
  end
end
