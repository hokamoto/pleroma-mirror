# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.MongooseIM.MongooseIMController do
  use Pleroma.Web, :controller

  alias Comeonin.Pbkdf2
  alias Pleroma.Plugs.RateLimiter
  alias Pleroma.User

  plug(RateLimiter, :authentication when action in [:user_exists, :check_password])
  plug(RateLimiter, {:authentication, params: ["user"]} when action == :check_password)

  def user_exists(conn, %{"user" => username}) do
    with %User{local: true} <- User.get_by_nickname(username) do
      conn
      |> json(true)
    else
      _ ->
        conn
        |> put_status(:not_found)
        |> json(false)
    end
  end

  def check_password(conn, %{"user" => username, "pass" => password}) do
    with %User{password_hash: password_hash, local: true} <-
           User.get_by_nickname(username),
         true <- Pbkdf2.checkpw(password, password_hash) do
      conn
      |> json(true)
    else
      false ->
        conn
        |> put_status(:forbidden)
        |> json(false)

      _ ->
        conn
        |> put_status(:not_found)
        |> json(false)
    end
  end
end
