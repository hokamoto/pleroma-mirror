# Pleroma: A lightweight social networking server
# Copyright © 2017-2018 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.CacheControlTest do
  alias Plug.Conn

  test "Verify Cache-Control header on static assets", %{conn: conn} do
    conn = get(conn, "/index.html")

    assert Conn.get_resp_header(conn, "cache-control") == ["public, no-cache"]
  end
end
