# Pleroma: A lightweight social networking server
# Copyright © 2017-2018 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.TwitterAPI.Representers.ObjectReprenterTest do
  use Pleroma.DataCase

  alias Pleroma.Object
  alias Pleroma.Web.TwitterAPI.Representers.ObjectRepresenter

  @meta %{
    "original" => %{
      "width" => 2048,
      "height" => 2048,
      "size" => "2048x2048",
      "aspect" => 1.2484394506866416,
      "content_type" => "image/png",
      "dest_key" => "original.png",
      "method" => "resize"
    },
    "small" => %{
      "width" => 800,
      "height" => 800,
      "size" => "800x800",
      "aspect" => 1.2484394506866416,
      "content_type" => "image/png",
      "dest_key" => "small.png",
      "method" => "smartcrop"
    }
  }

  test "represent an image attachment" do
    object = %Object{
      id: 5,
      data: %{
        "type" => "Image",
        "url" => [
          %{
            "mediaType" => "sometype",
            "href" => "someurl"
          }
        ],
        "uuid" => 6,
        "meta" => @meta
      }
    }

    expected_object = %{
      id: 6,
      url: "someurl",
      mimetype: "sometype",
      oembed: false,
      description: nil,
      large_thumb_url: nil,
      meta: @meta
    }

    assert expected_object == ObjectRepresenter.to_map(object)
  end

  test "represents mastodon-style attachments" do
    object = %Object{
      id: nil,
      data: %{
        "mediaType" => "image/png",
        "name" => "blabla",
        "type" => "Document",
        "url" =>
          "http://mastodon.example.org/system/media_attachments/files/000/000/001/original/8619f31c6edec470.png",
        "meta" => @meta
      }
    }

    expected_object = %{
      url:
        "http://mastodon.example.org/system/media_attachments/files/000/000/001/original/8619f31c6edec470.png",
      mimetype: "image/png",
      oembed: false,
      id: nil,
      description: "blabla",
      meta: @meta
    }

    assert expected_object == ObjectRepresenter.to_map(object)
  end
end
