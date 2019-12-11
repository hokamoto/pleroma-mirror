# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.TwitterAPI.TwoFactorAuthenticationController do
  @moduledoc "The module represents actions to manage MFA"
  use Pleroma.Web, :controller

  alias Pleroma.MFA
  alias Pleroma.MFA.TOTP
  alias Pleroma.Plugs.OAuthScopesPlug
  alias Pleroma.Web.CommonAPI.Utils

  plug(OAuthScopesPlug, %{scopes: ["write:accounts"]})

  @doc """
  Gets user multi factor authentication settings

  ## Endpoint
  GET /api/pleroma/account/mfa

  """
  def settings(%{assigns: %{user: user}} = conn, _params) do
    json(conn, %{settings: MFA.mfa_settings(user)})
  end

  @doc """
  Prepare setup mfa method

  ## Endpoint
  GET /api/pleroma/account/mfa/setup/[:method]

  """
  def setup(%{assigns: %{user: user}} = conn, %{"method" => "totp"} = _params) do
    with {:ok, user} <- MFA.setup_totp(user),
         %{secret: secret} = _ <- user.multi_factor_authentication_settings.totp do
      provisioning_uri = TOTP.provisioning_uri(secret, "#{user.email}")

      json(
        conn,
        %{status: "success", provisioning_uri: provisioning_uri, key: secret}
      )
    else
      {:error, msg} ->
        json(conn, %{error: msg, status: "error"})
    end
  end

  def setup(conn, _params), do: json(conn, %{error: "undefined method"})

  @doc """
  Confirms setup and enable mfa method

  ## Endpoint
  POST /api/pleroma/account/mfa/confirm/:method

  - params:
  `code` - confirmation code
  `password` - current password
  """
  def confirm(
        %{assigns: %{user: user}} = conn,
        %{"method" => "totp", "password" => _, "code" => _} = params
      ) do
    with {:ok, _user} <- Utils.confirm_current_password(user, params["password"]),
         {:ok, _user} <- MFA.confirm_totp(user, params) do
      json(conn, %{status: "success"})
    else
      {:error, msg} ->
        conn
        |> json(%{error: msg, status: "error"})
    end
  end

  def confirm(conn, _params), do: json(conn, %{error: "undefined mfa method"})

  @doc """
  Disable mfa method and disable mfa if need.
  """
  def disable(%{assigns: %{user: user}} = conn, %{"method" => "totp"} = params) do
    with {:ok, user} <- Utils.confirm_current_password(user, params["password"]),
         {:ok, _user} <- MFA.disable_totp(user) do
      json(conn, %{status: "success"})
    else
      {:error, msg} ->
        json(conn, %{error: msg})
    end
  end

  def disable(%{assigns: %{user: user}} = conn, %{"method" => "mfa"} = params) do
    with {:ok, user} <- Utils.confirm_current_password(user, params["password"]),
         {:ok, _user} <- MFA.disable(user) do
      json(conn, %{status: "success"})
    else
      {:error, msg} ->
        json(conn, %{error: msg})
    end
  end

  def disable(conn, _params), do: json(conn, %{error: "undefined mfa method"})

  @doc """
  Generates backup codes.

  ## Endpoint
  GET /api/pleroma/mfa/backup_codes

  ## Response
  ### Success
  `{status: 'success', codes: [codes]}`

  ### Error
  `{error: [error_message]}`

  """
  def backup_codes(%{assigns: %{user: user}} = conn, _params) do
    with {:ok, codes} <- MFA.generate_backup_codes(user) do
      json(conn, %{status: "success", codes: codes})
    else
      {:error, msg} ->
        json(conn, %{error: msg})
    end
  end
end
