# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.MongooseIM.MongooseIMController do
  use Pleroma.Web, :controller
  alias Comeonin.Pbkdf2
  alias Pleroma.Repo
  alias Pleroma.User

  require Logger

  def user_exists(conn, %{"user" => username}) do
    with %User{} <- Repo.get_by(User, nickname: username, local: true) do
      conn
      |> json(true)
    else
      _ ->
        conn
        |> put_status(:not_found)
        |> json(false)
    end
  end

  def check_password(conn, %{"user" => username, "pass" => password}) do
    with %User{password_hash: password_hash} <-
           Repo.get_by(User, nickname: username, local: true),
         true <- Pbkdf2.checkpw(password, password_hash) do
      conn
      |> json(true)
    else
      false ->
        conn
        |> put_status(:forbidden)
        |> json(false)

      _ ->
        conn
        |> put_status(:not_found)
        |> json(false)
    end
  end

  def prebind(conn, _params) do
    response =
      case get_session(conn, :xmpp) do
        %{jid: jid, sid: sid} ->
          rid = System.unique_integer([:monotonic, :positive])
          %{jid: jid, sid: sid, rid: rid}

        _ ->
          false
      end

    json(conn, response)
  end

  def conndata(conn, %{"jid" => jid} = _params) do
    response =
      case get_session(conn, :xmpp) do
        %{jid: ^jid} ->
          %{
            jid: jid,
            prebind_url:
              Pleroma.Web.Router.Helpers.mongoose_im_url(Pleroma.Web.Endpoint, :prebind, jid),
            http_bind_url: Application.get_env(:pleroma, :xmpp, [])[:host] <> "/http-bind"
          }

        _ ->
          false
      end

    json(conn, response)
  end
end
