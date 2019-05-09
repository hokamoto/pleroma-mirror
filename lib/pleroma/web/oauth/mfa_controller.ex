# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.OAuth.MFAController do
  use Pleroma.Web, :controller

  alias Pleroma.MultiFactorAuthentications, as: MFA
  alias Pleroma.Web.Auth.TOTPAuthenticator
  alias Pleroma.Web.OAuth.Authorization
  alias Pleroma.Web.OAuth.Token

  @moduledoc """
  The model represents api to use Multi Factor authentications.
  """

  @expires_in Pleroma.Config.get([:oauth2, :token_expires_in], 600)

  @doc """
  client_id
  client_secret
  mfa_token

  challenge_type
  code
  """
  def challenge(conn, %{"mfa_token" => mfa_token} = params) do
    with {:ok, app} <- Token.Utils.fetch_app(conn),
         {:ok, %{user: user, scopes: scopes}} <- MFA.Token.validate(mfa_token),
         {:ok, _} <- validates_challenge(user, params),
         {:ok, auth} <- Authorization.create_authorization(app, user, scopes),
         {:ok, token} <- Token.exchange_token(app, auth) do
      response = %{
        token_type: "Bearer",
        access_token: token.token,
        refresh_token: token.refresh_token,
        expires_in: @expires_in,
        scope: Enum.join(token.scopes, " "),
        me: user.ap_id
      }

      json(conn, response)
    end
  end

  defp validates_challenge(user, %{"challenge_type" => "totp", "code" => code} = _) do
    TOTPAuthenticator.verify(code, user)
  end

  defp validates_challenge(user, %{"challenge_type" => "recovery_code", "code" => code} = _) do
    TOTPAuthenticator.verify_recovery_code(user, code)
  end

  defp validates_challenge(_, _), do: {:error, :unsupported_challenge_type}
end
