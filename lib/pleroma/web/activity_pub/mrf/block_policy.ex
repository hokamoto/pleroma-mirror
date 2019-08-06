# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.ActivityPub.MRF.BlockPolicy do
  alias Pleroma.User
  alias Pleroma.Web.CommonAPI

  @moduledoc "Notify local users upon remote block."

  @behaviour Pleroma.Web.ActivityPub.MRF

  defp is_block_or_unblock(message) do
    case message do
      %{"type" => "Block", "object" => object} ->
        {true, "blocked", object}

      %{"type" => "Undo", "object" => %{"type" => "Block", "object" => object}} ->
        {true, "unblocked", object}

      _ ->
        {false, nil, nil}
    end
  end

  defp is_remote_or_displaying_local?(actor) do
    case actor do
      %User{local: false} -> true
      _ -> Pleroma.Config.get([:mrf_blockpolicy, :display_local])
    end
  end

  @impl true
  def filter(message) do
    with {true, action, object} <- is_block_or_unblock(message),
         %User{} = actor <- User.get_cached_by_ap_id(message["actor"]),
         %User{} = recipient <- User.get_cached_by_ap_id(object),
         true <- recipient.local,
         true <- is_remote_or_displaying_local?(actor),
         false <- User.blocks_ap_id?(recipient, actor) do
      bot_user = Pleroma.Config.get([:mrf_blockpolicy, :user])

      _reply =
        CommonAPI.post(User.get_by_nickname(bot_user), %{
          "status" =>
            "@" <> recipient.nickname <> " you are now " <> action <> " by " <> actor.nickname,
          "visibility" => "direct"
        })
    end

    {:ok, message}
  end
end
