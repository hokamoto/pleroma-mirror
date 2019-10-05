# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.MastodonAPI.AccountController do
  use Pleroma.Web, :controller

  import Pleroma.Web.ControllerHelper,
    only: [add_link_headers: 2, truthy_param?: 1, assign_account_by_id: 2, json_response: 3]

  alias Pleroma.Emoji
  alias Pleroma.Plugs.RateLimiter
  alias Pleroma.User
  alias Pleroma.Web.ActivityPub.ActivityPub
  alias Pleroma.Web.CommonAPI
  alias Pleroma.Web.MastodonAPI.ListView
  alias Pleroma.Web.MastodonAPI.MastodonAPI
  alias Pleroma.Web.MastodonAPI.StatusView
  alias Pleroma.Web.OAuth.Token
  alias Pleroma.Web.TwitterAPI.TwitterAPI

  @relations [:follow, :unfollow]
  @needs_account ~W(followers following lists follow unfollow mute unmute block unblock)a

  plug(RateLimiter, {:relations_id_action, params: ["id", "uri"]} when action in @relations)
  plug(RateLimiter, :relations_actions when action in @relations)
  plug(RateLimiter, :app_account_creation when action == :create)
  plug(:assign_account_by_id when action in @needs_account)

  action_fallback(Pleroma.Web.MastodonAPI.FallbackController)

  @doc "POST /api/v1/accounts"
  def create(
        %{assigns: %{app: app}} = conn,
        %{"username" => nickname, "email" => _, "password" => _, "agreement" => true} = params
      ) do
    params =
      params
      |> Map.take([
        "email",
        "captcha_solution",
        "captcha_token",
        "captcha_answer_data",
        "token",
        "password"
      ])
      |> Map.put("nickname", nickname)
      |> Map.put("fullname", params["fullname"] || nickname)
      |> Map.put("bio", params["bio"] || "")
      |> Map.put("confirm", params["password"])

    with {:ok, user} <- TwitterAPI.register_user(params, need_confirmation: true),
         {:ok, token} <- Token.create_token(app, user, %{scopes: app.scopes}) do
      json(conn, %{
        token_type: "Bearer",
        access_token: token.token,
        scope: app.scopes,
        created_at: Token.Utils.format_created_at(token)
      })
    else
      {:error, errors} -> json_response(conn, :bad_request, errors)
    end
  end

  def create(%{assigns: %{app: _app}} = conn, _) do
    render_error(conn, :bad_request, "Missing parameters")
  end

  def create(conn, _) do
    render_error(conn, :forbidden, "Invalid credentials")
  end

  @doc "GET /api/v1/accounts/verify_credentials"
  def verify_credentials(%{assigns: %{user: user}} = conn, _) do
    chat_token = Phoenix.Token.sign(conn, "user socket", user.id)

    render(conn, "show.json",
      user: user,
      for: user,
      with_pleroma_settings: true,
      with_chat_token: chat_token
    )
  end

  @doc "PATCH /api/v1/accounts/update_credentials"
  def update_credentials(%{assigns: %{user: original_user}} = conn, params) do
    user = original_user

    user_params =
      %{}
      |> add_if_present(params, "display_name", :name)
      |> add_if_present(params, "note", :bio, fn value -> {:ok, User.parse_bio(value, user)} end)
      |> add_if_present(params, "avatar", :avatar, fn value ->
        with %Plug.Upload{} <- value,
             {:ok, object} <- ActivityPub.upload(value, type: :avatar) do
          {:ok, object.data}
        end
      end)

    emojis_text = (user_params["display_name"] || "") <> (user_params["note"] || "")

    user_info_emojis =
      user.info
      |> Map.get(:emoji, [])
      |> Enum.concat(Emoji.Formatter.get_emoji_map(emojis_text))
      |> Enum.dedup()

    info_params =
      [
        :no_rich_text,
        :locked,
        :hide_followers_count,
        :hide_follows_count,
        :hide_followers,
        :hide_follows,
        :hide_favorites,
        :show_role,
        :skip_thread_containment,
        :discoverable
      ]
      |> Enum.reduce(%{}, fn key, acc ->
        add_if_present(acc, params, to_string(key), key, &{:ok, truthy_param?(&1)})
      end)
      |> add_if_present(params, "default_scope", :default_scope)
      |> add_if_present(params, "fields", :fields, fn fields ->
        fields = Enum.map(fields, fn f -> Map.update!(f, "value", &AutoLinker.link(&1)) end)

        {:ok, fields}
      end)
      |> add_if_present(params, "fields", :raw_fields)
      |> add_if_present(params, "pleroma_settings_store", :pleroma_settings_store, fn value ->
        {:ok, Map.merge(user.info.pleroma_settings_store, value)}
      end)
      |> add_if_present(params, "header", :banner, fn value ->
        with %Plug.Upload{} <- value,
             {:ok, object} <- ActivityPub.upload(value, type: :banner) do
          {:ok, object.data}
        end
      end)
      |> add_if_present(params, "pleroma_background_image", :background, fn value ->
        with %Plug.Upload{} <- value,
             {:ok, object} <- ActivityPub.upload(value, type: :background) do
          {:ok, object.data}
        end
      end)
      |> Map.put(:emoji, user_info_emojis)

    changeset =
      user
      |> User.update_changeset(user_params)
      |> User.change_info(&User.Info.profile_update(&1, info_params))

    with {:ok, user} <- User.update_and_set_cache(changeset) do
      if original_user != user, do: CommonAPI.update(user)

      render(conn, "show.json", user: user, for: user, with_pleroma_settings: true)
    else
      _e -> render_error(conn, :forbidden, "Invalid request")
    end
  end

  defp add_if_present(map, params, params_field, map_field, value_function \\ &{:ok, &1}) do
    with true <- Map.has_key?(params, params_field),
         {:ok, new_value} <- value_function.(params[params_field]) do
      Map.put(map, map_field, new_value)
    else
      _ -> map
    end
  end

  @doc "GET /api/v1/accounts/relationships"
  def relationships(%{assigns: %{user: user}} = conn, %{"id" => id}) do
    targets = User.get_all_by_ids(List.wrap(id))

    render(conn, "relationships.json", user: user, targets: targets)
  end

  # Instead of returning a 400 when no "id" params is present, Mastodon returns an empty array.
  def relationships(%{assigns: %{user: _user}} = conn, _), do: json(conn, [])

  @doc "GET /api/v1/accounts/:id"
  def show(%{assigns: %{user: for_user}} = conn, %{"id" => nickname_or_id}) do
    with %User{} = user <- User.get_cached_by_nickname_or_id(nickname_or_id, for: for_user),
         true <- User.auth_active?(user) || user.id == for_user.id || User.superuser?(for_user) do
      render(conn, "show.json", user: user, for: for_user)
    else
      _e -> render_error(conn, :not_found, "Can't find user")
    end
  end

  @doc "GET /api/v1/accounts/:id/statuses"
  def statuses(%{assigns: %{user: reading_user}} = conn, params) do
    with %User{} = user <- User.get_cached_by_nickname_or_id(params["id"], for: reading_user) do
      params = Map.put(params, "tag", params["tagged"])
      activities = ActivityPub.fetch_user_activities(user, reading_user, params)

      conn
      |> add_link_headers(activities)
      |> put_view(StatusView)
      |> render("index.json", activities: activities, for: reading_user, as: :activity)
    end
  end

  @doc "GET /api/v1/accounts/:id/followers"
  def followers(%{assigns: %{user: for_user, account: user}} = conn, params) do
    followers =
      cond do
        for_user && user.id == for_user.id -> MastodonAPI.get_followers(user, params)
        user.info.hide_followers -> []
        true -> MastodonAPI.get_followers(user, params)
      end

    conn
    |> add_link_headers(followers)
    |> render("index.json", for: for_user, users: followers, as: :user)
  end

  @doc "GET /api/v1/accounts/:id/following"
  def following(%{assigns: %{user: for_user, account: user}} = conn, params) do
    followers =
      cond do
        for_user && user.id == for_user.id -> MastodonAPI.get_friends(user, params)
        user.info.hide_follows -> []
        true -> MastodonAPI.get_friends(user, params)
      end

    conn
    |> add_link_headers(followers)
    |> render("index.json", for: for_user, users: followers, as: :user)
  end

  @doc "GET /api/v1/accounts/:id/lists"
  def lists(%{assigns: %{user: user, account: account}} = conn, _params) do
    lists = Pleroma.List.get_lists_account_belongs(user, account)

    conn
    |> put_view(ListView)
    |> render("index.json", lists: lists)
  end

  @doc "POST /api/v1/accounts/:id/follow"
  def follow(%{assigns: %{user: %{id: id}, account: %{id: id}}}, _params) do
    {:error, :not_found}
  end

  def follow(%{assigns: %{user: follower, account: followed}} = conn, _params) do
    with {:ok, follower} <- MastodonAPI.follow(follower, followed, conn.params) do
      render(conn, "relationship.json", user: follower, target: followed)
    else
      {:error, message} -> json_response(conn, :forbidden, %{error: message})
    end
  end

  @doc "POST /api/v1/accounts/:id/unfollow"
  def unfollow(%{assigns: %{user: %{id: id}, account: %{id: id}}}, _params) do
    {:error, :not_found}
  end

  def unfollow(%{assigns: %{user: follower, account: followed}} = conn, _params) do
    with {:ok, follower} <- CommonAPI.unfollow(follower, followed) do
      render(conn, "relationship.json", user: follower, target: followed)
    end
  end

  @doc "POST /api/v1/accounts/:id/mute"
  def mute(%{assigns: %{user: muter, account: muted}} = conn, params) do
    notifications? = params |> Map.get("notifications", true) |> truthy_param?()

    with {:ok, muter} <- User.mute(muter, muted, notifications?) do
      render(conn, "relationship.json", user: muter, target: muted)
    else
      {:error, message} -> json_response(conn, :forbidden, %{error: message})
    end
  end

  @doc "POST /api/v1/accounts/:id/unmute"
  def unmute(%{assigns: %{user: muter, account: muted}} = conn, _params) do
    with {:ok, muter} <- User.unmute(muter, muted) do
      render(conn, "relationship.json", user: muter, target: muted)
    else
      {:error, message} -> json_response(conn, :forbidden, %{error: message})
    end
  end

  @doc "POST /api/v1/accounts/:id/block"
  def block(%{assigns: %{user: blocker, account: blocked}} = conn, _params) do
    with {:ok, blocker} <- User.block(blocker, blocked),
         {:ok, _activity} <- ActivityPub.block(blocker, blocked) do
      render(conn, "relationship.json", user: blocker, target: blocked)
    else
      {:error, message} -> json_response(conn, :forbidden, %{error: message})
    end
  end

  @doc "POST /api/v1/accounts/:id/unblock"
  def unblock(%{assigns: %{user: blocker, account: blocked}} = conn, _params) do
    with {:ok, blocker} <- User.unblock(blocker, blocked),
         {:ok, _activity} <- ActivityPub.unblock(blocker, blocked) do
      render(conn, "relationship.json", user: blocker, target: blocked)
    else
      {:error, message} -> json_response(conn, :forbidden, %{error: message})
    end
  end

  @doc "POST /api/v1/follows"
  def follows(%{assigns: %{user: follower}} = conn, %{"uri" => uri}) do
    with {_, %User{} = followed} <- {:followed, User.get_cached_by_nickname(uri)},
         {_, true} <- {:followed, follower.id != followed.id},
         {:ok, follower, followed, _} <- CommonAPI.follow(follower, followed) do
      render(conn, "show.json", user: followed, for: follower)
    else
      {:followed, _} -> {:error, :not_found}
      {:error, message} -> json_response(conn, :forbidden, %{error: message})
    end
  end

  @doc "GET /api/v1/mutes"
  def mutes(%{assigns: %{user: user}} = conn, _) do
    render(conn, "index.json", users: User.muted_users(user), for: user, as: :user)
  end

  @doc "GET /api/v1/blocks"
  def blocks(%{assigns: %{user: user}} = conn, _) do
    render(conn, "index.json", users: User.blocked_users(user), for: user, as: :user)
  end
end
