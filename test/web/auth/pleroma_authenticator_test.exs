# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.Auth.PleromaAuthenticatorTest do
  use Pleroma.Web.ConnCase

  alias Pleroma.Web.Auth.PleromaAuthenticator
  import Pleroma.Factory

  setup_all do
    :ok
  end

  test "get_user/authorization" do
    password = "testpassword"
    name = "AgentSmith"
    user = insert(:user, nickname: name, password_hash: Comeonin.Pbkdf2.hashpwsalt(password))
    params = %{"authorization" => %{"name" => name, "password" => password}}
    res = PleromaAuthenticator.get_user(%Plug.Conn{params: params}, params)

    assert {:ok, user} == res
  end

  test "get_user/authorization with invalid password" do
    password = "testpassword"
    name = "AgentSmith"
    user = insert(:user, nickname: name, password_hash: Comeonin.Pbkdf2.hashpwsalt(password))
    params = %{"authorization" => %{"name" => name, "password" => "password"}}
    res = PleromaAuthenticator.get_user(%Plug.Conn{params: params}, params)

    assert {:error, user} == res
  end

  test "get_user/grant_type_password" do
    password = "testpassword"
    name = "AgentSmith"
    user = insert(:user, nickname: name, password_hash: Comeonin.Pbkdf2.hashpwsalt(password))
    params = %{"grant_type" => "password", "username" => name, "password" => password}
    res = PleromaAuthenticator.get_user(%Plug.Conn{params: params}, params)

    assert {:ok, user} == res
  end

  test "error credintails" do
    password = "testpassword"
    name = "AgentSmith"
    _user = insert(:user, nickname: name, password_hash: Comeonin.Pbkdf2.hashpwsalt(password))
    res = PleromaAuthenticator.get_user(%Plug.Conn{params: %{}}, %{})
    assert {:error, :invalid_credentials} == res
  end
end
