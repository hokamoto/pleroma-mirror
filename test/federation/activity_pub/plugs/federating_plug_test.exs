# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Federation.ActivityPub.FederatingPlugTest do
  use Pleroma.Web.ConnCase
  alias Pleroma.Federation.ActivityPub.FederatingPlug

  clear_config_all([:instance, :federating])

  test "returns and halt the conn when federating is disabled" do
    Pleroma.Config.put([:instance, :federating], false)

    conn = FederatingPlug.call(build_conn(), %{})

    assert conn.status == 404
    assert conn.halted
  end

  test "does nothing when federating is enabled" do
    Pleroma.Config.put([:instance, :federating], true)

    conn = FederatingPlug.call(build_conn(), %{})

    refute conn.status
    refute conn.halted
  end
end
