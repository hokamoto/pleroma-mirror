# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.OAuth.FallbackController do
  use Pleroma.Web, :controller
  alias Pleroma.Web.OAuth.OAuthController

  # Two-factor authentication step is failed."
  #
  def call(conn, {:error, :verify_2fa_failded}) do
    conn
    |> put_status(400)
    |> json(%{error_code: "2fa_failed", error: "Two-factor authentication failed."})
  end

  # login or password incorrect
  #
  def call(conn, {:error, :invalid_credentails}) do
    conn
    |> put_status(400)
    |> json(%{error_code: "invalid_credentails", error: "Invalid credentials"})
  end

  # No user/password
  def call(conn, _) do
    conn
    |> put_status(:unauthorized)
    |> put_flash(:error, "Invalid Username/Password")
    |> OAuthController.authorize(conn.params["authorization"])
  end
end
