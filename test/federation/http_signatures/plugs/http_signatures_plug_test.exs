# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Federation.HTTPSignatures.HTTPSignaturesPlugTest do
  use Pleroma.Web.ConnCase
  alias Pleroma.Federation.HTTPSignatures.HTTPSignaturesPlug

  import Plug.Conn
  import Mock

  test "it call HTTPSignatures to check validity if the actor sighed it" do
    params = %{"actor" => "http://mastodon.example.org/users/admin"}
    conn = build_conn(:get, "/doesntmattter", params)

    with_mock HTTPSignatures, validate_conn: fn _ -> true end do
      conn =
        conn
        |> put_req_header("signature", "keyId=\"http://mastodon.example.org/users/admin#main-key")
        |> HTTPSignaturesPlug.call(%{})

      assert conn.assigns.valid_signature == true
      assert called(HTTPSignatures.validate_conn(:_))
    end
  end
end
