defmodule Pleroma.Web.Mfc.ApiTest do
  use Pleroma.DataCase
  import Pleroma.Factory
  alias Pleroma.Web.Mfc.Api

  test "does a signed request" do
    data = %{x: 1, y: 2}
    url = Pleroma.Config.get([:mfc, :account_creation_endpoint])

    Tesla.Mock.mock(fn %{url: ^url, body: body} ->
      assert body =~ "x=1"
      assert body =~ "y=2"
      assert body =~ "gh="
      assert body =~ "service_id="
      assert body =~ "t="

      send(self(), :called_api)
      %Tesla.Env{status: 200}
    end)

    Api.authenticated_request(:post, url, data)

    assert_received(:called_api)
  end

  test "it fetches the users another user is following" do
    body =
      "{\"err\":0,\"data\":[{\"id\":372,\"nick\":\"Tenshi\",\"access_level\":1},{\"id\":18062,\"nick\":\"CornDogLover\",\"access_level\":1}]}"

    url = Pleroma.Config.get([:mfc, :following_endpoint_v2])

    Tesla.Mock.mock(fn %{url: ^url} ->
      %Tesla.Env{status: 200, body: body}
    end)

    user_ids = Api.get_following_for_mfc_id("123")

    assert "18062" in user_ids
    assert "372" in user_ids
  end

  test "it calls the account creation endpoint" do
    url = Pleroma.Config.get([:mfc, :account_creation_endpoint])
    user = insert(:user, %{mfc_id: "1"})
    expected_time = user.inserted_at |> DateTime.from_naive!("Etc/UTC") |> DateTime.to_unix()

    Tesla.Mock.mock(fn %{url: ^url, body: body} ->
      assert body =~ "mfc_id=1"

      assert body =~ "username=#{user.nickname}"

      assert body =~ "social_created_at=#{expected_time}"

      send(self(), :called_api)
      %Tesla.Env{status: 200}
    end)

    assert Pleroma.Web.Mfc.Api.notify_account_creation(user)
    assert_received(:called_api)
  end

  test "it calls the status creation endpoint" do
    url = Pleroma.Config.get([:mfc, :status_creation_endpoint])
    user = insert(:user, %{mfc_id: "1"})
    {:ok, activity} = Pleroma.Web.CommonAPI.post(user, %{"status" => "Hello"})

    expected_time = activity.inserted_at |> DateTime.from_naive!("Etc/UTC") |> DateTime.to_unix()

    Tesla.Mock.mock(fn %{url: ^url, body: body} ->
      assert body =~ "mfc_id=1"
      assert body =~ "last_post_date=#{expected_time}"
      assert body =~ "last_post_content=#{activity.data["object"]["content"]}"
      assert body =~ "status_count=1"
      assert body =~ "last_post_id=#{activity.id}"
      assert body =~ "last_post_url=#{URI.encode_www_form(activity.data["object"]["id"])}"
      send(self(), :called_api)

      %Tesla.Env{status: 200}
    end)

    assert Pleroma.Web.Mfc.Api.notify_status_creation(activity)
    assert_received(:called_api)

    {:ok, reply} = Pleroma.Web.CommonAPI.post(user, %{"status" => "Hello", "in_reply_to_status_id" => activity.id})
    Tesla.Mock.mock(fn %{url: ^url, body: body} ->
      assert body =~ "mfc_id=1"
      assert body =~ "status_count=2"
      assert body =~ "last_post_id=#{reply.id}"
      assert body =~ "in_reply_to_id=#{activity.id}"
      send(self(), :called_reply_api)

      %Tesla.Env{status: 200}
    end)

    assert Pleroma.Web.Mfc.Api.notify_status_creation(reply)
    assert_received(:called_reply_api)
  end
end
