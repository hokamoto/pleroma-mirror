defmodule Pleroma.Web.MastodonApi.MastodonSocketTest do
  use Pleroma.Web.ChannelCase

  alias Pleroma.Web.{Streamer, CommonAPI}

  import Pleroma.Factory

  test "public is working when non-authenticated" do
    user = insert(:user)

    task =
      Task.async(fn ->
        assert_receive {:text, _}, 4_000
      end)

    fake_socket = %{
      transport_pid: task.pid,
      assigns: %{}
    }

    topics = %{
      "public" => [fake_socket]
    }

    {:ok, activity} = CommonAPI.post(user, %{"status" => "Test"})

    Streamer.push_to_socket(topics, "public", activity)

    Task.await(task)
  end

  describe "connect/2" do
    test "`connect` assigns a user and topic" do
      user = insert(:user)
      {:ok, %{token: token}} = Pleroma.Web.OAuth.Token.create_token(insert(:oauth_app), user)

      assert {:ok, socket} =
               Pleroma.Web.MastodonAPI.MastodonSocket.connect(
                 %{"access_token" => token, "stream" => "user"},
                 %Phoenix.Socket{}
               )

      assert socket.assigns.user == user
      assert socket.assigns.topic == "user"
    end
  end
end
