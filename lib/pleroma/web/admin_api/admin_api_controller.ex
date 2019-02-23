# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.AdminAPI.AdminAPIController do
  use Pleroma.Web, :controller
  alias Pleroma.User
  alias Pleroma.Web.ActivityPub.Relay
  alias Pleroma.Web.ActivityPub.MRF.KeywordPolicy

  import Pleroma.Web.ControllerHelper, only: [json_response: 3]

  require Logger

  action_fallback(:errors)

  def user_delete(conn, %{"nickname" => nickname}) do
    User.get_by_nickname(nickname)
    |> User.delete()

    conn
    |> json(nickname)
  end

  def user_create(
        conn,
        %{"nickname" => nickname, "email" => email, "password" => password}
      ) do
    user_data = %{
      nickname: nickname,
      name: nickname,
      email: email,
      password: password,
      password_confirmation: password,
      bio: "."
    }

    changeset = User.register_changeset(%User{}, user_data, confirmed: true)
    {:ok, user} = User.register(changeset)

    conn
    |> json(user.nickname)
  end

  def tag_users(conn, %{"nicknames" => nicknames, "tags" => tags}) do
    with {:ok, _} <- User.tag(nicknames, tags),
         do: json_response(conn, :no_content, "")
  end

  def untag_users(conn, %{"nicknames" => nicknames, "tags" => tags}) do
    with {:ok, _} <- User.untag(nicknames, tags),
         do: json_response(conn, :no_content, "")
  end

  def right_add(conn, %{"permission_group" => permission_group, "nickname" => nickname})
      when permission_group in ["moderator", "admin"] do
    user = User.get_by_nickname(nickname)

    info =
      %{}
      |> Map.put("is_" <> permission_group, true)

    info_cng = User.Info.admin_api_update(user.info, info)

    cng =
      user
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_embed(:info, info_cng)

    {:ok, _user} = User.update_and_set_cache(cng)

    json(conn, info)
  end

  def right_add(conn, _) do
    conn
    |> put_status(404)
    |> json(%{error: "No such permission_group"})
  end

  def right_get(conn, %{"nickname" => nickname}) do
    user = User.get_by_nickname(nickname)

    conn
    |> json(%{
      is_moderator: user.info.is_moderator,
      is_admin: user.info.is_admin
    })
  end

  def right_delete(
        %{assigns: %{user: %User{:nickname => admin_nickname}}} = conn,
        %{
          "permission_group" => permission_group,
          "nickname" => nickname
        }
      )
      when permission_group in ["moderator", "admin"] do
    if admin_nickname == nickname do
      conn
      |> put_status(403)
      |> json(%{error: "You can't revoke your own admin status."})
    else
      user = User.get_by_nickname(nickname)

      info =
        %{}
        |> Map.put("is_" <> permission_group, false)

      info_cng = User.Info.admin_api_update(user.info, info)

      cng =
        Ecto.Changeset.change(user)
        |> Ecto.Changeset.put_embed(:info, info_cng)

      {:ok, _user} = User.update_and_set_cache(cng)

      json(conn, info)
    end
  end

  def right_delete(conn, _) do
    conn
    |> put_status(404)
    |> json(%{error: "No such permission_group"})
  end

  def set_activation_status(conn, %{"nickname" => nickname, "status" => status}) do
    with {:ok, status} <- Ecto.Type.cast(:boolean, status),
         %User{} = user <- User.get_by_nickname(nickname),
         {:ok, _} <- User.deactivate(user, !status),
         do: json_response(conn, :no_content, "")
  end

  def relay_follow(conn, %{"relay_url" => target}) do
    with {:ok, _message} <- Relay.follow(target) do
      json(conn, target)
    else
      _ ->
        conn
        |> put_status(500)
        |> json(target)
    end
  end

  def relay_unfollow(conn, %{"relay_url" => target}) do
    with {:ok, _message} <- Relay.unfollow(target) do
      json(conn, target)
    else
      _ ->
        conn
        |> put_status(500)
        |> json(target)
    end
  end

  @doc "Sends registration invite via email"
  def email_invite(%{assigns: %{user: user}} = conn, %{"email" => email} = params) do
    with true <-
           Pleroma.Config.get([:instance, :invites_enabled]) &&
             !Pleroma.Config.get([:instance, :registrations_open]),
         {:ok, invite_token} <- Pleroma.UserInviteToken.create_token(),
         email <-
           Pleroma.UserEmail.user_invitation_email(user, invite_token, email, params["name"]),
         {:ok, _} <- Pleroma.Mailer.deliver(email) do
      json_response(conn, :no_content, "")
    end
  end

  @doc "Get a account registeration invite token (base64 string)"
  def get_invite_token(conn, _params) do
    {:ok, token} = Pleroma.UserInviteToken.create_token()

    conn
    |> json(token.token)
  end

  @doc "Get a password reset token (base64 string) for given nickname"
  def get_password_reset(conn, %{"nickname" => nickname}) do
    (%User{local: true} = user) = User.get_by_nickname(nickname)
    {:ok, token} = Pleroma.PasswordResetToken.create_token(user)

    conn
    |> json(token.token)
  end

  @doc "List this instance's keyword policy"
  def list_keyword_policy(conn, _params) do
    mrf_keyword = KeywordPolicy.list_keyword_policy()

    conn
    |> put_status(200)
    |> json(mrf_keyword)
  end

  @doc "Add another MRF Keyword Policy rule"
  def add_keyword_policy(conn, %{"policy" => policy}) do
    result =
      policy
      |> Poison.decode!()
      |> KeywordPolicy.save_keyword_policy()

    case result do
      :ok ->
        conn
        |> put_status(201)
        |> json(%{status: "success", message: "New keyword policy created"})

      {:error, msg} ->
        conn
        |> put_status(422)
        |> json(%{status: "error", message: msg})
    end
  end

  @doc "Reset the keyword policy"
  def reset_keyword_policy(conn, _params) do
    KeywordPolicy.save_keyword_policy(%{
      "federated_timeline_removal" => [],
      "reject" => [],
      "replace" => %{}
    })

    conn
    |> put_status(200)
    |> json(%{status: "success", message: "Keyword Policy has been successfully reset"})
  end

  def errors(conn, {:param_cast, _}) do
    conn
    |> put_status(400)
    |> json("Invalid parameters")
  end

  def errors(conn, _) do
    conn
    |> put_status(500)
    |> json("Something went wrong")
  end
end
