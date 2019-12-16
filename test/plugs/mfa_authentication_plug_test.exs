# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Plugs.MfaAuthenticationPlugTest do
  use Pleroma.Web.ConnCase, async: true

  alias Pleroma.MFA
  alias Pleroma.Plugs.MfaAuthenticationPlug

  import Pleroma.Factory

  setup %{conn: conn} do
    user =
      insert(:user,
        multi_factor_authentication_settings: %MFA.Settings{
          enabled: true,
          totp: %MFA.Settings.TOTP{secret: "QYNR4JU6MZ6ZPEIT", confirmed: true}
        }
      )

    %{mfa_user: user, conn: conn}
  end

  test "it does nothing if not use password credentails", %{conn: conn} do
    conn = MfaAuthenticationPlug.call(conn, %{})
    refute conn.halted
  end

  test "it halts if headers hasn't x-pleroma-otp", %{conn: conn, mfa_user: user} do
    conn =
      conn
      |> assign(:user, user)
      |> assign(:auth_credentials, %{password: "xxx"})
      |> MfaAuthenticationPlug.call(%{})

    assert conn.status == 401
    assert conn.halted == true
  end

  test "it halts when otp code invalid", %{conn: conn, mfa_user: user} do
    conn =
      conn
      |> assign(:user, user)
      |> assign(:auth_credentials, %{password: "xxx"})
      |> put_req_header("x-pleroma-otp", "1111")
      |> MfaAuthenticationPlug.call(%{})

    assert conn.status == 401
    assert conn.halted == true
  end

  test "it does nothing if otp code is valid", %{conn: conn, mfa_user: user} do
    token = :pot.totp(user.multi_factor_authentication_settings.totp.secret)

    conn =
      conn
      |> assign(:user, user)
      |> assign(:auth_credentials, %{password: "xxx"})
      |> put_req_header("x-pleroma-otp", token)
      |> MfaAuthenticationPlug.call(%{})

    refute conn.halted
  end
end
