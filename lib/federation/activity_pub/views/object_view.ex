# Pleroma: A lightweight social networking server
# Copyright © 2017-2020 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Federation.ActivityPub.ObjectView do
  use Pleroma.Web, :view
  alias Pleroma.Activity
  alias Pleroma.Federation.ActivityPub.Transmogrifier
  alias Pleroma.Federation.ActivityPub.Utils
  alias Pleroma.Object

  def render("object.json", %{object: %Object{} = object}) do
    base = Utils.make_json_ld_header()

    additional = Transmogrifier.prepare_object(object.data)
    Map.merge(base, additional)
  end

  def render("object.json", %{object: %Activity{data: %{"type" => activity_type}} = activity})
      when activity_type in ["Create", "Listen"] do
    base = Utils.make_json_ld_header()
    object = Object.normalize(activity)

    additional =
      Transmogrifier.prepare_object(activity.data)
      |> Map.put("object", Transmogrifier.prepare_object(object.data))

    Map.merge(base, additional)
  end

  def render("object.json", %{object: %Activity{} = activity}) do
    base = Utils.make_json_ld_header()
    object = Object.normalize(activity)

    additional =
      Transmogrifier.prepare_object(activity.data)
      |> Map.put("object", object.data["id"])

    Map.merge(base, additional)
  end
end
