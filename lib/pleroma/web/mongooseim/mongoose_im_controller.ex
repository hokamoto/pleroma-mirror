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
        |> put_status(403)
        |> json(false)

      _ ->
        conn
        |> put_status(:not_found)
        |> json(false)
    end
  end

  def prebind(conn, params) do
    Logger.warn("Conn: #{inspect(conn)}\n\nParams: #{inspect(params)}")
    # from = user.name

    _body = """
      <body
        content='text/xml; charset=utf-8'
        from='user1@p.devs.live'
        hold='1'
        rid='1'
        to='p.devs.live'
        route='xmpp:p.devs.live:9999'
        wait='60'
        xml:lang='en'
        xmpp:version='1.0'
        xmlns='http://jabber.org/protocol/httpbind'
        xmlns:xmpp='urn:xmpp:xbosh'
      />
    """

    IO.inspect(params)

    response = %{
      "jid" => "user1@p.devs.live",
      "sid" => "",
      "rid" => ""
    }

    json(conn, response)
  end
end
