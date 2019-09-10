# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule PleromaWeb.Streamer do
  use GenServer
  require Logger
  alias Pleroma.Activity
  alias Pleroma.Config
  alias Pleroma.Conversation.Participation
  alias Pleroma.Notification
  alias Pleroma.Object
  alias Pleroma.User
  alias Pleroma.Web.ActivityPub.ActivityPub
  alias Pleroma.Web.ActivityPub.Visibility
  alias Pleroma.Web.CommonAPI
  alias Pleroma.Web.MastodonAPI.NotificationView
  alias PleromaWeb.Streamer.State
  alias PleromaWeb.Streamer.StreamerSocket

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def add_socket(topic, socket) do
    State.add_socket(topic, socket)
  end

  def remove_socket(topic, socket) do
    State.remove_socket(topic, socket)
  end

  def get_sockets() do
    State.get_sockets()
  end

  def stream(topics, item) when is_list(topics) do
    Enum.each(topics, fn t ->
      GenServer.cast(__MODULE__, %{action: :stream, topic: t, item: item})
    end)
  end

  def stream(topic, items) when is_list(items) do
    Enum.each(items, fn i ->
      GenServer.cast(__MODULE__, %{action: :stream, topic: topic, item: i})
    end)
  end

  def stream(topic, item) do
    GenServer.cast(__MODULE__, %{action: :stream, topic: topic, item: item})
  end

  def supervisor, do: PleromaWeb.Streamer.Supervisor

  def init(args) do
    {:ok, args}
  end

  def handle_cast(%{action: :stream, topic: "direct", item: item}, state) do
    recipient_topics =
      User.get_recipients_from_activity(item)
      |> Enum.map(fn %{id: id} -> "direct:#{id}" end)

    Enum.each(recipient_topics || [], fn user_topic ->
      Logger.debug("Trying to push direct message to #{user_topic}\n\n")
      push_to_socket(State.get_sockets(), user_topic, item)
    end)

    {:noreply, state}
  end

  def handle_cast(%{action: :stream, topic: "participation", item: participation}, state) do
    user_topic = "direct:#{participation.user_id}"
    Logger.debug("Trying to push a conversation participation to #{user_topic}\n\n")

    push_to_socket(State.get_sockets(), user_topic, participation)

    {:noreply, state}
  end

  def handle_cast(%{action: :stream, topic: "list", item: item}, state) do
    # filter the recipient list if the activity is not public, see #270.
    recipient_lists =
      case Visibility.is_public?(item) do
        true ->
          Pleroma.List.get_lists_from_activity(item)

        _ ->
          Pleroma.List.get_lists_from_activity(item)
          |> Enum.filter(fn list ->
            owner = User.get_cached_by_id(list.user_id)

            Visibility.visible_for_user?(item, owner)
          end)
      end

    recipient_topics =
      recipient_lists
      |> Enum.map(fn %{id: id} -> "list:#{id}" end)

    Enum.each(recipient_topics || [], fn list_topic ->
      Logger.debug("Trying to push message to #{list_topic}\n\n")
      push_to_socket(State.get_sockets(), list_topic, item)
    end)

    {:noreply, state}
  end

  def handle_cast(
        %{action: :stream, topic: topic, item: %Notification{} = item},
        state
      )
      when topic in ["user", "user:notification"] do
    State.get_sockets()
    |> Map.get("#{topic}:#{item.user_id}", [])
    |> Enum.each(fn %StreamerSocket{transport_pid: transport_pid, user: socket_user} ->
      with %User{} = user <- User.get_cached_by_ap_id(socket_user.ap_id),
           true <- should_send?(user, item) do
        send(transport_pid, {:text, represent_notification(socket_user, item)})
      end
    end)

    {:noreply, state}
  end

  def handle_cast(%{action: :stream, topic: "user", item: item}, state) do
    Logger.debug("Trying to push to users")

    recipient_topics =
      User.get_recipients_from_activity(item)
      |> Enum.map(fn %{id: id} -> "user:#{id}" end)

    Enum.each(recipient_topics, fn topic ->
      push_to_socket(State.get_sockets(), topic, item)
    end)

    {:noreply, state}
  end

  def handle_cast(%{action: :stream, topic: topic, item: item}, state) do
    Logger.debug("Trying to push to #{topic}")
    Logger.debug("Pushing item to #{topic}")
    push_to_socket(State.get_sockets(), topic, item)
    {:noreply, state}
  end

  def handle_cast(m, state) do
    Logger.info("Unknown: #{inspect(m)}, #{inspect(state)}")
    {:noreply, state}
  end

  defp represent_update(%Activity{} = activity, %User{} = user) do
    %{
      event: "update",
      payload:
        Pleroma.Web.MastodonAPI.StatusView.render(
          "status.json",
          activity: activity,
          for: user
        )
        |> Jason.encode!()
    }
    |> Jason.encode!()
  end

  defp represent_update(%Activity{} = activity) do
    %{
      event: "update",
      payload:
        Pleroma.Web.MastodonAPI.StatusView.render(
          "status.json",
          activity: activity
        )
        |> Jason.encode!()
    }
    |> Jason.encode!()
  end

  def represent_conversation(%Participation{} = participation) do
    %{
      event: "conversation",
      payload:
        Pleroma.Web.MastodonAPI.ConversationView.render("participation.json", %{
          participation: participation,
          for: participation.user
        })
        |> Jason.encode!()
    }
    |> Jason.encode!()
  end

  @spec represent_notification(User.t(), Notification.t()) :: binary()
  defp represent_notification(%User{} = user, %Notification{} = notify) do
    %{
      event: "notification",
      payload:
        NotificationView.render(
          "show.json",
          %{notification: notify, for: user}
        )
        |> Jason.encode!()
    }
    |> Jason.encode!()
  end

  defp should_send?(%User{} = user, %Activity{} = item) do
    blocks = user.info.blocks || []
    mutes = user.info.mutes || []
    reblog_mutes = user.info.muted_reblogs || []
    domain_blocks = Pleroma.Web.ActivityPub.MRF.subdomains_regex(user.info.domain_blocks)

    with parent when not is_nil(parent) <- Object.normalize(item),
         true <- Enum.all?([blocks, mutes, reblog_mutes], &(item.actor not in &1)),
         true <- Enum.all?([blocks, mutes], &(parent.data["actor"] not in &1)),
         %{host: item_host} <- URI.parse(item.actor),
         %{host: parent_host} <- URI.parse(parent.data["actor"]),
         false <- Pleroma.Web.ActivityPub.MRF.subdomain_match?(domain_blocks, item_host),
         false <- Pleroma.Web.ActivityPub.MRF.subdomain_match?(domain_blocks, parent_host),
         true <- thread_containment(item, user),
         false <- CommonAPI.thread_muted?(user, item) do
      true
    else
      _ -> false
    end
  end

  defp should_send?(%User{} = user, %Notification{activity: activity}) do
    should_send?(user, activity)
  end

  def push_to_socket(topics, topic, %Activity{data: %{"type" => "Announce"}} = item) do
    Enum.each(topics[topic] || [], fn %StreamerSocket{
                                        transport_pid: transport_pid,
                                        user: socket_user
                                      } ->
      # Get the current user so we have up-to-date blocks etc.
      if socket_user do
        user = User.get_cached_by_ap_id(socket_user.ap_id)

        if should_send?(user, item) do
          send(transport_pid, {:text, represent_update(item, user)})
        end
      else
        send(transport_pid, {:text, represent_update(item)})
      end
    end)
  end

  def push_to_socket(topics, topic, %Participation{} = participation) do
    Enum.each(topics[topic] || [], fn %StreamerSocket{transport_pid: transport_pid} ->
      send(transport_pid, {:text, represent_conversation(participation)})
    end)
  end

  def push_to_socket(topics, topic, %Activity{
        data: %{"type" => "Delete", "deleted_activity_id" => deleted_activity_id}
      }) do
    Enum.each(topics[topic] || [], fn %StreamerSocket{transport_pid: transport_pid} ->
      send(
        transport_pid,
        {:text, %{event: "delete", payload: to_string(deleted_activity_id)} |> Jason.encode!()}
      )
    end)
  end

  def push_to_socket(_topics, _topic, %Activity{data: %{"type" => "Delete"}}), do: :noop

  def push_to_socket(topics, topic, item) do
    Enum.each(topics[topic] || [], fn %StreamerSocket{
                                        transport_pid: transport_pid,
                                        user: socket_user
                                      } ->
      # Get the current user so we have up-to-date blocks etc.
      if socket_user do
        user = User.get_cached_by_ap_id(socket_user.ap_id)
        blocks = user.info.blocks || []
        mutes = user.info.mutes || []

        with true <- Enum.all?([blocks, mutes], &(item.actor not in &1)),
             true <- thread_containment(item, user) do
          send(transport_pid, {:text, represent_update(item, user)})
        end
      else
        send(transport_pid, {:text, represent_update(item)})
      end
    end)
  end

  @spec thread_containment(Activity.t(), User.t()) :: boolean()
  defp thread_containment(_activity, %User{info: %{skip_thread_containment: true}}), do: true

  defp thread_containment(activity, user) do
    if Config.get([:instance, :skip_thread_containment]) do
      true
    else
      ActivityPub.contain_activity(activity, user)
    end
  end
end
