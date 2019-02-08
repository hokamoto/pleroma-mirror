# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.Auth.PleromaAuthenticator do
  alias Comeonin.Pbkdf2
  alias Pleroma.User

  import Pleroma.Web.Auth.Authenticator,
    only: [fetch_credentials: 1, fetch_user: 1]

  @behaviour Pleroma.Web.Auth.Authenticator

  def get_user(%Plug.Conn{} = conn) do
    with {:ok, {name, password}} <- fetch_credentials(conn),
         {_, %User{} = user} <- {:user, fetch_user(name)},
         {:ok, _user} <- {authenticate(user, password), user} do
      {:ok, user}
    else
      {:error, reason} -> {:error, reason}
      error -> {:error, error}
    end
  end

  def handle_error(%Plug.Conn{} = _conn, error) do
    error
  end

  def auth_template, do: nil

  def authenticate(%User{password_hash: hash} = _user, password) do
    if Pbkdf2.checkpw(password, hash) do
      :ok
    else
      :error
    end
  end
end
