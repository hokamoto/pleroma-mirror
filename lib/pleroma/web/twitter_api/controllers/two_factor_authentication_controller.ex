# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.TwitterAPI.TwoFactorAuthenticationController do
  @moduledoc "The module represents actions to manage 2FA/TOTP"
  use Pleroma.Web, :controller

  alias Comeonin.Pbkdf2
  alias Pleroma.User
  alias Pleroma.Web.Auth.TOTP
  alias Pleroma.Web.CommonAPI.Utils

  @doc """
  Generates secret key for 2FA and returns provisioning_uri to generate qr code.

  ## Endpoint
  GET /api/pleroma/2fa/provisioning_uri

  ## Response
  ### Success
  `{status: 'success', provisioning_uri: [uri], key: otp_secret_key }`

  ### Error
  `{error: [error_message]}`
  """
  def provisioning_uri(%{assigns: %{user: user}} = conn, _params) do
    with {:ok, %User{otp_secret: secret} = _} <- User.set_2fa_secret(user) do
      uri = TOTP.provisioning_uri(secret, "#{user.email}")
      json(conn, %{status: "success", provisioning_uri: uri, key: secret})
    else
      {:error, msg} ->
        json(conn, %{error: msg})
    end
  end

  @doc """
  Enables 2FA support for user account.

  ## Endpoint
  POST /api/pleroma/2fa/enable

  ## Required params
  `password` - current password of user
  `otp_token` - token from Google Auth. app

  ## Response
  ### Success
  `{status: 'success'}`

  ### Error
  `{error: [error_message]}`

  """
  def enable(%{assigns: %{user: user}} = conn, params) do
    with {:ok, user} <- Utils.confirm_current_password(user, params["password"]),
         {:ok, :pass} <- TOTP.validate_token(user.otp_secret, params["otp_token"]) do
      Pleroma.Async.start(fn -> User.enable_2fa(user) end)
      json(conn, %{status: "success"})
    else
      {:error, msg} ->
        json(conn, %{error: msg, status: "error"})
    end
  end

  @doc """
  Disables 2FA for user account.

  ## Endpoint
  POST /api/pleroma/2fa/disable

  ## Required params
  `password` - current password of user

  ## Response
  ### Success
  `{status: 'success'}`

  ### Error
  `{error: [error_message]}`

  """
  def disable(%{assigns: %{user: user}} = conn, params) do
    with {:ok, user} <- Utils.confirm_current_password(user, params["password"]) do
      Pleroma.Async.start(fn -> User.disable_2fa(user) end)
      json(conn, %{status: "success"})
    else
      {:error, msg} ->
        json(conn, %{error: msg})
    end
  end

  @doc """
  Generates backup codes for 2fa

  ## Endpoint
  GET /api/pleroma/2fa/backup_codes

  ## Response
  ### Success
  `{status: 'success', codes: [codes]}`

  ### Error
  `{error: [error_message]}`

  """
  def backup_codes(%{assigns: %{user: user}} = conn, _params) do
    with codes <- TOTP.generate_backup_codes(),
         hashed_codes <- Enum.map(codes, fn code -> Pbkdf2.hashpwsalt(code) end),
         {:ok, _user} <- User.update_2fa_backup_codes(user, hashed_codes) do
      json(conn, %{status: "success", codes: codes})
    else
      {:error, msg} ->
        json(conn, %{error: msg})
    end
  end
end
