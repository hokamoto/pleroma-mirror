# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.Auth.TOTPAuthenticator do
  alias Comeonin.Pbkdf2
  alias Pleroma.User
  alias Pleroma.Web.Auth.TOTP

  @doc "Verify code or check backup code."
  @spec verify(String.t(), User.t()) :: {:ok, :pass} | {:error, :invalid_token} | {:error, any()}
  def verify(token, %User{otp_enabled: true, otp_secret: secret} = user) do
    with {:error, _} <- TOTP.validate_token(secret, token) do
      check_backup_code(user, token)
    end
  end

  def verify(_, _), do: {:error, :invalid_token}

  defp check_backup_code(%User{otp_backup_codes: codes} = user, code)
       when is_list(codes) do
    hash_code = Enum.find(codes, fn hash -> Pbkdf2.checkpw(code, hash) end)

    if hash_code do
      User.invalidate_2fa_backup_code(user, hash_code)
      {:ok, :pass}
    else
      {:error, :invalid_token}
    end
  end

  defp check_backup_code(_, _), do: {:error, :invalid_token}
end
