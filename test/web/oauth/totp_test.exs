defmodule Pleroma.Web.Auth.TOTPTest do
  use Pleroma.DataCase
  alias Pleroma.Web.Auth.TOTP

  test "create provisioning_uri to generate qrcode" do
    uri =
      TOTP.provisioning_uri("test-secrcet", "test@example.com",
        issuer: "Plerome-42",
        digits: 8,
        period: 60
      )

    assert uri ==
             "otpauth://totp/test@example.com?digits=8&issuer=Plerome-42&period=60&secret=test-secrcet"
  end

  test "generate backup codes" do
    codes = TOTP.generate_backup_codes(number_of_codes: 2, code_length: 4)

    assert [<<_::bytes-size(4)>>, <<_::bytes-size(4)>>] = codes
  end
end
