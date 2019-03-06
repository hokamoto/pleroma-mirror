# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.MastodonAPI.SubscriptionController do
  @moduledoc "The module represents functions to manage user subscriptions."
  use Pleroma.Web, :controller

  alias Pleroma.Web.Push
  alias Pleroma.Web.Push.Subscription
  alias Pleroma.Web.MastodonAPI.PushSubscriptionView, as: View

  action_fallback(:errors)

  # Creates PushSubscription
  #
  def create(%{assigns: %{user: user, token: token}} = conn, params) do
    with true <- Push.enabled(),
         {:ok, _} <- Subscription.delete_if_exists(user, token),
         {:ok, subscription} <- Subscription.create(user, token, params) do
      view = View.render("push_subscription.json", subscription: subscription)
      json(conn, view)
    end
  end

  # Gets PushSubscription
  #
  def get(%{assigns: %{user: user, token: token}} = conn, _params) do
    with true <- Push.enabled(),
         subscription <- Subscription.get(user, token) do
      view = View.render("push_subscription.json", subscription: subscription)
      json(conn, view)
    end
  end

  # Updates PushSubscription
  #
  def update(%{assigns: %{user: user, token: token}} = conn, params) do
    with true <- Push.enabled(),
         {:ok, subscription} <- Subscription.update(user, token, params) do
      view = View.render("push_subscription.json", subscription: subscription)
      json(conn, view)
    end
  end

  # Deletes PushSubscription
  #
  def delete(%{assigns: %{user: user, token: token}} = conn, _params) do
    with true <- Push.enabled(),
         {:ok, _response} <- Subscription.delete(user, token),
         do: json(conn, %{})
  end

  # fallback action
  #
  def errors(conn, _) do
    conn
    |> put_status(500)
    |> json("Something went wrong")
  end
end
