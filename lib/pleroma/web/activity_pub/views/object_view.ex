# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.ActivityPub.ObjectView do
  use Pleroma.Web, :view
  alias Pleroma.Activity
  alias Pleroma.Object
  alias Pleroma.Web.ActivityPub.Transmogrifier
  alias Pleroma.Web.ActivityPub.Utils

  @likes_page_size 10
  def likes_page_size, do: @likes_page_size

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
      activity.data
      |> Transmogrifier.prepare_object()
      |> Map.put("object", Transmogrifier.prepare_object(object.data))

    Map.merge(base, additional)
  end

  def render("object.json", %{object: %Activity{} = activity}) do
    base = Utils.make_json_ld_header()
    object = Object.normalize(activity)

    additional =
      activity.data
      |> Transmogrifier.prepare_object()
      |> Map.put("object", object.data["id"])

    Map.merge(base, additional)
  end

  def render("likes.json", %{ap_id: ap_id, likes: likes, page: page} = params) do
    likes
    |> collection("#{ap_id}/likes", page, params)
    |> Map.merge(Utils.make_json_ld_header())
  end

  def render("likes.json", %{ap_id: ap_id, likes: likes} = params) do
    %{
      "id" => "#{ap_id}/likes",
      "type" => "OrderedCollection",
      "totalItems" => params[:total] || length(likes),
      "first" => collection(likes, "#{ap_id}/likes", 1, params)
    }
    |> Map.merge(Utils.make_json_ld_header())
  end

  def collection(collection, iri, page, params \\ %{}) do
    offset = (page - 1) * @likes_page_size
    items = Enum.map(collection, &Transmogrifier.prepare_object(&1.data))
    total = params[:total] || length(collection)

    map = %{
      "id" => "#{iri}?page=#{page}",
      "type" => "OrderedCollectionPage",
      "partOf" => iri,
      "totalItems" => total,
      "orderedItems" => items
    }

    if offset + length(items) < total do
      Map.put(map, "next", "#{iri}?page=#{page + 1}")
    else
      map
    end
  end
end
