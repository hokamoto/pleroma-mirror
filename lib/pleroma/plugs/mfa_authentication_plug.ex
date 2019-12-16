# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Plugs.MfaAuthenticationPlug do
  @moduledoc """
  The plug check otp code when using Basic Auth for api.
  otp code takes from `x-pleroma-otp` header.
  """

  alias Pleroma.User
  alias Pleroma.Web.Auth.TOTPAuthenticator

  import Pleroma.Web.TranslationHelpers, only: [render_error: 3]
  import Plug.Conn

  def init(options), do: options

  def call(
        %{
          assigns: %{
            user: %User{multi_factor_authentication_settings: %{enabled: true}} = user,
            auth_credentials: %{password: _} = _credentials
          }
        } = conn,
        _
      ) do
    with [code] when is_binary(code) <- get_req_header(conn, "x-pleroma-otp"),
         {:ok, _} <- TOTPAuthenticator.verify(code, user) do
      conn
    else
      _ ->
        conn
        |> render_error(401, "Must specify two-factor authentication OTP code.")
        |> halt
    end
  end

  def call(conn, _), do: conn
end
