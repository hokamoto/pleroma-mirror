# Pleroma: A lightweight social networking server
# Copyright © 2017-2018 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.OAuth.MFAControllerTest do
  use Pleroma.Web.ConnCase
  import Pleroma.Factory

  alias Pleroma.MultiFactorAuthentications, as: MFA
  alias Pleroma.Web.Auth.TOTP

  describe "challenge/totp" do
    setup %{conn: conn} do
      otp_secret = TOTP.generate_secret()

      user =
        insert(:user,
          multi_factor_authentication_settings: %MFA.Settings{
            enabled: true,
            totp: %MFA.Settings.TOTP{secret: otp_secret, confirmed: true}
          }
        )

      app = insert(:oauth_app)
      {:ok, conn: conn, app: app, user: user}
    end

    test "returns access token with valid code", %{conn: conn, user: user, app: app} do
      otp_token = TOTP.generate_token(user.multi_factor_authentication_settings.totp.secret)
      mfa_token = insert(:mfa_token, user: user, scopes: ["write"])

      response =
        conn
        |> post("/oauth/mfa/challenge", %{
          "mfa_token" => mfa_token.token,
          "challenge_type" => "totp",
          "code" => otp_token,
          "client_id" => app.client_id,
          "client_secret" => app.client_secret
        })
        |> json_response(:ok)

      ap_id = user.ap_id

      assert match?(
               %{
                 "access_token" => _,
                 "expires_in" => 600,
                 "me" => ^ap_id,
                 "refresh_token" => _,
                 "scope" => "write",
                 "token_type" => "Bearer"
               },
               response
             )
    end

    test "returns errors when mfa token invalid", %{conn: conn, user: user, app: app} do
      otp_token = TOTP.generate_token(user.multi_factor_authentication_settings.totp.secret)

      response =
        conn
        |> post("/oauth/mfa/challenge", %{
          "mfa_token" => "XXX",
          "challenge_type" => "totp",
          "code" => otp_token,
          "client_id" => app.client_id,
          "client_secret" => app.client_secret
        })
        |> json_response(400)

      assert response == %{"error" => "Invalid code"}
    end

    test "returns error when otp code is invalid", %{conn: conn, user: user, app: app} do
      mfa_token = insert(:mfa_token, user: user, scopes: ["write"])

      response =
        conn
        |> post("/oauth/mfa/challenge", %{
          "mfa_token" => mfa_token.token,
          "challenge_type" => "totp",
          "code" => "XXX",
          "client_id" => app.client_id,
          "client_secret" => app.client_secret
        })
        |> json_response(400)

      assert response == %{"error" => "Invalid code"}
    end

    test "returns error when client credentails is wrong ", %{conn: conn, user: user} do
      otp_token = TOTP.generate_token(user.multi_factor_authentication_settings.totp.secret)
      mfa_token = insert(:mfa_token, user: user, scopes: ["write"])

      response =
        conn
        |> post("/oauth/mfa/challenge", %{
          "mfa_token" => mfa_token.token,
          "challenge_type" => "totp",
          "code" => otp_token,
          "client_id" => "xxx",
          "client_secret" => "xxx"
        })
        |> json_response(400)

      assert response == %{"error" => "Invalid code"}
    end
  end

  describe "challenge/recovery" do
    setup %{conn: conn} do
      app = insert(:oauth_app)
      {:ok, conn: conn, app: app}
    end

    test "returns access token with valid code", %{conn: conn, app: app} do
      otp_secret = TOTP.generate_secret()

      [code | _] = backup_codes = TOTP.generate_backup_codes()

      hashed_codes =
        backup_codes
        |> Enum.map(&Comeonin.Pbkdf2.hashpwsalt(&1))

      user =
        insert(:user,
          multi_factor_authentication_settings: %MFA.Settings{
            enabled: true,
            backup_codes: hashed_codes,
            totp: %MFA.Settings.TOTP{secret: otp_secret, confirmed: true}
          }
        )

      mfa_token = insert(:mfa_token, user: user, scopes: ["write"])

      response =
        conn
        |> post("/oauth/mfa/challenge", %{
          "mfa_token" => mfa_token.token,
          "challenge_type" => "recovery",
          "code" => code,
          "client_id" => app.client_id,
          "client_secret" => app.client_secret
        })
        |> json_response(:ok)

      ap_id = user.ap_id

      assert match?(
               %{
                 "access_token" => _,
                 "expires_in" => 600,
                 "me" => ^ap_id,
                 "refresh_token" => _,
                 "scope" => "write",
                 "token_type" => "Bearer"
               },
               response
             )

      error_response =
        conn
        |> post("/oauth/mfa/challenge", %{
          "mfa_token" => mfa_token.token,
          "challenge_type" => "recovery",
          "code" => code,
          "client_id" => app.client_id,
          "client_secret" => app.client_secret
        })
        |> json_response(400)

      assert error_response == %{"error" => "Invalid code"}
    end
  end
end
