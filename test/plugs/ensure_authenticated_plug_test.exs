# Pleroma: A lightweight social networking server
# Copyright © 2017-2018 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Plugs.EnsureAuthenticatedPlugTest do
  use Pleroma.Web.ConnCase, async: true

  alias Pleroma.Plugs.EnsureAuthenticatedPlug
  alias Pleroma.User

  test "it halts if no user is assigned", %{conn: conn} do
    conn =
      conn
      |> EnsureAuthenticatedPlug.call(%{})

    assert conn.status == 403
    assert conn.halted == true
  end

  test "it halts if user is assigned and MFA enabled", %{conn: conn} do
    conn =
      conn
      |> assign(:user, %User{multi_factor_authentication_settings: %{enabled: true}})
      |> assign(:auth_credentials, %{password: "xd-42"})
      |> EnsureAuthenticatedPlug.call(%{})

    assert conn.status == 403
    assert conn.halted == true

    assert conn.resp_body ==
             "{\"error\":\"Two-factor authentication enabled, you must use a access token.\"}"
  end

  test "it continues if user is assigned and MFA disabled", %{conn: conn} do
    conn =
      conn
      |> assign(:user, %User{multi_factor_authentication_settings: %{enabled: false}})
      |> assign(:auth_credentials, %{password: "xd-42"})
      |> EnsureAuthenticatedPlug.call(%{})

    refute conn.status == 403
    refute conn.halted
  end

  test "it continues if a user is assigned", %{conn: conn} do
    conn =
      conn
      |> assign(:user, %User{})

    ret_conn =
      conn
      |> EnsureAuthenticatedPlug.call(%{})

    assert ret_conn == conn
  end
end
