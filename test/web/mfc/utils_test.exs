defmodule Pleroma.Web.Mfc.UtilsTest do
  use Pleroma.DataCase
  import Pleroma.Factory
  alias Pleroma.Repo
  alias Pleroma.User
  alias Pleroma.Web.Mfc.Utils

  describe "model online status" do
    test "it pulls the state form the web and sets the online state for the model" do
      user = insert(:user, %{mfc_id: "1"})
      online_model = insert(:user, %{mfc_id: "2", nickname: "AnnaLove7"})
      online_model_two = insert(:user, %{mfc_id: "4", nickname: "MadelinLove"})

      offline_model =
        insert(:user, %{mfc_id: "3", nickname: "Erica_grey", info: %{mfc_model_online: true}})

      fixture = File.read!("test/fixtures/online_models")
      models_state_url = Pleroma.Config.get([:mfc, :models_state_endpoint])

      Tesla.Mock.mock(fn
        %{url: ^models_state_url} ->
          {:ok, %Tesla.Env{status: 200, body: fixture}}
      end)

      Utils.update_online_status()

      assert Utils.model_online?(Repo.get(User, user.id)) == false
      assert Utils.model_online?(Repo.get(User, online_model.id)) == true
      assert Utils.model_online?(Repo.get(User, online_model_two.id)) == true
      assert Utils.model_online?(Repo.get(User, offline_model.id)) == false
    end
  end

  describe "user following synchronization" do
    test "for a user with friends and bookmarks, it follows them" do
      user = insert(:user, %{mfc_id: "1"})
      friend_user = insert(:user, %{mfc_id: "2"})
      bookmark_user = insert(:user, %{mfc_id: "3"})
      following_user = insert(:user, %{mfc_id: "4"})
      non_followed_user = insert(:user, %{mfc_id: "5"})
      twitter_friend_user = insert(:user, %{mfc_id: "6"})

      friends_url = "#{Pleroma.Config.get([:mfc, :friends_endpoint])}/1"
      twitter_friends_url = "#{Pleroma.Config.get([:mfc, :twitter_friends_endpoint])}/1"
      bookmarks_url = "#{Pleroma.Config.get([:mfc, :bookmarks_endpoint])}/1"
      following_url = "#{Pleroma.Config.get([:mfc, :following_endpoint_v2])}"

      Tesla.Mock.mock(fn
        %{url: ^twitter_friends_url} ->
          %Tesla.Env{
            status: 200,
            body: Jason.encode!(%{err: 0, data: [%{following_id: 6}]})
          }

        %{url: ^friends_url} ->
          %Tesla.Env{
            status: 200,
            body: Jason.encode!(%{err: 0, data: [%{id: 2}]})
          }

        %{url: ^bookmarks_url} ->
          %Tesla.Env{
            status: 200,
            body: Jason.encode!(%{err: 0, data: [%{id: 3}]})
          }

        %{url: ^following_url} ->
          %Tesla.Env{
            status: 200,
            body: Jason.encode!(%{err: 0, data: [%{id: 4}]})
          }
      end)

      # Does nothing if user.info.mfc_follower_sync is false
      Utils.sync_follows(%User{user | info: %{user.info | mfc_follower_sync: false}})
      user = Repo.get(User, user.id)

      refute User.following?(user, friend_user)
      refute User.following?(user, twitter_friend_user)
      refute User.following?(user, bookmark_user)
      refute User.following?(user, following_user)
      refute User.following?(user, non_followed_user)

      Utils.sync_follows(user)

      user = Repo.get(User, user.id)

      assert User.following?(user, friend_user)
      assert User.following?(user, twitter_friend_user)
      assert User.following?(user, bookmark_user)
      assert User.following?(user, following_user)
      refute User.following?(user, non_followed_user)
    end

    test "it works if the endpoints return 404" do
      user = insert(:user, %{mfc_id: "1"})
      friend_user = insert(:user, %{mfc_id: "2"})

      friends_url = "#{Pleroma.Config.get([:mfc, :friends_endpoint])}/1"
      twitter_friends_url = "#{Pleroma.Config.get([:mfc, :twitter_friends_endpoint])}/1"
      bookmarks_url = "#{Pleroma.Config.get([:mfc, :bookmarks_endpoint])}/1"
      following_url = "#{Pleroma.Config.get([:mfc, :following_endpoint_v2])}"

      Tesla.Mock.mock(fn
        %{url: ^twitter_friends_url} ->
          %Tesla.Env{
            status: 200,
            body: Jason.encode!(%{err: 0, data: [%{id: 2}]})
          }

        %{url: ^friends_url} ->
          %Tesla.Env{
            status: 200,
            body: Jason.encode!(%{err: 0, data: [%{id: 2}]})
          }

        %{url: ^bookmarks_url} ->
          %Tesla.Env{
            status: 404,
            body: Jason.encode!(%{code: "file_not_found", message: "File not found."})
          }

        %{url: ^following_url} ->
          %Tesla.Env{
            status: 200,
            body: Jason.encode!(%{err: 0, data: []})
          }
      end)

      Utils.sync_follows(user)

      user = Repo.get(User, user.id)

      assert User.following?(user, friend_user)
    end

    test "it works with `since` parameter" do
      user = insert(:user, %{mfc_id: "1"})
      friend_user = insert(:user, %{mfc_id: "2"})
      bookmark_user = insert(:user, %{mfc_id: "3"})
      following_user = insert(:user, %{mfc_id: "4"})
      non_followed_user = insert(:user, %{mfc_id: "5"})
      twitter_friend_user = insert(:user, %{mfc_id: "6"})

      friends_url = "#{Pleroma.Config.get([:mfc, :friends_endpoint])}/1"
      twitter_friends_url = "#{Pleroma.Config.get([:mfc, :twitter_friends_endpoint])}/1"
      bookmarks_url = "#{Pleroma.Config.get([:mfc, :bookmarks_endpoint])}/1"
      following_url = "#{Pleroma.Config.get([:mfc, :following_endpoint_v2])}"

      time =
        DateTime.utc_now()
        |> DateTime.to_unix()
        |> to_string()

      Tesla.Mock.mock(fn
        %{url: ^twitter_friends_url} = req ->
          assert req.query.since

          %Tesla.Env{
            status: 200,
            body: Jason.encode!(%{err: 0, data: [%{following_id: 6}]})
          }

        %{url: ^friends_url} = req ->
          assert req.query.since

          %Tesla.Env{
            status: 200,
            body: Jason.encode!(%{err: 0, data: [%{id: 2}]})
          }

        %{url: ^bookmarks_url} = req ->
          assert req.query.since

          %Tesla.Env{
            status: 200,
            body: Jason.encode!(%{err: 0, data: [%{id: 3}]})
          }

        %{url: ^following_url} = req ->
          assert req.query.since

          %Tesla.Env{
            status: 200,
            body: Jason.encode!(%{err: 0, data: [%{id: 4}]})
          }
      end)

      Utils.sync_follows(user, %{since: time})

      user = Repo.get(User, user.id)

      assert User.following?(user, friend_user)
      assert User.following?(user, twitter_friend_user)
      assert User.following?(user, bookmark_user)
      assert User.following?(user, following_user)
      refute User.following?(user, non_followed_user)
    end
  end

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
