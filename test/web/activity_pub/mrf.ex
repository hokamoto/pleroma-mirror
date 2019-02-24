defmodule Pleroma.Web.ActivityPub.MRFTest do
  use Pleroma.DataCase

  alias Pleroma.Web.ActivityPub.MRF

  test "that no random policy name can be accepted" do
    assert_raise ArgumentError, "Wrong MRF Policy name!", fn ->
      MRF.save_policy(%{policy: "Foobar42"})
    end
  end

  test "that each MRF policy is valid" do
    for name <- ["KeywordPolicy", "RejectNonPublic", "NormalizeMarkup", "HellThread", "Simple"] do
      assert {:ok, _} = MRF.save_policy(%{policy: name, data: %{}})
    end
  end
end
