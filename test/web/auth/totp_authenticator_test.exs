# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.Auth.TOTPAuthenticatorTest do
  use Pleroma.Web.ConnCase

  alias Pleroma.Web.Auth.TOTP
  alias Pleroma.Web.Auth.TOTPAuthenticator
  import Pleroma.Factory

  # setup_all do
  #   insert(:user)
  #   :ok
  # end

  test "verify token" do
    otp_secret = TOTP.generate_secret()
    otp_token = TOTP.generate_token(otp_secret)

    user =
      insert(:user,
        otp_enabled: true,
        otp_secret: otp_secret
      )

    assert TOTPAuthenticator.verify(otp_token, user) == {:ok, :pass}
    assert TOTPAuthenticator.verify(nil, user) == {:error, :invalid_token}
    assert TOTPAuthenticator.verify("", user) == {:error, :invalid_token}
  end

  test "checks backup codes" do
    [code | _] = backup_codes = Pleroma.Web.Auth.TOTP.generate_backup_codes()

    hashed_codes =
      backup_codes
      |> Enum.map(&Comeonin.Pbkdf2.hashpwsalt(&1))

    user =
      insert(:user,
        otp_enabled: true,
        otp_secret: "otp_secret",
        otp_backup_codes: hashed_codes
      )

    assert TOTPAuthenticator.verify(code, user) == {:ok, :pass}
    refute TOTPAuthenticator.verify(code, refresh_record(user)) == {:ok, :pass}
  end
end
