# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Plugs.SessionAuthenticationNocheckPlug do
  import Plug.Conn

  alias Pleroma.User

  def init(options) do
    options
  end

  def call(conn, _) do
    with id <- get_session(conn, :user_id),
         true <- is_binary(id),
         %User{} = user <- User.get_by_id(id) do
      assign(conn, :auth_user, user)
    else
      _ -> conn
    end
  end
end
