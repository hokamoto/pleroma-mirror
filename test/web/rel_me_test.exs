# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.RelMeTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog

  setup_all do
    Tesla.Mock.mock_global(fn env -> apply(HttpRequestMock, :request, [env]) end)
    :ok
  end

  test "parse/1" do
    hrefs = ["https://social.example.org/users/lain"]

    assert Pleroma.Web.RelMe.parse("http://example.com/rel_me/null") == {:ok, []}

    assert capture_log(fn ->
             assert {:error, _} = Pleroma.Web.RelMe.parse("http://example.com/rel_me/error")
           end) =~ "some error"

    assert Pleroma.Web.RelMe.parse("http://example.com/rel_me/link") == {:ok, hrefs}
    assert Pleroma.Web.RelMe.parse("http://example.com/rel_me/anchor") == {:ok, hrefs}
    assert Pleroma.Web.RelMe.parse("http://example.com/rel_me/anchor_nofollow") == {:ok, hrefs}
  end

  test "maybe_put_rel_me/2" do
    profile_urls = ["https://social.example.org/users/lain"]
    attr = "me"
    fallback = nil

    assert Pleroma.Web.RelMe.maybe_put_rel_me("http://example.com/rel_me/null", profile_urls) ==
             fallback

    assert capture_log(fn ->
             assert Pleroma.Web.RelMe.maybe_put_rel_me(
                      "http://example.com/rel_me/error",
                      profile_urls
                    ) ==
                      fallback
           end) =~ "some error"

    assert Pleroma.Web.RelMe.maybe_put_rel_me("http://example.com/rel_me/anchor", profile_urls) ==
             attr

    assert Pleroma.Web.RelMe.maybe_put_rel_me(
             "http://example.com/rel_me/anchor_nofollow",
             profile_urls
           ) == attr

    assert Pleroma.Web.RelMe.maybe_put_rel_me("http://example.com/rel_me/link", profile_urls) ==
             attr
  end
end
