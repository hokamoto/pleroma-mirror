defmodule Pleroma.Web.Mfc.UtilsTest do
  use Pleroma.DataCase
  import Pleroma.Factory
  alias Pleroma.Web.Mfc.Utils

  describe "avatar updating" do
    test "for a user with no avatar, sets the new avatar" do
      user = insert(:user, avatar: nil)

      %{avatar: avatar} = Utils.maybe_update_avatar(user, ["https://new-url.com/image.", ".png"])

      assert avatar["source"] == "mfc"
      assert [%{"href" => "https://new-url.com/image.300x300.png"}] = avatar["url"]
    end

    test "for a user with non-mfc avatar, doesn't set the avatar" do
      avatar = %{
        "type" => "Image",
        "url" => [
          %{
            "type" => "Link",
            "href" => "https://example.com/image.png"
          }
        ]
      }

      user = insert(:user, avatar: avatar)

      %{avatar: new_avatar} =
        Utils.maybe_update_avatar(user, ["https://new-url.com/image.", ".png"])

      assert avatar == new_avatar
    end

    test "for a user with an mfc avatar, replaces the avatar" do
      avatar = %{
        "type" => "Image",
        "url" => [
          %{
            "type" => "Link",
            "href" => "https://example.com/image.png"
          }
        ],
        "source" => "mfc"
      }

      user = insert(:user, avatar: avatar)

      %{avatar: new_avatar} =
        Utils.maybe_update_avatar(user, ["https://new-url.com/image.", ".png"])

      assert new_avatar["source"] == "mfc"
      assert [%{"href" => "https://new-url.com/image.300x300.png"}] = new_avatar["url"]
    end
  end
end
