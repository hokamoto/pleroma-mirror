# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Plugs.SessionAuthenticationNocheckPlugTest do
  use Pleroma.Web.ConnCase, async: true

  import Pleroma.Factory

  alias Pleroma.Plugs.SessionAuthenticationNocheckPlug

  setup %{conn: conn} do
    user = insert(:user)

    session_opts = [
      store: :cookie,
      key: "_test",
      signing_salt: "cooldude"
    ]

    conn =
      conn
      |> Plug.Session.call(Plug.Session.init(session_opts))
      |> fetch_session()
      |> put_session(:user_id, user.id)

    %{conn: conn, user: user}
  end

  test "Assigns auth_user if user_id present in session", %{conn: conn, user: user} do
    conn = SessionAuthenticationNocheckPlug.call(conn, %{})

    assert conn.assigns.auth_user == user
  end

  test "Does not assign auth_user if user_id is absent in session", %{conn: conn} do
    conn =
      conn
      |> delete_session(:user_id)
      |> SessionAuthenticationNocheckPlug.call(%{})

    assert conn.assigns == %{}
  end

  test "Does not assign auth_user if user with the user_id doesn't exist", %{
    conn: conn,
    user: user
  } do
    conn =
      conn
      |> put_session(:user_id, user.id <> user.id)
      |> SessionAuthenticationNocheckPlug.call(%{})

    assert conn.assigns == %{}
  end
end
