# Pleroma: A lightweight social networking server
# Copyright © 2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.ActivityPub.MRF.BlockPolicyTest do
  use Pleroma.DataCase
  import Pleroma.Factory
  import Mock

  import Pleroma.Web.ActivityPub.MRF.BlockPolicy

  setup do
    bot_user = insert(:user)
    actor_remote = insert(:user, %{local: false})
    recipient = insert(:user)

    block_remote = %{
      "actor" => actor_remote.ap_id,
      "type" => "Block",
      "object" => recipient.ap_id
    }

    %{
      bot_user: bot_user,
      actor_remote: actor_remote,
      recipient: recipient,
      block_remote: block_remote,
    }
  end

  defp generate_notif(recipient, action, actor),
    do: "@" <> recipient.nickname <> " you are now " <> action <> " by " <> actor.nickname

  test_with_mock "user is notified upon remote block",
                 %{
                   bot_user: bot_user,
                   actor_remote: actor_remote,
                   block_remote: block_remote,
                   recipient: recipient
                 },
                 Pleroma.Web.CommonAPI,
                 [:passthrough],
                 [] do
    Pleroma.Config.put([:mrf_blockpolicy], %{user: bot_user.nickname, display_local: false})

    {:ok, _message} = filter(block_remote)

    notif = generate_notif(recipient, "blocked", actor_remote)

    assert called(
             Pleroma.Web.CommonAPI.post(bot_user, %{
               "status" => notif,
               "visbility" => "direct"
             })
           )
  end
end
