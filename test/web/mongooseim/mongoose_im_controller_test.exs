# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.MongooseIMController do
  use Pleroma.Web.ConnCase
  import Pleroma.Factory

  setup %{conn: conn} do
    session_opts = [
      store: :cookie,
      key: "_test",
      signing_salt: "cooldude"
    ]

    conn =
      conn
      |> Plug.Session.call(Plug.Session.init(session_opts))
      |> fetch_session()

    %{conn: conn}
  end

  test "/user_exists", %{conn: conn} do
    _user = insert(:user, nickname: "lain")
    _remote_user = insert(:user, nickname: "alice", local: false)

    res =
      conn
      |> get(mongoose_im_path(conn, :user_exists), user: "lain")
      |> json_response(200)

    assert res == true

    res =
      conn
      |> get(mongoose_im_path(conn, :user_exists), user: "alice")
      |> json_response(404)

    assert res == false

    res =
      conn
      |> get(mongoose_im_path(conn, :user_exists), user: "bob")
      |> json_response(404)

    assert res == false
  end

  test "/check_password", %{conn: conn} do
    user = insert(:user, password_hash: Comeonin.Pbkdf2.hashpwsalt("cool"))

    res =
      conn
      |> get(mongoose_im_path(conn, :check_password), user: user.nickname, pass: "cool")
      |> json_response(200)

    assert res == true

    res =
      conn
      |> get(mongoose_im_path(conn, :check_password), user: user.nickname, pass: "uncool")
      |> json_response(403)

    assert res == false

    res =
      conn
      |> get(mongoose_im_path(conn, :check_password), user: "nobody", pass: "cool")
      |> json_response(404)

    assert res == false
  end

  describe "/conndata" do
    test "When xmpp key is set in session", %{conn: conn} do
      jid = "test@localhost"
      conn = put_session(conn, :xmpp, %{jid: jid})

      response =
        conn
        |> get(mongoose_im_path(conn, :conndata))
        |> json_response(200)

      assert response["jid"] == jid
      assert response["http_bind_url"] == "/http-bind"
      assert response["prebind_url"] == mongoose_im_url(Pleroma.Web.Endpoint, :prebind, jid)
    end

    test "When xmpp key is not set in session", %{conn: conn} do
      response =
        conn
        |> get(mongoose_im_path(conn, :conndata))
        |> json_response(200)

      assert response == false
    end
  end

  describe "/prebind" do
    test "When xmpp key is set in session and jid param matches one in session", %{conn: conn} do
      jid = "test@localhost"
      sid = "TestSessionID"
      conn = put_session(conn, :xmpp, %{jid: jid, sid: sid})

      response =
        conn
        |> get(mongoose_im_path(conn, :prebind, jid))
        |> json_response(200)

      assert response["jid"] == jid
      assert response["sid"] == sid
      assert is_integer(response["rid"])
    end

    test "When xmpp key is set in session but jid param does not match one in session", %{
      conn: conn
    } do
      jid = "test@localhost"
      sid = "TestSessionID"
      conn = put_session(conn, :xmpp, %{jid: jid, sid: sid})

      response =
        conn
        |> get(mongoose_im_path(conn, :prebind, jid <> jid))
        |> json_response(200)

      assert response == false
    end

    test "When xmpp key is not set in session", %{conn: conn} do
      jid = "test@localhost"

      response =
        conn
        |> get(mongoose_im_path(conn, :prebind, jid))
        |> json_response(200)

      assert response == false
    end
  end
end
