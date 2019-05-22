defmodule Pleroma.MultiFactorAuthentications.BackupCodesTest do
  use Pleroma.DataCase

  alias Pleroma.MultiFactorAuthentications.BackupCodes

  test "generate backup codes" do
    codes = BackupCodes.generate(number_of_codes: 2, code_length: 4)

    assert [<<_::bytes-size(4)>>, <<_::bytes-size(4)>>] = codes
  end
end
