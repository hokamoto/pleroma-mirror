# Pleroma: A lightweight social networking server
# Copyright © 2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.ActivityPub.MRF.NoPlaceholderTextPolicyTest do
  use Pleroma.DataCase
  use ExUnitProperties
  alias Pleroma.Web.ActivityPub.MRF.NoPlaceholderTextPolicy

  property "filter/3 it clears content object" do
    check all content <- StreamData.member_of([".", "<p>.</p>"]) do
      message = %{
        "type" => "Create",
        "object" => %{"content" => content, "attachment" => "image"}
      }

      assert {:ok, res} = NoPlaceholderTextPolicy.filter(message)
      assert res["object"]["content"] == ""
    end
  end

  @messages [
    %{
      "type" => "Create",
      "object" => %{"content" => "test", "attachment" => "image"}
    },
    %{"type" => "Create", "object" => %{"content" => "."}},
    %{"type" => "Create", "object" => %{"content" => "<p>.</p>"}}
  ]
  property "filter/3 it skip filter" do
    check all message <- StreamData.member_of(@messages) do
      assert {:ok, res} = NoPlaceholderTextPolicy.filter(message)
      assert res == message
    end
  end
end
