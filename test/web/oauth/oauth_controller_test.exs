# Pleroma: A lightweight social networking server
# Copyright © 2017-2018 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.OAuth.OAuthControllerTest do
  use Pleroma.Web.ConnCase
  import Pleroma.Factory

  alias Pleroma.Repo
  alias Pleroma.Web.OAuth.Authorization
  alias Pleroma.Web.OAuth.Token

  test "redirects with oauth authorization" do
    user = insert(:user)
    app = insert(:oauth_app, scopes: ["read", "write", "follow"])

    conn =
      build_conn()
      |> post("/oauth/authorize", %{
        "authorization" => %{
          "name" => user.nickname,
          "password" => "test",
          "client_id" => app.client_id,
          "redirect_uri" => app.redirect_uris,
          "scope" => "read write",
          "state" => "statepassed"
        }
      })

    target = redirected_to(conn)
    assert target =~ app.redirect_uris

    query = URI.parse(target).query |> URI.query_decoder() |> Map.new()

    assert %{"state" => "statepassed", "code" => code} = query
    auth = Repo.get_by(Authorization, token: code)
    assert auth
    assert auth.scopes == ["read", "write"]
  end

  test "returns 401 for wrong credentials", %{conn: conn} do
    user = insert(:user)
    app = insert(:oauth_app)

    result =
      conn
      |> post("/oauth/authorize", %{
        "authorization" => %{
          "name" => user.nickname,
          "password" => "wrong",
          "client_id" => app.client_id,
          "redirect_uri" => app.redirect_uris,
          "state" => "statepassed",
          "scope" => Enum.join(app.scopes, " ")
        }
      })
      |> html_response(:unauthorized)

    # Keep the details
    assert result =~ app.client_id
    assert result =~ app.redirect_uris

    # Error message
    assert result =~ "Invalid Username/Password"
  end

  test "returns 401 for missing scopes", %{conn: conn} do
    user = insert(:user)
    app = insert(:oauth_app)

    result =
      conn
      |> post("/oauth/authorize", %{
        "authorization" => %{
          "name" => user.nickname,
          "password" => "test",
          "client_id" => app.client_id,
          "redirect_uri" => app.redirect_uris,
          "state" => "statepassed",
          "scope" => ""
        }
      })
      |> html_response(:unauthorized)

    # Keep the details
    assert result =~ app.client_id
    assert result =~ app.redirect_uris

    # Error message
    assert result =~ "Permissions not specified"
  end

  test "returns 401 for scopes beyond app scopes", %{conn: conn} do
    user = insert(:user)
    app = insert(:oauth_app, scopes: ["read", "write"])

    result =
      conn
      |> post("/oauth/authorize", %{
        "authorization" => %{
          "name" => user.nickname,
          "password" => "test",
          "client_id" => app.client_id,
          "redirect_uri" => app.redirect_uris,
          "state" => "statepassed",
          "scope" => "read write follow"
        }
      })
      |> html_response(:unauthorized)

    # Keep the details
    assert result =~ app.client_id
    assert result =~ app.redirect_uris

    # Error message
    assert result =~ "Permissions not specified"
  end

  test "issues a token for an all-body request" do
    user = insert(:user)
    app = insert(:oauth_app, scopes: ["read", "write"])

    {:ok, auth} = Authorization.create_authorization(app, user, ["write"])

    conn =
      build_conn()
      |> post("/oauth/token", %{
        "grant_type" => "authorization_code",
        "code" => auth.token,
        "redirect_uri" => app.redirect_uris,
        "client_id" => app.client_id,
        "client_secret" => app.client_secret
      })

    assert %{"access_token" => token} = json_response(conn, 200)

    token = Repo.get_by(Token, token: token)
    assert token
    assert token.scopes == auth.scopes
  end

  test "issues a token for `password` grant_type with valid credentials, with full permissions by default" do
    password = "testpassword"
    user = insert(:user, password_hash: Comeonin.Pbkdf2.hashpwsalt(password))

    app = insert(:oauth_app, scopes: ["read", "write"])

    # Note: "scope" param is intentionally omitted
    conn =
      build_conn()
      |> post("/oauth/token", %{
        "grant_type" => "password",
        "username" => user.nickname,
        "password" => password,
        "client_id" => app.client_id,
        "client_secret" => app.client_secret
      })

    assert %{"access_token" => token} = json_response(conn, 200)

    token = Repo.get_by(Token, token: token)
    assert token
    assert token.scopes == app.scopes
  end

  test "issues a token for request with HTTP basic auth client credentials" do
    user = insert(:user)
    app = insert(:oauth_app, scopes: ["scope1", "scope2"])

    {:ok, auth} = Authorization.create_authorization(app, user, ["scope2"])
    assert auth.scopes == ["scope2"]

    app_encoded =
      (URI.encode_www_form(app.client_id) <> ":" <> URI.encode_www_form(app.client_secret))
      |> Base.encode64()

    conn =
      build_conn()
      |> put_req_header("authorization", "Basic " <> app_encoded)
      |> post("/oauth/token", %{
        "grant_type" => "authorization_code",
        "code" => auth.token,
        "redirect_uri" => app.redirect_uris
      })

    assert %{"access_token" => token} = json_response(conn, 200)

    token = Repo.get_by(Token, token: token)
    assert token
    assert token.scopes == ["scope2"]
  end

  test "rejects token exchange with invalid client credentials" do
    user = insert(:user)
    app = insert(:oauth_app)

    {:ok, auth} = Authorization.create_authorization(app, user)

    conn =
      build_conn()
      |> put_req_header("authorization", "Basic JTIxOiVGMCU5RiVBNCVCNwo=")
      |> post("/oauth/token", %{
        "grant_type" => "authorization_code",
        "code" => auth.token,
        "redirect_uri" => app.redirect_uris
      })

    assert resp = json_response(conn, 400)
    assert %{"error" => _} = resp
    refute Map.has_key?(resp, "access_token")
  end

  test "rejects token exchange for valid credentials belonging to unconfirmed user and confirmation is required" do
    setting = Pleroma.Config.get([:instance, :account_activation_required])

    unless setting do
      Pleroma.Config.put([:instance, :account_activation_required], true)
      on_exit(fn -> Pleroma.Config.put([:instance, :account_activation_required], setting) end)
    end

    password = "testpassword"
    user = insert(:user, password_hash: Comeonin.Pbkdf2.hashpwsalt(password))
    info_change = Pleroma.User.Info.confirmation_changeset(user.info, :unconfirmed)

    {:ok, user} =
      user
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_embed(:info, info_change)
      |> Repo.update()

    refute Pleroma.User.auth_active?(user)

    app = insert(:oauth_app)

    conn =
      build_conn()
      |> post("/oauth/token", %{
        "grant_type" => "password",
        "username" => user.nickname,
        "password" => password,
        "client_id" => app.client_id,
        "client_secret" => app.client_secret
      })

    assert resp = json_response(conn, 403)
    assert %{"error" => _} = resp
    refute Map.has_key?(resp, "access_token")
  end

  test "rejects an invalid authorization code" do
    app = insert(:oauth_app)

    conn =
      build_conn()
      |> post("/oauth/token", %{
        "grant_type" => "authorization_code",
        "code" => "Imobviouslyinvalid",
        "redirect_uri" => app.redirect_uris,
        "client_id" => app.client_id,
        "client_secret" => app.client_secret
      })

    assert resp = json_response(conn, 400)
    assert %{"error" => _} = json_response(conn, 400)
    refute Map.has_key?(resp, "access_token")
  end
end
