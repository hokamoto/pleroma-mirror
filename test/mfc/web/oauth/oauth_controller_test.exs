# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.OAuth.OAuthControllerTest do
  use Pleroma.Test.MfcCase

  use Pleroma.Web.ConnCase
  import Pleroma.Factory

  alias Pleroma.Repo
  alias Pleroma.User
  alias Pleroma.Web.OAuth.Authorization

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
end
