defmodule Pleroma.Web.StreamerTest do
  use Pleroma.DataCase

  alias Pleroma.Web.Streamer
  alias Pleroma.User
  alias Pleroma.Web.CommonAPI
  import Pleroma.Factory

  defp create_sender_recipient() do
    with object <- direct_note_factory(),
         %{data: %{"actor" => actor_id, "to" => [recipient_id | _]}} <- object,
         sender <- User.get_by_ap_id(actor_id),
         recipient <- User.get_by_ap_id(recipient_id) do
      %{sender: sender, recipient: recipient, object: object}
    end
  end

  test "it sends direct messages" do
    %{sender: sender, recipient: recipient, object: object} = create_sender_recipient()

    task =
      Task.async(fn ->
        assert_receive {:text, _}, 4_000
      end)

    fake_socket = %{
      transport_pid: task.pid,
      assigns: %{
        user: recipient
      }
    }

    {:ok, activity} = CommonAPI.post(sender, %{"status" => "Test", "data" => object})

    direct_topic = "direct:#{recipient.id}"
    topics = %{direct_topic => [fake_socket]}

    Streamer.push_to_socket(topics, direct_topic, activity)

    Task.await(task)
  end

  test "it sends to public" do
    user = insert(:user)
    other_user = insert(:user)

    task =
      Task.async(fn ->
        assert_receive {:text, _}, 4_000
      end)

    fake_socket = %{
      transport_pid: task.pid,
      assigns: %{
        user: user
      }
    }

    {:ok, activity} = CommonAPI.post(other_user, %{"status" => "Test"})

    topics = %{
      "public" => [fake_socket]
    }

    Streamer.push_to_socket(topics, "public", activity)

    Task.await(task)
  end

  test "it doesn't send to blocked users" do
    user = insert(:user)
    blocked_user = insert(:user)
    {:ok, user} = User.block(user, blocked_user)

    task =
      Task.async(fn ->
        refute_receive {:text, _}, 1_000
      end)

    fake_socket = %{
      transport_pid: task.pid,
      assigns: %{
        user: user
      }
    }

    {:ok, activity} = CommonAPI.post(blocked_user, %{"status" => "Test"})

    topics = %{
      "public" => [fake_socket]
    }

    Streamer.push_to_socket(topics, "public", activity)

    Task.await(task)
  end
end
