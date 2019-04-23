# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.MastodonAPI.MastodonAPIController do
  use Pleroma.Web, :controller
  alias Ecto.Changeset
  alias Pleroma.Activity
  alias Pleroma.Config
  alias Pleroma.Filter
  alias Pleroma.Notification
  alias Pleroma.Object
  alias Pleroma.Object.Fetcher
  alias Pleroma.Pagination
  alias Pleroma.Question
  alias Pleroma.Repo
  alias Pleroma.ScheduledActivity
  alias Pleroma.Stats
  alias Pleroma.User
  alias Pleroma.Web
  alias Pleroma.Web.ActivityPub.ActivityPub
  alias Pleroma.Web.ActivityPub.Visibility
  alias Pleroma.Web.CommonAPI
  alias Pleroma.Web.MastodonAPI.AccountView
  alias Pleroma.Web.MastodonAPI.AppView
  alias Pleroma.Web.MastodonAPI.FilterView
  alias Pleroma.Web.MastodonAPI.ListView
  alias Pleroma.Web.MastodonAPI.MastodonAPI
  alias Pleroma.Web.MastodonAPI.MastodonView
  alias Pleroma.Web.MastodonAPI.NotificationView
  alias Pleroma.Web.MastodonAPI.QuestionView
  alias Pleroma.Web.MastodonAPI.ReportView
  alias Pleroma.Web.MastodonAPI.ScheduledActivityView
  alias Pleroma.Web.MastodonAPI.StatusView
  alias Pleroma.Web.MediaProxy
  alias Pleroma.Web.OAuth.App
  alias Pleroma.Web.OAuth.Authorization
  alias Pleroma.Web.OAuth.Token

  import Pleroma.Web.ControllerHelper, only: [oauth_scopes: 2]
  import Ecto.Query

  require Logger

  @httpoison Application.get_env(:pleroma, :httpoison)
  @local_mastodon_name "Mastodon-Local"

  action_fallback(:errors)

  def create_app(conn, params) do
    scopes = oauth_scopes(params, ["read"])

    app_attrs =
      params
      |> Map.drop(["scope", "scopes"])
      |> Map.put("scopes", scopes)

    with cs <- App.register_changeset(%App{}, app_attrs),
         false <- cs.changes[:client_name] == @local_mastodon_name,
         {:ok, app} <- Repo.insert(cs) do
      conn
      |> put_view(AppView)
      |> render("show.json", %{app: app})
    end
  end

  defp add_if_present(
         map,
         params,
         params_field,
         map_field,
         value_function \\ fn x -> {:ok, x} end
       ) do
    if Map.has_key?(params, params_field) do
      case value_function.(params[params_field]) do
        {:ok, new_value} -> Map.put(map, map_field, new_value)
        :error -> map
      end
    else
      map
    end
  end

  def update_credentials(%{assigns: %{user: user}} = conn, params) do
    original_user = user

    user_params =
      %{}
      |> add_if_present(params, "display_name", :name)
      |> add_if_present(params, "note", :bio, fn value -> {:ok, User.parse_bio(value)} end)
      |> add_if_present(params, "avatar", :avatar, fn value ->
        with %Plug.Upload{} <- value,
             {:ok, object} <- ActivityPub.upload(value, type: :avatar) do
          {:ok, object.data}
        else
          _ -> :error
        end
      end)

    info_params =
      %{}
      |> add_if_present(params, "locked", :locked, fn value -> {:ok, value == "true"} end)
      |> add_if_present(params, "header", :banner, fn value ->
        with %Plug.Upload{} <- value,
             {:ok, object} <- ActivityPub.upload(value, type: :banner) do
          {:ok, object.data}
        else
          _ -> :error
        end
      end)

    info_cng = User.Info.mastodon_profile_update(user.info, info_params)

    with changeset <- User.update_changeset(user, user_params),
         changeset <- Ecto.Changeset.put_embed(changeset, :info, info_cng),
         {:ok, user} <- User.update_and_set_cache(changeset) do
      if original_user != user do
        CommonAPI.update(user)
      end

      json(conn, AccountView.render("account.json", %{user: user, for: user}))
    else
      _e ->
        conn
        |> put_status(403)
        |> json(%{error: "Invalid request"})
    end
  end

  def verify_credentials(%{assigns: %{user: user}} = conn, _) do
    account = AccountView.render("account.json", %{user: user, for: user})
    json(conn, account)
  end

  def verify_app_credentials(%{assigns: %{user: _user, token: token}} = conn, _) do
    with %Token{app: %App{} = app} <- Repo.preload(token, :app) do
      conn
      |> put_view(AppView)
      |> render("short.json", %{app: app})
    end
  end

  def user(%{assigns: %{user: for_user}} = conn, %{"id" => nickname_or_id}) do
    with %User{} = user <- User.get_cached_by_nickname_or_id(nickname_or_id),
         true <- User.auth_active?(user) || user.id == for_user.id || User.superuser?(for_user) do
      account = AccountView.render("account.json", %{user: user, for: for_user})
      json(conn, account)
    else
      _e ->
        conn
        |> put_status(404)
        |> json(%{error: "Can't find user"})
    end
  end

  @mastodon_api_level "2.5.0"

  def masto_instance(conn, _params) do
    instance = Config.get(:instance)

    response = %{
      uri: Web.base_url(),
      title: Keyword.get(instance, :name),
      description: Keyword.get(instance, :description),
      version: "#{@mastodon_api_level} (compatible; #{Pleroma.Application.named_version()})",
      email: Keyword.get(instance, :email),
      urls: %{
        streaming_api: Pleroma.Web.Endpoint.websocket_url()
      },
      stats: Stats.get_stats(),
      thumbnail: Web.base_url() <> "/instance/thumbnail.jpeg",
      languages: ["en"],
      registrations: Pleroma.Config.get([:instance, :registrations_open]),
      # Extra (not present in Mastodon):
      max_toot_chars: Keyword.get(instance, :limit)
    }

    json(conn, response)
  end

  def peers(conn, _params) do
    json(conn, Stats.get_peers())
  end

  defp mastodonized_emoji do
    Pleroma.Emoji.get_all()
    |> Enum.map(fn {shortcode, relative_url, tags} ->
      url = to_string(URI.merge(Web.base_url(), relative_url))

      %{
        "shortcode" => shortcode,
        "static_url" => url,
        "visible_in_picker" => true,
        "url" => url,
        "tags" => String.split(tags, ",")
      }
    end)
  end

  def custom_emojis(conn, _params) do
    mastodon_emoji = mastodonized_emoji()
    json(conn, mastodon_emoji)
  end

  defp add_link_headers(conn, method, activities, param \\ nil, params \\ %{}) do
    params =
      conn.params
      |> Map.drop(["since_id", "max_id", "min_id"])
      |> Map.merge(params)

    last = List.last(activities)

    if last do
      max_id = last.id

      limit =
        params
        |> Map.get("limit", "20")
        |> String.to_integer()

      min_id =
        if length(activities) <= limit do
          activities
          |> List.first()
          |> Map.get(:id)
        else
          activities
          |> Enum.at(limit * -1)
          |> Map.get(:id)
        end

      {next_url, prev_url} =
        if param do
          {
            mastodon_api_url(
              Pleroma.Web.Endpoint,
              method,
              param,
              Map.merge(params, %{max_id: max_id})
            ),
            mastodon_api_url(
              Pleroma.Web.Endpoint,
              method,
              param,
              Map.merge(params, %{min_id: min_id})
            )
          }
        else
          {
            mastodon_api_url(
              Pleroma.Web.Endpoint,
              method,
              Map.merge(params, %{max_id: max_id})
            ),
            mastodon_api_url(
              Pleroma.Web.Endpoint,
              method,
              Map.merge(params, %{min_id: min_id})
            )
          }
        end

      conn
      |> put_resp_header("link", "<#{next_url}>; rel=\"next\", <#{prev_url}>; rel=\"prev\"")
    else
      conn
    end
  end

  def home_timeline(%{assigns: %{user: user}} = conn, params) do
    params =
      params
      |> Map.put("type", ["Create", "Announce"])
      |> Map.put("blocking_user", user)
      |> Map.put("muting_user", user)
      |> Map.put("user", user)

    activities =
      [user.ap_id | user.following]
      |> ActivityPub.fetch_activities(params)
      |> ActivityPub.contain_timeline(user)
      |> Enum.reverse()

    conn
    |> add_link_headers(:home_timeline, activities)
    |> put_view(StatusView)
    |> render("index.json", %{activities: activities, for: user, as: :activity})
  end

  def public_timeline(%{assigns: %{user: user}} = conn, params) do
    local_only = params["local"] in [true, "True", "true", "1"]

    activities =
      params
      |> Map.put("type", ["Create", "Announce"])
      |> Map.put("local_only", local_only)
      |> Map.put("blocking_user", user)
      |> Map.put("muting_user", user)
      |> ActivityPub.fetch_public_activities()
      |> Enum.reverse()

    conn
    |> add_link_headers(:public_timeline, activities, false, %{"local" => local_only})
    |> put_view(StatusView)
    |> render("index.json", %{activities: activities, for: user, as: :activity})
  end

  def user_statuses(%{assigns: %{user: reading_user}} = conn, params) do
    with %User{} = user <- User.get_by_id(params["id"]) do
      activities = ActivityPub.fetch_user_activities(user, reading_user, params)

      conn
      |> add_link_headers(:user_statuses, activities, params["id"])
      |> put_view(StatusView)
      |> render("index.json", %{
        activities: activities,
        for: reading_user,
        as: :activity
      })
    end
  end

  def dm_timeline(%{assigns: %{user: user}} = conn, params) do
    params =
      params
      |> Map.put("type", "Create")
      |> Map.put("blocking_user", user)
      |> Map.put("user", user)
      |> Map.put(:visibility, "direct")

    activities =
      [user.ap_id]
      |> ActivityPub.fetch_activities_query(params)
      |> Pagination.fetch_paginated(params)

    conn
    |> add_link_headers(:dm_timeline, activities)
    |> put_view(StatusView)
    |> render("index.json", %{activities: activities, for: user, as: :activity})
  end

  def get_status(%{assigns: %{user: user}} = conn, %{"id" => id}) do
    with %Activity{} = activity <- Activity.get_by_id_with_object(id),
         true <- Visibility.visible_for_user?(activity, user) do
      conn
      |> put_view(StatusView)
      |> try_render("status.json", %{activity: activity, for: user})
    end
  end

  def get_context(%{assigns: %{user: user}} = conn, %{"id" => id}) do
    with %Activity{} = activity <- Activity.get_by_id(id),
         activities <-
           ActivityPub.fetch_activities_for_context(activity.data["context"], %{
             "blocking_user" => user,
             "user" => user
           }),
         activities <-
           activities |> Enum.filter(fn %{id: aid} -> to_string(aid) != to_string(id) end),
         activities <-
           activities |> Enum.filter(fn %{data: %{"type" => type}} -> type == "Create" end),
         grouped_activities <- Enum.group_by(activities, fn %{id: id} -> id < activity.id end) do
      result = %{
        ancestors:
          StatusView.render(
            "index.json",
            for: user,
            activities: grouped_activities[true] || [],
            as: :activity
          )
          |> Enum.reverse(),
        # credo:disable-for-previous-line Credo.Check.Refactor.PipeChainStart
        descendants:
          StatusView.render(
            "index.json",
            for: user,
            activities: grouped_activities[false] || [],
            as: :activity
          )
          |> Enum.reverse()
        # credo:disable-for-previous-line Credo.Check.Refactor.PipeChainStart
      }

      json(conn, result)
    end
  end

  def scheduled_statuses(%{assigns: %{user: user}} = conn, params) do
    with scheduled_activities <- MastodonAPI.get_scheduled_activities(user, params) do
      conn
      |> add_link_headers(:scheduled_statuses, scheduled_activities)
      |> put_view(ScheduledActivityView)
      |> render("index.json", %{scheduled_activities: scheduled_activities})
    end
  end

  def show_scheduled_status(%{assigns: %{user: user}} = conn, %{"id" => scheduled_activity_id}) do
    with %ScheduledActivity{} = scheduled_activity <-
           ScheduledActivity.get(user, scheduled_activity_id) do
      conn
      |> put_view(ScheduledActivityView)
      |> render("show.json", %{scheduled_activity: scheduled_activity})
    else
      _ -> {:error, :not_found}
    end
  end

  def update_scheduled_status(
        %{assigns: %{user: user}} = conn,
        %{"id" => scheduled_activity_id} = params
      ) do
    with %ScheduledActivity{} = scheduled_activity <-
           ScheduledActivity.get(user, scheduled_activity_id),
         {:ok, scheduled_activity} <- ScheduledActivity.update(scheduled_activity, params) do
      conn
      |> put_view(ScheduledActivityView)
      |> render("show.json", %{scheduled_activity: scheduled_activity})
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end

  def delete_scheduled_status(%{assigns: %{user: user}} = conn, %{"id" => scheduled_activity_id}) do
    with %ScheduledActivity{} = scheduled_activity <-
           ScheduledActivity.get(user, scheduled_activity_id),
         {:ok, scheduled_activity} <- ScheduledActivity.delete(scheduled_activity) do
      conn
      |> put_view(ScheduledActivityView)
      |> render("show.json", %{scheduled_activity: scheduled_activity})
    else
      nil -> {:error, :not_found}
      error -> error
    end
  end

  def post_status(conn, %{"status" => "", "media_ids" => media_ids} = params)
      when length(media_ids) > 0 do
    params =
      params
      |> Map.put("status", ".")

    post_status(conn, params)
  end

  def post_status(%{assigns: %{user: user}} = conn, %{"status" => _} = params) do
    params =
      params
      |> Map.put("in_reply_to_status_id", params["in_reply_to_id"])

    scheduled_at = params["scheduled_at"]

    if scheduled_at && ScheduledActivity.far_enough?(scheduled_at) do
      with {:ok, scheduled_activity} <-
             ScheduledActivity.create(user, %{"params" => params, "scheduled_at" => scheduled_at}) do
        conn
        |> put_view(ScheduledActivityView)
        |> render("show.json", %{scheduled_activity: scheduled_activity})
      end
    else
      params = Map.drop(params, ["scheduled_at"])

      case maybe_get_cached_status(conn, params) do
        {:ignore, message} ->
          conn
          |> put_status(401)
          |> json(%{error: message})

        {:error, message} ->
          conn
          |> put_status(401)
          |> json(%{error: message})

        {_, activity} ->
          conn
          |> put_view(StatusView)
          |> try_render("status.json", %{activity: activity, for: user, as: :activity})
      end
    end
  end

  defp maybe_get_cached_status(%{assigns: %{user: user}} = conn, params) do
    idempotency_key =
      case get_req_header(conn, "idempotency-key") do
        [key] -> key
        _ -> Ecto.UUID.generate()
      end

    Cachex.fetch(:idempotency_cache, idempotency_key, fn _ ->
      case CommonAPI.post(user, params) do
        {:ok, activity} -> activity
        {:error, message} -> {:ignore, message}
      end
    end)
  end

  def delete_status(%{assigns: %{user: user}} = conn, %{"id" => id}) do
    with {:ok, %Activity{}} <- CommonAPI.delete(id, user) do
      json(conn, %{})
    else
      _e ->
        conn
        |> put_status(403)
        |> json(%{error: "Can't delete this post"})
    end
  end

  def reblog_status(%{assigns: %{user: user}} = conn, %{"id" => ap_id_or_id}) do
    with {:ok, announce, _activity} <- CommonAPI.repeat(ap_id_or_id, user),
         %Activity{} = announce <- Activity.normalize(announce.data) do
      conn
      |> put_view(StatusView)
      |> try_render("status.json", %{activity: announce, for: user, as: :activity})
    end
  end

  def unreblog_status(%{assigns: %{user: user}} = conn, %{"id" => ap_id_or_id}) do
    with {:ok, _unannounce, %{data: %{"id" => id}}} <- CommonAPI.unrepeat(ap_id_or_id, user),
         %Activity{} = activity <- Activity.get_create_by_object_ap_id_with_object(id) do
      conn
      |> put_view(StatusView)
      |> try_render("status.json", %{activity: activity, for: user, as: :activity})
    end
  end

  def fav_status(%{assigns: %{user: user}} = conn, %{"id" => ap_id_or_id}) do
    with {:ok, _fav, %{data: %{"id" => id}}} <- CommonAPI.favorite(ap_id_or_id, user),
         %Activity{} = activity <- Activity.get_create_by_object_ap_id(id) do
      conn
      |> put_view(StatusView)
      |> try_render("status.json", %{activity: activity, for: user, as: :activity})
    end
  end

  def unfav_status(%{assigns: %{user: user}} = conn, %{"id" => ap_id_or_id}) do
    with {:ok, _, _, %{data: %{"id" => id}}} <- CommonAPI.unfavorite(ap_id_or_id, user),
         %Activity{} = activity <- Activity.get_create_by_object_ap_id(id) do
      conn
      |> put_view(StatusView)
      |> try_render("status.json", %{activity: activity, for: user, as: :activity})
    end
  end

  def pin_status(%{assigns: %{user: user}} = conn, %{"id" => ap_id_or_id}) do
    with {:ok, activity} <- CommonAPI.pin(ap_id_or_id, user) do
      conn
      |> put_view(StatusView)
      |> try_render("status.json", %{activity: activity, for: user, as: :activity})
    else
      {:error, reason} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(:bad_request, Jason.encode!(%{"error" => reason}))
    end
  end

  def unpin_status(%{assigns: %{user: user}} = conn, %{"id" => ap_id_or_id}) do
    with {:ok, activity} <- CommonAPI.unpin(ap_id_or_id, user) do
      conn
      |> put_view(StatusView)
      |> try_render("status.json", %{activity: activity, for: user, as: :activity})
    end
  end

  def bookmark_status(%{assigns: %{user: user}} = conn, %{"id" => id}) do
    with %Activity{} = activity <- Activity.get_by_id_with_object(id),
         %Object{} = object <- Object.normalize(activity),
         %User{} = user <- User.get_by_nickname(user.nickname),
         true <- Visibility.visible_for_user?(activity, user),
         {:ok, user} <- User.bookmark(user, object.data["id"]) do
      conn
      |> put_view(StatusView)
      |> try_render("status.json", %{activity: activity, for: user, as: :activity})
    end
  end

  def unbookmark_status(%{assigns: %{user: user}} = conn, %{"id" => id}) do
    with %Activity{} = activity <- Activity.get_by_id_with_object(id),
         %Object{} = object <- Object.normalize(activity),
         %User{} = user <- User.get_by_nickname(user.nickname),
         true <- Visibility.visible_for_user?(activity, user),
         {:ok, user} <- User.unbookmark(user, object.data["id"]) do
      conn
      |> put_view(StatusView)
      |> try_render("status.json", %{activity: activity, for: user, as: :activity})
    end
  end

  def mute_conversation(%{assigns: %{user: user}} = conn, %{"id" => id}) do
    activity = Activity.get_by_id(id)

    with {:ok, activity} <- CommonAPI.add_mute(user, activity) do
      conn
      |> put_view(StatusView)
      |> try_render("status.json", %{activity: activity, for: user, as: :activity})
    else
      {:error, reason} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(:bad_request, Jason.encode!(%{"error" => reason}))
    end
  end

  def unmute_conversation(%{assigns: %{user: user}} = conn, %{"id" => id}) do
    activity = Activity.get_by_id(id)

    with {:ok, activity} <- CommonAPI.remove_mute(user, activity) do
      conn
      |> put_view(StatusView)
      |> try_render("status.json", %{activity: activity, for: user, as: :activity})
    end
  end

  def notifications(%{assigns: %{user: user}} = conn, params) do
    notifications = MastodonAPI.get_notifications(user, params)

    conn
    |> add_link_headers(:notifications, notifications)
    |> put_view(NotificationView)
    |> render("index.json", %{notifications: notifications, for: user})
  end

  def get_notification(%{assigns: %{user: user}} = conn, %{"id" => id} = _params) do
    with {:ok, notification} <- Notification.get(user, id) do
      conn
      |> put_view(NotificationView)
      |> render("show.json", %{notification: notification, for: user})
    else
      {:error, reason} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(403, Jason.encode!(%{"error" => reason}))
    end
  end

  def clear_notifications(%{assigns: %{user: user}} = conn, _params) do
    Notification.clear(user)
    json(conn, %{})
  end

  def dismiss_notification(%{assigns: %{user: user}} = conn, %{"id" => id} = _params) do
    with {:ok, _notif} <- Notification.dismiss(user, id) do
      json(conn, %{})
    else
      {:error, reason} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(403, Jason.encode!(%{"error" => reason}))
    end
  end

  def destroy_multiple(%{assigns: %{user: user}} = conn, %{"ids" => ids} = _params) do
    Notification.destroy_multiple(user, ids)
    json(conn, %{})
  end

  def relationships(%{assigns: %{user: user}} = conn, %{"id" => id}) do
    id = List.wrap(id)
    q = from(u in User, where: u.id in ^id)
    targets = Repo.all(q)

    conn
    |> put_view(AccountView)
    |> render("relationships.json", %{user: user, targets: targets})
  end

  # Instead of returning a 400 when no "id" params is present, Mastodon returns an empty array.
  def relationships(%{assigns: %{user: _user}} = conn, _), do: json(conn, [])

  def update_media(%{assigns: %{user: user}} = conn, data) do
    with %Object{} = object <- Repo.get(Object, data["id"]),
         true <- Object.authorize_mutation(object, user),
         true <- is_binary(data["description"]),
         description <- data["description"] do
      new_data = %{object.data | "name" => description}

      {:ok, _} =
        object
        |> Object.change(%{data: new_data})
        |> Repo.update()

      attachment_data = Map.put(new_data, "id", object.id)

      conn
      |> put_view(StatusView)
      |> render("attachment.json", %{attachment: attachment_data})
    end
  end

  def upload(%{assigns: %{user: user}} = conn, %{"file" => file} = data) do
    with {:ok, object} <-
           ActivityPub.upload(
             file,
             actor: User.ap_id(user),
             description: Map.get(data, "description")
           ) do
      attachment_data = Map.put(object.data, "id", object.id)

      conn
      |> put_view(StatusView)
      |> render("attachment.json", %{attachment: attachment_data})
    end
  end

  def favourited_by(conn, %{"id" => id}) do
    with %Activity{data: %{"object" => object}} <- Repo.get(Activity, id),
         %Object{data: %{"likes" => likes}} <- Object.normalize(object) do
      q = from(u in User, where: u.ap_id in ^likes)
      users = Repo.all(q)

      conn
      |> put_view(AccountView)
      |> render(AccountView, "accounts.json", %{users: users, as: :user})
    else
      _ -> json(conn, [])
    end
  end

  def reblogged_by(conn, %{"id" => id}) do
    with %Activity{data: %{"object" => object}} <- Repo.get(Activity, id),
         %Object{data: %{"announcements" => announces}} <- Object.normalize(object) do
      q = from(u in User, where: u.ap_id in ^announces)
      users = Repo.all(q)

      conn
      |> put_view(AccountView)
      |> render("accounts.json", %{users: users, as: :user})
    else
      _ -> json(conn, [])
    end
  end

  def hashtag_timeline(%{assigns: %{user: user}} = conn, params) do
    local_only = params["local"] in [true, "True", "true", "1"]

    tags =
      [params["tag"], params["any"]]
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.filter(& &1)
      |> Enum.map(&String.downcase(&1))

    tag_all =
      params["all"] ||
        []
        |> Enum.map(&String.downcase(&1))

    tag_reject =
      params["none"] ||
        []
        |> Enum.map(&String.downcase(&1))

    activities =
      params
      |> Map.put("type", "Create")
      |> Map.put("local_only", local_only)
      |> Map.put("blocking_user", user)
      |> Map.put("muting_user", user)
      |> Map.put("tag", tags)
      |> Map.put("tag_all", tag_all)
      |> Map.put("tag_reject", tag_reject)
      |> ActivityPub.fetch_public_activities()
      |> Enum.reverse()

    conn
    |> add_link_headers(:hashtag_timeline, activities, params["tag"], %{"local" => local_only})
    |> put_view(StatusView)
    |> render("index.json", %{activities: activities, for: user, as: :activity})
  end

  def followers(%{assigns: %{user: for_user}} = conn, %{"id" => id} = params) do
    with %User{} = user <- User.get_by_id(id),
         followers <- MastodonAPI.get_followers(user, params) do
      followers =
        cond do
          for_user && user.id == for_user.id -> followers
          user.info.hide_followers -> []
          true -> followers
        end

      conn
      |> add_link_headers(:followers, followers, user)
      |> put_view(AccountView)
      |> render("accounts.json", %{users: followers, as: :user})
    end
  end

  def following(%{assigns: %{user: for_user}} = conn, %{"id" => id} = params) do
    with %User{} = user <- User.get_by_id(id),
         followers <- MastodonAPI.get_friends(user, params) do
      followers =
        cond do
          for_user && user.id == for_user.id -> followers
          user.info.hide_follows -> []
          true -> followers
        end

      conn
      |> add_link_headers(:following, followers, user)
      |> put_view(AccountView)
      |> render("accounts.json", %{users: followers, as: :user})
    end
  end

  def follow_requests(%{assigns: %{user: followed}} = conn, _params) do
    with {:ok, follow_requests} <- User.get_follow_requests(followed) do
      conn
      |> put_view(AccountView)
      |> render("accounts.json", %{users: follow_requests, as: :user})
    end
  end

  def authorize_follow_request(%{assigns: %{user: followed}} = conn, %{"id" => id}) do
    with %User{} = follower <- User.get_by_id(id),
         {:ok, follower} <- CommonAPI.accept_follow_request(follower, followed) do
      conn
      |> put_view(AccountView)
      |> render("relationship.json", %{user: followed, target: follower})
    else
      {:error, message} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(403, Jason.encode!(%{"error" => message}))
    end
  end

  def reject_follow_request(%{assigns: %{user: followed}} = conn, %{"id" => id}) do
    with %User{} = follower <- User.get_by_id(id),
         {:ok, follower} <- CommonAPI.reject_follow_request(follower, followed) do
      conn
      |> put_view(AccountView)
      |> render("relationship.json", %{user: followed, target: follower})
    else
      {:error, message} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(403, Jason.encode!(%{"error" => message}))
    end
  end

  def follow(%{assigns: %{user: follower}} = conn, %{"id" => id}) do
    with {_, %User{} = followed} <- {:followed, User.get_cached_by_id(id)},
         {_, true} <- {:followed, follower.id != followed.id},
         {:ok, follower} <- MastodonAPI.follow(follower, followed, conn.params) do
      conn
      |> put_view(AccountView)
      |> render("relationship.json", %{user: follower, target: followed})
    else
      {:followed, _} ->
        {:error, :not_found}

      {:error, message} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(403, Jason.encode!(%{"error" => message}))
    end
  end

  def follow(%{assigns: %{user: follower}} = conn, %{"uri" => uri}) do
    with {_, %User{} = followed} <- {:followed, User.get_cached_by_nickname(uri)},
         {_, true} <- {:followed, follower.id != followed.id},
         {:ok, follower, followed, _} <- CommonAPI.follow(follower, followed) do
      conn
      |> put_view(AccountView)
      |> render("account.json", %{user: followed, for: follower})
    else
      {:followed, _} ->
        {:error, :not_found}

      {:error, message} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(403, Jason.encode!(%{"error" => message}))
    end
  end

  def unfollow(%{assigns: %{user: follower}} = conn, %{"id" => id}) do
    with {_, %User{} = followed} <- {:followed, User.get_cached_by_id(id)},
         {_, true} <- {:followed, follower.id != followed.id},
         {:ok, follower} <- CommonAPI.unfollow(follower, followed) do
      conn
      |> put_view(AccountView)
      |> render("relationship.json", %{user: follower, target: followed})
    else
      {:followed, _} ->
        {:error, :not_found}

      error ->
        error
    end
  end

  def mute(%{assigns: %{user: muter}} = conn, %{"id" => id}) do
    with %User{} = muted <- User.get_by_id(id),
         {:ok, muter} <- User.mute(muter, muted) do
      conn
      |> put_view(AccountView)
      |> render("relationship.json", %{user: muter, target: muted})
    else
      {:error, message} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(403, Jason.encode!(%{"error" => message}))
    end
  end

  def unmute(%{assigns: %{user: muter}} = conn, %{"id" => id}) do
    with %User{} = muted <- User.get_by_id(id),
         {:ok, muter} <- User.unmute(muter, muted) do
      conn
      |> put_view(AccountView)
      |> render("relationship.json", %{user: muter, target: muted})
    else
      {:error, message} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(403, Jason.encode!(%{"error" => message}))
    end
  end

  def mutes(%{assigns: %{user: user}} = conn, _) do
    with muted_accounts <- User.muted_users(user) do
      res = AccountView.render("accounts.json", users: muted_accounts, for: user, as: :user)
      json(conn, res)
    end
  end

  def block(%{assigns: %{user: blocker}} = conn, %{"id" => id}) do
    with %User{} = blocked <- User.get_by_id(id),
         {:ok, blocker} <- User.block(blocker, blocked),
         {:ok, _activity} <- ActivityPub.block(blocker, blocked) do
      conn
      |> put_view(AccountView)
      |> render("relationship.json", %{user: blocker, target: blocked})
    else
      {:error, message} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(403, Jason.encode!(%{"error" => message}))
    end
  end

  def unblock(%{assigns: %{user: blocker}} = conn, %{"id" => id}) do
    with %User{} = blocked <- User.get_by_id(id),
         {:ok, blocker} <- User.unblock(blocker, blocked),
         {:ok, _activity} <- ActivityPub.unblock(blocker, blocked) do
      conn
      |> put_view(AccountView)
      |> render("relationship.json", %{user: blocker, target: blocked})
    else
      {:error, message} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(403, Jason.encode!(%{"error" => message}))
    end
  end

  def blocks(%{assigns: %{user: user}} = conn, _) do
    with blocked_accounts <- User.blocked_users(user) do
      res = AccountView.render("accounts.json", users: blocked_accounts, for: user, as: :user)
      json(conn, res)
    end
  end

  def domain_blocks(%{assigns: %{user: %{info: info}}} = conn, _) do
    json(conn, info.domain_blocks || [])
  end

  def block_domain(%{assigns: %{user: blocker}} = conn, %{"domain" => domain}) do
    User.block_domain(blocker, domain)
    json(conn, %{})
  end

  def unblock_domain(%{assigns: %{user: blocker}} = conn, %{"domain" => domain}) do
    User.unblock_domain(blocker, domain)
    json(conn, %{})
  end

  def subscribe(%{assigns: %{user: user}} = conn, %{"id" => id}) do
    with %User{} = subscription_target <- User.get_cached_by_id(id),
         {:ok, subscription_target} = User.subscribe(user, subscription_target) do
      conn
      |> put_view(AccountView)
      |> render("relationship.json", %{user: user, target: subscription_target})
    else
      {:error, message} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(403, Jason.encode!(%{"error" => message}))
    end
  end

  def unsubscribe(%{assigns: %{user: user}} = conn, %{"id" => id}) do
    with %User{} = subscription_target <- User.get_cached_by_id(id),
         {:ok, subscription_target} = User.unsubscribe(user, subscription_target) do
      conn
      |> put_view(AccountView)
      |> render("relationship.json", %{user: user, target: subscription_target})
    else
      {:error, message} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(403, Jason.encode!(%{"error" => message}))
    end
  end

  def status_search(user, query) do
    fetched =
      if Regex.match?(~r/https?:/, query) do
        with {:ok, object} <- Fetcher.fetch_object_from_id(query),
             %Activity{} = activity <- Activity.get_create_by_object_ap_id(object.data["id"]),
             true <- Visibility.visible_for_user?(activity, user) do
          [activity]
        else
          _e -> []
        end
      end || []

    q =
      from(
        [a, o] in Activity.with_preloaded_object(Activity),
        where: fragment("?->>'type' = 'Create'", a.data),
        where: "https://www.w3.org/ns/activitystreams#Public" in a.recipients,
        where:
          fragment(
            "to_tsvector('english', ?->>'content') @@ plainto_tsquery('english', ?)",
            o.data,
            ^query
          ),
        limit: 20,
        order_by: [desc: :id]
      )

    Repo.all(q) ++ fetched
  end

  def search2(%{assigns: %{user: user}} = conn, %{"q" => query} = params) do
    accounts = User.search(query, resolve: params["resolve"] == "true", for_user: user)

    statuses = status_search(user, query)

    tags_path = Web.base_url() <> "/tag/"

    tags =
      query
      |> String.split()
      |> Enum.uniq()
      |> Enum.filter(fn tag -> String.starts_with?(tag, "#") end)
      |> Enum.map(fn tag -> String.slice(tag, 1..-1) end)
      |> Enum.map(fn tag -> %{name: tag, url: tags_path <> tag} end)

    res = %{
      "accounts" => AccountView.render("accounts.json", users: accounts, for: user, as: :user),
      "statuses" =>
        StatusView.render("index.json", activities: statuses, for: user, as: :activity),
      "hashtags" => tags
    }

    json(conn, res)
  end

  def search(%{assigns: %{user: user}} = conn, %{"q" => query} = params) do
    accounts = User.search(query, resolve: params["resolve"] == "true", for_user: user)

    statuses = status_search(user, query)

    tags =
      query
      |> String.split()
      |> Enum.uniq()
      |> Enum.filter(fn tag -> String.starts_with?(tag, "#") end)
      |> Enum.map(fn tag -> String.slice(tag, 1..-1) end)

    res = %{
      "accounts" => AccountView.render("accounts.json", users: accounts, for: user, as: :user),
      "statuses" =>
        StatusView.render("index.json", activities: statuses, for: user, as: :activity),
      "hashtags" => tags
    }

    json(conn, res)
  end

  def account_search(%{assigns: %{user: user}} = conn, %{"q" => query} = params) do
    accounts = User.search(query, resolve: params["resolve"] == "true", for_user: user)

    res = AccountView.render("accounts.json", users: accounts, for: user, as: :user)

    json(conn, res)
  end

  def favourites(%{assigns: %{user: user}} = conn, params) do
    params =
      params
      |> Map.put("type", "Create")
      |> Map.put("favorited_by", user.ap_id)
      |> Map.put("blocking_user", user)

    activities =
      ActivityPub.fetch_activities([], params)
      |> Enum.reverse()

    conn
    |> add_link_headers(:favourites, activities)
    |> put_view(StatusView)
    |> render("index.json", %{activities: activities, for: user, as: :activity})
  end

  def bookmarks(%{assigns: %{user: user}} = conn, _) do
    user = User.get_by_id(user.id)

    activities =
      user.bookmarks
      |> Enum.map(fn id -> Activity.get_create_by_object_ap_id(id) end)
      |> Enum.reverse()

    conn
    |> put_view(StatusView)
    |> render("index.json", %{activities: activities, for: user, as: :activity})
  end

  def get_lists(%{assigns: %{user: user}} = conn, opts) do
    lists = Pleroma.List.for_user(user, opts)
    res = ListView.render("lists.json", lists: lists)
    json(conn, res)
  end

  def get_list(%{assigns: %{user: user}} = conn, %{"id" => id}) do
    with %Pleroma.List{} = list <- Pleroma.List.get(id, user) do
      res = ListView.render("list.json", list: list)
      json(conn, res)
    else
      _e ->
        conn
        |> put_status(404)
        |> json(%{error: "Record not found"})
    end
  end

  def account_lists(%{assigns: %{user: user}} = conn, %{"id" => account_id}) do
    lists = Pleroma.List.get_lists_account_belongs(user, account_id)
    res = ListView.render("lists.json", lists: lists)
    json(conn, res)
  end

  def delete_list(%{assigns: %{user: user}} = conn, %{"id" => id}) do
    with %Pleroma.List{} = list <- Pleroma.List.get(id, user),
         {:ok, _list} <- Pleroma.List.delete(list) do
      json(conn, %{})
    else
      _e ->
        json(conn, "error")
    end
  end

  def create_list(%{assigns: %{user: user}} = conn, %{"title" => title}) do
    with {:ok, %Pleroma.List{} = list} <- Pleroma.List.create(title, user) do
      res = ListView.render("list.json", list: list)
      json(conn, res)
    end
  end

  def add_to_list(%{assigns: %{user: user}} = conn, %{"id" => id, "account_ids" => accounts}) do
    accounts
    |> Enum.each(fn account_id ->
      with %Pleroma.List{} = list <- Pleroma.List.get(id, user),
           %User{} = followed <- User.get_by_id(account_id) do
        Pleroma.List.follow(list, followed)
      end
    end)

    json(conn, %{})
  end

  def remove_from_list(%{assigns: %{user: user}} = conn, %{"id" => id, "account_ids" => accounts}) do
    accounts
    |> Enum.each(fn account_id ->
      with %Pleroma.List{} = list <- Pleroma.List.get(id, user),
           %User{} = followed <- Pleroma.User.get_by_id(account_id) do
        Pleroma.List.unfollow(list, followed)
      end
    end)

    json(conn, %{})
  end

  def list_accounts(%{assigns: %{user: user}} = conn, %{"id" => id}) do
    with %Pleroma.List{} = list <- Pleroma.List.get(id, user),
         {:ok, users} = Pleroma.List.get_following(list) do
      conn
      |> put_view(AccountView)
      |> render("accounts.json", %{users: users, as: :user})
    end
  end

  def rename_list(%{assigns: %{user: user}} = conn, %{"id" => id, "title" => title}) do
    with %Pleroma.List{} = list <- Pleroma.List.get(id, user),
         {:ok, list} <- Pleroma.List.rename(list, title) do
      res = ListView.render("list.json", list: list)
      json(conn, res)
    else
      _e ->
        json(conn, "error")
    end
  end

  def list_timeline(%{assigns: %{user: user}} = conn, %{"list_id" => id} = params) do
    with %Pleroma.List{title: _title, following: following} <- Pleroma.List.get(id, user) do
      params =
        params
        |> Map.put("type", "Create")
        |> Map.put("blocking_user", user)
        |> Map.put("muting_user", user)

      # we must filter the following list for the user to avoid leaking statuses the user
      # does not actually have permission to see (for more info, peruse security issue #270).
      activities =
        following
        |> Enum.filter(fn x -> x in user.following end)
        |> ActivityPub.fetch_activities_bounded(following, params)
        |> Enum.reverse()

      conn
      |> put_view(StatusView)
      |> render("index.json", %{activities: activities, for: user, as: :activity})
    else
      _e ->
        conn
        |> put_status(403)
        |> json(%{error: "Error."})
    end
  end

  def index(%{assigns: %{user: user}} = conn, _params) do
    token = get_session(conn, :oauth_token)

    if user && token do
      mastodon_emoji = mastodonized_emoji()

      limit = Config.get([:instance, :limit])

      accounts =
        Map.put(%{}, user.id, AccountView.render("account.json", %{user: user, for: user}))

      flavour = get_user_flavour(user)

      initial_state =
        %{
          meta: %{
            streaming_api_base_url:
              String.replace(Pleroma.Web.Endpoint.static_url(), "http", "ws"),
            access_token: token,
            locale: "en",
            domain: Pleroma.Web.Endpoint.host(),
            admin: "1",
            me: "#{user.id}",
            unfollow_modal: false,
            boost_modal: false,
            delete_modal: true,
            auto_play_gif: false,
            display_sensitive_media: false,
            reduce_motion: false,
            max_toot_chars: limit,
            mascot: "/images/pleroma-fox-tan-smol.png"
          },
          poll_limits: Config.get([:instance, :poll_limits]),
          rights: %{
            delete_others_notice: present?(user.info.is_moderator),
            admin: present?(user.info.is_admin)
          },
          compose: %{
            me: "#{user.id}",
            default_privacy: user.info.default_scope,
            default_sensitive: false,
            allow_content_types: Config.get([:instance, :allowed_post_formats])
          },
          media_attachments: %{
            accept_content_types: [
              ".jpg",
              ".jpeg",
              ".png",
              ".gif",
              ".webm",
              ".mp4",
              ".m4v",
              "image\/jpeg",
              "image\/png",
              "image\/gif",
              "video\/webm",
              "video\/mp4"
            ]
          },
          settings:
            user.info.settings ||
              %{
                onboarded: true,
                home: %{
                  shows: %{
                    reblog: true,
                    reply: true
                  }
                },
                notifications: %{
                  alerts: %{
                    follow: true,
                    favourite: true,
                    reblog: true,
                    mention: true
                  },
                  shows: %{
                    follow: true,
                    favourite: true,
                    reblog: true,
                    mention: true
                  },
                  sounds: %{
                    follow: true,
                    favourite: true,
                    reblog: true,
                    mention: true
                  }
                }
              },
          push_subscription: nil,
          accounts: accounts,
          custom_emojis: mastodon_emoji,
          char_limit: limit
        }
        |> Jason.encode!()

      conn
      |> put_layout(false)
      |> put_view(MastodonView)
      |> render("index.html", %{initial_state: initial_state, flavour: flavour})
    else
      conn
      |> put_session(:return_to, conn.request_path)
      |> redirect(to: "/web/login")
    end
  end

  def put_settings(%{assigns: %{user: user}} = conn, %{"data" => settings} = _params) do
    info_cng = User.Info.mastodon_settings_update(user.info, settings)

    with changeset <- Ecto.Changeset.change(user),
         changeset <- Ecto.Changeset.put_embed(changeset, :info, info_cng),
         {:ok, _user} <- User.update_and_set_cache(changeset) do
      json(conn, %{})
    else
      e ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(500, Jason.encode!(%{"error" => inspect(e)}))
    end
  end

  @supported_flavours ["glitch", "vanilla"]

  def set_flavour(%{assigns: %{user: user}} = conn, %{"flavour" => flavour} = _params)
      when flavour in @supported_flavours do
    flavour_cng = User.Info.mastodon_flavour_update(user.info, flavour)

    with changeset <- Ecto.Changeset.change(user),
         changeset <- Ecto.Changeset.put_embed(changeset, :info, flavour_cng),
         {:ok, user} <- User.update_and_set_cache(changeset),
         flavour <- user.info.flavour do
      json(conn, flavour)
    else
      e ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(500, Jason.encode!(%{"error" => inspect(e)}))
    end
  end

  def set_flavour(conn, _params) do
    conn
    |> put_status(400)
    |> json(%{error: "Unsupported flavour"})
  end

  def get_flavour(%{assigns: %{user: user}} = conn, _params) do
    json(conn, get_user_flavour(user))
  end

  defp get_user_flavour(%User{info: %{flavour: flavour}}) when flavour in @supported_flavours do
    flavour
  end

  defp get_user_flavour(_) do
    "glitch"
  end

  def vote(%{assigns: %{user: user}} = conn, params) do
    case CommonAPI.vote(user, %{params | "id" => params["id"]}) do
      {:ok, activity} ->
        object = Object.get_by_id(Question.get_id_by_activity(activity))

        conn
        |> put_status(200)
        |> json(QuestionView.render("show.json", %{object: object, user: user}))

      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(401, Jason.encode!(%{"error" => "Failed to vote"}))
    end
  end

  def get_poll(%{assigns: %{user: user}} = conn, params) do
    object = Object.get_by_id(params["id"])

    conn
    |> put_status(200)
    |> json(QuestionView.render("show.json", %{object: object, user: user}))
  end

  def login(%{assigns: %{user: %User{}}} = conn, _params) do
    redirect(conn, to: local_mastodon_root_path(conn))
  end

  @doc "Local Mastodon FE login init action"
  def login(conn, %{"code" => auth_token}) do
    with {:ok, app} <- get_or_make_app(),
         %Authorization{} = auth <- Repo.get_by(Authorization, token: auth_token, app_id: app.id),
         {:ok, token} <- Token.exchange_token(app, auth) do
      conn
      |> put_session(:oauth_token, token.token)
      |> redirect(to: local_mastodon_root_path(conn))
    end
  end

  @doc "Local Mastodon FE callback action"
  def login(conn, _) do
    with {:ok, app} <- get_or_make_app() do
      path =
        o_auth_path(
          conn,
          :authorize,
          response_type: "code",
          client_id: app.client_id,
          redirect_uri: ".",
          scope: Enum.join(app.scopes, " ")
        )

      redirect(conn, to: path)
    end
  end

  defp local_mastodon_root_path(conn) do
    case get_session(conn, :return_to) do
      nil ->
        mastodon_api_path(conn, :index, ["getting-started"])

      return_to ->
        delete_session(conn, :return_to)
        return_to
    end
  end

  defp get_or_make_app do
    find_attrs = %{client_name: @local_mastodon_name, redirect_uris: "."}
    scopes = ["read", "write", "follow", "push"]

    with %App{} = app <- Repo.get_by(App, find_attrs) do
      {:ok, app} =
        if app.scopes == scopes do
          {:ok, app}
        else
          app
          |> Ecto.Changeset.change(%{scopes: scopes})
          |> Repo.update()
        end

      {:ok, app}
    else
      _e ->
        cs =
          App.register_changeset(
            %App{},
            Map.put(find_attrs, :scopes, scopes)
          )

        Repo.insert(cs)
    end
  end

  def logout(conn, _) do
    conn
    |> clear_session
    |> redirect(to: "/")
  end

  def relationship_noop(%{assigns: %{user: user}} = conn, %{"id" => id}) do
    Logger.debug("Unimplemented, returning unmodified relationship")

    with %User{} = target <- User.get_by_id(id) do
      conn
      |> put_view(AccountView)
      |> render("relationship.json", %{user: user, target: target})
    end
  end

  def empty_array(conn, _) do
    Logger.debug("Unimplemented, returning an empty array")
    json(conn, [])
  end

  def empty_object(conn, _) do
    Logger.debug("Unimplemented, returning an empty object")
    json(conn, %{})
  end

  def get_filters(%{assigns: %{user: user}} = conn, _) do
    filters = Filter.get_filters(user)
    res = FilterView.render("filters.json", filters: filters)
    json(conn, res)
  end

  def create_filter(
        %{assigns: %{user: user}} = conn,
        %{"phrase" => phrase, "context" => context} = params
      ) do
    query = %Filter{
      user_id: user.id,
      phrase: phrase,
      context: context,
      hide: Map.get(params, "irreversible", nil),
      whole_word: Map.get(params, "boolean", true)
      # expires_at
    }

    {:ok, response} = Filter.create(query)
    res = FilterView.render("filter.json", filter: response)
    json(conn, res)
  end

  def get_filter(%{assigns: %{user: user}} = conn, %{"id" => filter_id}) do
    filter = Filter.get(filter_id, user)
    res = FilterView.render("filter.json", filter: filter)
    json(conn, res)
  end

  def update_filter(
        %{assigns: %{user: user}} = conn,
        %{"phrase" => phrase, "context" => context, "id" => filter_id} = params
      ) do
    query = %Filter{
      user_id: user.id,
      filter_id: filter_id,
      phrase: phrase,
      context: context,
      hide: Map.get(params, "irreversible", nil),
      whole_word: Map.get(params, "boolean", true)
      # expires_at
    }

    {:ok, response} = Filter.update(query)
    res = FilterView.render("filter.json", filter: response)
    json(conn, res)
  end

  def delete_filter(%{assigns: %{user: user}} = conn, %{"id" => filter_id}) do
    query = %Filter{
      user_id: user.id,
      filter_id: filter_id
    }

    {:ok, _} = Filter.delete(query)
    json(conn, %{})
  end

  # fallback action
  #
  def errors(conn, {:error, %Changeset{} = changeset}) do
    error_message =
      changeset
      |> Changeset.traverse_errors(fn {message, _opt} -> message end)
      |> Enum.map_join(", ", fn {_k, v} -> v end)

    conn
    |> put_status(422)
    |> json(%{error: error_message})
  end

  def errors(conn, {:error, :not_found}) do
    conn
    |> put_status(404)
    |> json(%{error: "Record not found"})
  end

  def errors(conn, _) do
    conn
    |> put_status(500)
    |> json("Something went wrong")
  end

  def suggestions(%{assigns: %{user: user}} = conn, _) do
    suggestions = Config.get(:suggestions)

    if Keyword.get(suggestions, :enabled, false) do
      api = Keyword.get(suggestions, :third_party_engine, "")
      timeout = Keyword.get(suggestions, :timeout, 5000)
      limit = Keyword.get(suggestions, :limit, 23)

      host = Config.get([Pleroma.Web.Endpoint, :url, :host])

      user = user.nickname

      url =
        api
        |> String.replace("{{host}}", host)
        |> String.replace("{{user}}", user)

      with {:ok, %{status: 200, body: body}} <-
             @httpoison.get(
               url,
               [],
               adapter: [
                 recv_timeout: timeout,
                 pool: :default
               ]
             ),
           {:ok, data} <- Jason.decode(body) do
        data =
          data
          |> Enum.slice(0, limit)
          |> Enum.map(fn x ->
            Map.put(
              x,
              "id",
              case User.get_or_fetch(x["acct"]) do
                %{id: id} -> id
                _ -> 0
              end
            )
          end)
          |> Enum.map(fn x ->
            Map.put(x, "avatar", MediaProxy.url(x["avatar"]))
          end)
          |> Enum.map(fn x ->
            Map.put(x, "avatar_static", MediaProxy.url(x["avatar_static"]))
          end)

        conn
        |> json(data)
      else
        e -> Logger.error("Could not retrieve suggestions at fetch #{url}, #{inspect(e)}")
      end
    else
      json(conn, [])
    end
  end

  def status_card(%{assigns: %{user: user}} = conn, %{"id" => status_id}) do
    with %Activity{} = activity <- Activity.get_by_id(status_id),
         true <- Visibility.visible_for_user?(activity, user) do
      data =
        StatusView.render(
          "card.json",
          Pleroma.Web.RichMedia.Helpers.fetch_data_for_activity(activity)
        )

      json(conn, data)
    else
      _e ->
        %{}
    end
  end

  def reports(%{assigns: %{user: user}} = conn, params) do
    case CommonAPI.report(user, params) do
      {:ok, activity} ->
        conn
        |> put_view(ReportView)
        |> try_render("report.json", %{activity: activity})

      {:error, err} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: err})
    end
  end

  def try_render(conn, target, params)
      when is_binary(target) do
    res = render(conn, target, params)

    if res == nil do
      conn
      |> put_status(501)
      |> json(%{error: "Can't display this activity"})
    else
      res
    end
  end

  def try_render(conn, _, _) do
    conn
    |> put_status(501)
    |> json(%{error: "Can't display this activity"})
  end

  defp present?(nil), do: false
  defp present?(false), do: false
  defp present?(_), do: true
end
