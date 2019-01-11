# Pleroma: A lightweight social networking server
# Copyright © 2017-2018 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.WebFinger.WebFingerController do
  use Pleroma.Web, :controller

  alias Pleroma.Web.WebFinger

  plug(Pleroma.Web.FederatingPlug)

  def host_meta(conn, _params) do
    xml = WebFinger.host_meta()

    conn
    |> put_resp_content_type("application/xrd+xml")
    |> send_resp(200, xml)
  end

  def webfinger(conn, %{"resource" => resource}) do
    case get_format(conn) do
      n when n in ["xml", "xrd+xml"] ->
        with {:ok, response} <- WebFinger.webfinger(resource, "XML") do
          conn
          |> put_resp_content_type("application/xrd+xml")
          |> send_resp(200, response)
        else
          _e -> send_resp(conn, 404, "Couldn't find user")
        end

      n when n in ["json", "jrd+json"] ->
        with {:ok, response} <- WebFinger.webfinger(resource, "JSON") do
          json(conn, response)
        else
          _e -> send_resp(conn, 404, "Couldn't find user")
        end

      _ ->
        send_resp(conn, 404, "Unsupported format")
    end
  end

  def webfinger(conn, _params) do
    send_resp(conn, 400, "Bad Request")
  end
end
