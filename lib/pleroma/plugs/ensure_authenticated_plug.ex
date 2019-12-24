# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Plugs.EnsureAuthenticatedPlug do
  import Plug.Conn
  import Pleroma.Web.TranslationHelpers
  alias Pleroma.User

  def init(options) do
    options
  end

  def call(
        %{
          assigns: %{
            auth_credentials: %{password: _},
            user: %User{multi_factor_authentication_settings: %{enabled: true}}
          }
        } = conn,
        _
      ) do
    conn
    |> render_error(:forbidden, "Two-factor authentication enabled, you must use a access token.")
    |> halt
  end

  def call(%{assigns: %{user: %User{}}} = conn, _), do: conn

  def call(conn, _) do
    conn
    |> render_error(:forbidden, "Invalid credentials.")
    |> halt
  end
end
