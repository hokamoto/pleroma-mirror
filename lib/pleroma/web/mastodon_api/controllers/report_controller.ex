# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.MastodonAPI.ReportController do
  use Pleroma.Web, :controller

  action_fallback(Pleroma.Web.MastodonAPI.FallbackController)

  @doc "POST /api/v1/reports"
  def create(%{assigns: %{user: user}} = conn, params) do
    with {:ok, activity} <- Pleroma.Web.CommonAPI.report(user, params) do
      render(conn, "show.json", activity: activity)
    end
  end
end