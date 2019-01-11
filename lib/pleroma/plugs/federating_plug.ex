# Pleroma: A lightweight social networking server
# Copyright © 2017-2018 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.FederatingPlug do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _opts) do
    if Keyword.get(Application.get_env(:pleroma, :instance), :federating) do
      conn
    else
      conn
      |> put_status(404)
      |> Phoenix.Controller.put_view(Pleroma.Web.ErrorView)
      |> Phoenix.Controller.render("404.json")
      |> halt()
    end
  end
end
