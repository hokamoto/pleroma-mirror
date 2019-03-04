# Pleroma: A lightweight social networking server
# Copyright © 2017-2018 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.OAuth.OAuthControllerTest do
  use Pleroma.Web.ConnCase
  import Pleroma.Factory

  alias Pleroma.Repo
  alias Pleroma.User
  alias Pleroma.Web.OAuth.Authorization
  alias Pleroma.Web.OAuth.Token

  import Mock

  test "redirects with oauth authorization, calling the MFC login" do
    user = insert(:user, %{mfc_id: "1234"})
    app = insert(:oauth_app, scopes: ["read", "write", "follow"])
    nickname = user.nickname

    with_mocks [
      {Pleroma.Web.Mfc.Utils, [:passthrough], [sync_follows: fn x -> x end]},
      {Pleroma.Web.Mfc.Login, [],
       [
         authenticate: fn ^nickname, "test", _ip ->
           {:ok,
            %{
              "user_id" => 1234,
              "access_level" => 2,
              "avatar_url" => false,
              "username" => "lain"
            }}
         end
       ]}
    ] do
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
  end

  test "With an access level below the minimum, don't allow access" do
    user = insert(:user, %{mfc_id: "1234"})
    app = insert(:oauth_app)
    nickname = user.nickname

    with_mock Pleroma.Web.Mfc.Login,
      authenticate: fn ^nickname, "test", _ip ->
        {:ok,
         %{
           "user_id" => 1234,
           "access_level" => 1,
           "avatar_url" => false,
           "username" => "lain"
         }}
      end do
      conn =
        build_conn()
        |> post("/oauth/authorize", %{
          "authorization" => %{
            "name" => user.nickname,
            "password" => "test",
            "client_id" => app.client_id,
            "redirect_uri" => app.redirect_uris,
            "state" => "statepassed"
          }
        })

      assert html_response(conn, 200) =~ "Premium"
    end
  end

  test "without a user, calls MFC for auth and creates a user (level 2)" do
    app = insert(:oauth_app)

    with_mocks [
      {Pleroma.Web.Mfc.Utils, [:passthrough], [sync_follows: fn x -> x end]},
      {Pleroma.Web.Mfc.Login, [],
       [
         authenticate: fn "lain", "test", _ip ->
           {:ok,
            %{
              "user_id" => 1234,
              "access_level" => 2,
              "avatar_url" => [
                "https://img.mfcimg.com/photos2/300/30004271/avatar.",
                ".jpg?nc=1541675948"
              ],
              "username" => "lain"
            }}
         end
       ]}
    ] do
      conn =
        build_conn()
        |> post("/oauth/authorize", %{
          "authorization" => %{
            "name" => "lain",
            "password" => "test",
            "client_id" => app.client_id,
            "redirect_uri" => app.redirect_uris,
            "scope" => Enum.join(app.scopes, " "),
            "state" => "statepassed"
          }
        })

      target = redirected_to(conn)
      assert target =~ app.redirect_uris

      query = URI.parse(target).query |> URI.query_decoder() |> Map.new()

      assert %{"state" => "statepassed", "code" => code} = query
      assert Repo.get_by(Authorization, token: code)
      assert user = Repo.get_by(User, nickname: "lain", mfc_id: "1234")

      assert User.avatar_url(user) ==
               "https://img.mfcimg.com/photos2/300/30004271/avatar.300x300.jpg?nc=1541675948"

      assert user.avatar["source"] == "mfc"
      assert "mfc_premium_member" in user.tags
    end
  end

  test "without a user, calls MFC for auth and creates a user (level 4)" do
    app = insert(:oauth_app)

    with_mocks [
      {Pleroma.Web.Mfc.Utils, [:passthrough], [sync_follows: fn x -> x end]},
      {Pleroma.Web.Mfc.Login, [],
       [
         authenticate: fn "lain", "test", _ip ->
           {:ok,
            %{
              "user_id" => 1234,
              "access_level" => 4,
              "avatar_url" => [
                "https://img.mfcimg.com/photos2/300/30004271/avatar.",
                ".jpg?nc=1541675948"
              ],
              "username" => "lain"
            }}
         end
       ]}
    ] do
      conn =
        build_conn()
        |> post("/oauth/authorize", %{
          "authorization" => %{
            "name" => "lain",
            "password" => "test",
            "client_id" => app.client_id,
            "redirect_uri" => app.redirect_uris,
            "scope" => Enum.join(app.scopes, " "),
            "state" => "statepassed"
          }
        })

      target = redirected_to(conn)
      assert target =~ app.redirect_uris

      query = URI.parse(target).query |> URI.query_decoder() |> Map.new()

      assert %{"state" => "statepassed", "code" => code} = query
      assert Repo.get_by(Authorization, token: code)
      assert user = Repo.get_by(User, nickname: "lain", mfc_id: "1234")

      assert User.avatar_url(user) ==
               "https://img.mfcimg.com/photos2/300/30004271/avatar.300x300.jpg?nc=1541675948"

      assert user.avatar["source"] == "mfc"
      assert "mfc_model" in user.tags
    end
  end

  # # Deactivated because we enforce the nickname now
  # test "without a user, but given a nickname, authorizes" do
  #   app = insert(:oauth_app)

  #   with_mock Pleroma.Web.Mfc.Login,
  #     authenticate: fn "lain", "test" ->
  #       {:ok,
  #        %{
  #          "user_id" => 1234,
  #          "access_level" => 2,
  #          "avatar_url" => false,
  #          "username" => "lain"
  #        }}
  #     end do
  #     conn =
  #       build_conn()
  #       |> post("/oauth/authorize", %{
  #         "authorization" => %{
  #           "name" => "lain",
  #           "password" => "test",
  #           "client_id" => app.client_id,
  #           "redirect_uri" => app.redirect_uris,
  #           "state" => "statepassed",
  #           "nickname" => "lain"
  #         }
  #       })

  #     target = redirected_to(conn)
  #     assert target =~ app.redirect_uris

  #     query = URI.parse(target).query |> URI.query_decoder() |> Map.new()

  #     assert %{"state" => "statepassed", "code" => code} = query
  #     assert Repo.get_by(Authorization, token: code)
  #   end
  # end

  test "returns 401 for wrong credentials", %{conn: conn} do
    user = insert(:user)
    app = insert(:oauth_app)

    with_mocks [
      {Pleroma.Web.Mfc.Login, [],
       [
         authenticate: fn _nickname, _password, _ip ->
           {:error, "I made an oopsy whoopsy"}
         end
       ]}
    ] do
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
  end

  test "renders auth page with error on missing scopes", %{conn: conn} do
    user = insert(:user)
    app = insert(:oauth_app)
    nickname = user.nickname

    with_mocks [
      {Pleroma.Web.Mfc.Utils, [:passthrough], [sync_follows: fn x -> x end]},
      {Pleroma.Web.Mfc.Login, [],
       [
         authenticate: fn ^nickname, "test", _ip ->
           {:ok,
            %{
              "user_id" => 1234,
              "access_level" => 2,
              "avatar_url" => false,
              "username" => "lain"
            }}
         end
       ]}
    ] do
      conn =
        post(conn, "/oauth/authorize", %{
          "authorization" => %{
            "name" => user.nickname,
            "password" => "test",
            "client_id" => app.client_id,
            "redirect_uri" => app.redirect_uris,
            "state" => "statepassed",
            "scope" => ""
          }
        })

      assert html_response(conn, 401) =~ "Permissions not specified."
    end
  end

  test "renders auth page with error if requested scopes are beyond app scopes", %{conn: conn} do
    user = insert(:user)
    app = insert(:oauth_app, scopes: ["read", "write"])
    nickname = user.nickname

    with_mocks [
      {Pleroma.Web.Mfc.Utils, [:passthrough], [sync_follows: fn x -> x end]},
      {Pleroma.Web.Mfc.Login, [],
       [
         authenticate: fn ^nickname, "test", _ip ->
           {:ok,
            %{
              "user_id" => 1234,
              "access_level" => 2,
              "avatar_url" => false,
              "username" => "lain"
            }}
         end
       ]}
    ] do
      conn =
        post(conn, "/oauth/authorize", %{
          "authorization" => %{
            "name" => user.nickname,
            "password" => "test",
            "client_id" => app.client_id,
            "redirect_uri" => app.redirect_uris,
            "state" => "statepassed",
            "scope" => "read write follow"
          }
        })

      assert html_response(conn, 401) =~ "Permissions not specified."
    end
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
    app = insert(:oauth_app, scopes: ["scope1", "scope2", "scope3"])

    {:ok, auth} = Authorization.create_authorization(app, user, ["scope1", "scope2"])
    assert auth.scopes == ["scope1", "scope2"]

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

    assert %{"access_token" => token, "scope" => scope} = json_response(conn, 200)

    assert scope == "scope1 scope2"

    token = Repo.get_by(Token, token: token)
    assert token
    assert token.scopes == ["scope1", "scope2"]
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
