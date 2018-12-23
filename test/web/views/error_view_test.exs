# Pleroma: A lightweight social networking server
# Copyright © 2017-2018 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.ErrorViewTest do
  use Pleroma.Web.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.json" do
    assert render(Pleroma.Web.ErrorView, "404.json", []) == %{errors: %{detail: "Page not found"}}
  end

  test "render 500.json" do
    assert render(Pleroma.Web.ErrorView, "500.json", []) ==
             %{errors: %{detail: "Internal server error"}}
  end

  test "render any other" do
    assert render(Pleroma.Web.ErrorView, "505.json", []) ==
             %{errors: %{detail: "Internal server error"}}
  end
end
