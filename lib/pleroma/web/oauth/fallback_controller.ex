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

  def call(conn, {:register, :generic_error}) do
    conn
    |> put_status(:internal_server_error)
    |> put_flash(:error, "Unknown error, please check the details and try again.")
    |> OAuthController.registration_details(conn.params)
  end

  def call(conn, {:register, _error}) do
    conn
    |> put_status(:unauthorized)
    |> put_flash(:error, "Invalid Username/Password")
    |> OAuthController.registration_details(conn.params)
  end

  def call(conn, _error) do
    conn
    |> put_status(:unauthorized)
    |> put_flash(:error, "Invalid Username/Password")
    |> OAuthController.authorize(conn.params)
  end
end
