# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.TwitterAPI.Representers.ObjectRepresenter do
  use Pleroma.Web.TwitterAPI.Representers.BaseRepresenter
  alias Pleroma.Object

  def to_map(%Object{data: %{"url" => [url | _]}} = object, opts) do
    data = object.data

    %{
      url: url["href"] |> Pleroma.Web.MediaProxy.url(),
      large_thumb_url: preview_url(Map.get(opts, :local, false), url),
      mimetype: url["mediaType"] || url["mimeType"],
      id: data["uuid"],
      oembed: false,
      description: data["name"]
    }
  end

  def to_map(%Object{data: %{"url" => url} = data}, _opts) when is_binary(url) do
    %{
      url: url |> Pleroma.Web.MediaProxy.url(),
      mimetype: data["mediaType"] || data["mimeType"],
      id: data["uuid"],
      oembed: false,
      description: data["name"]
    }
  end

  def to_map(%Object{}, _opts) do
    %{}
  end

  # If we only get the naked data, wrap in an object
  def to_map(%{} = data, opts) do
    to_map(%Object{data: data}, opts)
  end

  defp preview_url(true, url) do
    media_type = url["mediaType"] || url["mimeType"] || "image"

    type =
      cond do
        String.contains?(media_type, "image") -> "image"
        String.contains?(media_type, "video") -> "video"
        String.contains?(media_type, "audio") -> "audio"
        true -> "unknown"
      end

    Pleroma.Uploaders.Uploader.preview_url(type, url["href"])
  end

  defp preview_url(_, _), do: nil
end
