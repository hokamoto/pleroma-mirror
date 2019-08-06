# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.ActivityPub.MRF.BlockPolicy do
  alias Pleroma.User
  alias Pleroma.Web.CommonAPI

  @moduledoc "Notify local users upon remote block."

  @behaviour Pleroma.Web.ActivityPub.MRF

  @impl true
  def filter(message) do
    type = message["type"]

    if type == "Block" or (type == "Undo" and message["object"]["type"] == "Block") do
      recipient = User.get_cached_by_ap_id(message["object"])

      if recipient.local do
        actor = User.get_cached_by_ap_id(message["actor"])
        # default: do not show blocks from local users
        display_local = Pleroma.Config.get([:mrf_blockpolicy, :display_local])
        # ignore notifications from blocked users to stop spam
        if !User.blocks_ap_id?(recipient, actor) and (!actor.local or display_local) do
          bot_user = Pleroma.Config.get([:mrf_blockpolicy, :user])
          term = if type == "Block", do: "blocked", else: "unblocked"

          _reply =
            CommonAPI.post(User.get_by_nickname(bot_user), %{
              "status" =>
                "@" <> recipient.nickname <> " you are now " <> term <> " by " <> actor.nickname,
              "visibility" => "direct"
            })
        end
      end
    end

    {:ok, message}
  end
end
