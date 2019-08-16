# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.ReverseProxyTest do
  use Pleroma.Web.ConnCase
  import ExUnit.CaptureLog
  import Mox
  alias Pleroma.ReverseProxy
  alias Pleroma.ReverseProxy.ClientMock

  setup_all do
    {:ok, _} = Registry.start_link(keys: :unique, name: Pleroma.ReverseProxy.ClientMock)
    :ok
  end

  setup :verify_on_exit!

  defp user_agent_mock(user_agent, invokes) do
    json = Jason.encode!(%{"user-agent": user_agent})

    ClientMock
    |> expect(:request, fn :get, url, _, _, _ ->
      Registry.register(Pleroma.ReverseProxy.ClientMock, url, 0)

      {:ok, 200,
       [
         {"content-type", "application/json"},
         {"content-length", byte_size(json) |> to_string()}
       ], %{url: url}}
    end)
    |> expect(:stream_body, invokes, fn %{url: url} = client ->
      case Registry.lookup(Pleroma.ReverseProxy.ClientMock, url) do
        [{_, 0}] ->
          Registry.update_value(Pleroma.ReverseProxy.ClientMock, url, &(&1 + 1))
          {:ok, json, client}

        [{_, 1}] ->
          Registry.unregister(Pleroma.ReverseProxy.ClientMock, url)
          :done
      end
    end)
  end

  describe "user-agent" do
    test "don't keep", %{conn: conn} do
      user_agent_mock("hackney/1.15.1", 2)
      conn = ReverseProxy.call(conn, "/user-agent")
      assert json_response(conn, 200) == %{"user-agent" => "hackney/1.15.1"}
    end

    test "keep", %{conn: conn} do
      user_agent_mock(Pleroma.Application.user_agent(), 2)
      conn = ReverseProxy.call(conn, "/user-agent-keep", keep_user_agent: true)
      assert json_response(conn, 200) == %{"user-agent" => Pleroma.Application.user_agent()}
    end
  end

  test "closed connection", %{conn: conn} do
    ClientMock
    |> expect(:request, fn :get, "/closed", _, _, _ -> {:ok, 200, [], %{}} end)
    |> expect(:stream_body, fn _ -> {:error, :closed} end)
    |> expect(:close, fn _ -> :ok end)

    conn = ReverseProxy.call(conn, "/closed")
    assert conn.halted
  end

  defp stream_mock(invokes, with_close? \\ false) do
    ClientMock
    |> expect(:request, fn :get, "/stream-bytes/" <> length, _, _, _ ->
      Registry.register(Pleroma.ReverseProxy.ClientMock, "/stream-bytes/" <> length, 0)

      {:ok, 200, [{"content-type", "application/octet-stream"}],
       %{url: "/stream-bytes/" <> length}}
    end)
    |> expect(:stream_body, invokes, fn %{url: "/stream-bytes/" <> length} = client ->
      max = String.to_integer(length)

      case Registry.lookup(Pleroma.ReverseProxy.ClientMock, "/stream-bytes/" <> length) do
        [{_, current}] when current < max ->
          Registry.update_value(
            Pleroma.ReverseProxy.ClientMock,
            "/stream-bytes/" <> length,
            &(&1 + 10)
          )

          {:ok, "0123456789", client}

        [{_, ^max}] ->
          Registry.unregister(Pleroma.ReverseProxy.ClientMock, "/stream-bytes/" <> length)
          :done
      end
    end)

    if with_close? do
      expect(ClientMock, :close, fn _ -> :ok end)
    end
  end

  describe "max_body " do
    test "length returns error if content-length more than option", %{conn: conn} do
      user_agent_mock("hackney/1.15.1", 0)

      assert capture_log(fn ->
               ReverseProxy.call(conn, "/user-agent", max_body_length: 4)
             end) =~
               "[error] Elixir.Pleroma.ReverseProxy: request to \"/user-agent\" failed: :body_too_large"
    end

    test "max_body_size returns error if streaming body more than that option", %{conn: conn} do
      stream_mock(3, true)

      assert capture_log(fn ->
               ReverseProxy.call(conn, "/stream-bytes/50", max_body_size: 30)
             end) =~
               "[warn] Elixir.Pleroma.ReverseProxy request to /stream-bytes/50 failed while reading/chunking: :body_too_large"
    end
  end

  describe "HEAD requests" do
    test "common", %{conn: conn} do
      ClientMock
      |> expect(:request, fn :head, "/head", _, _, _ ->
        {:ok, 200, [{"content-type", "text/html; charset=utf-8"}]}
      end)

      conn = ReverseProxy.call(Map.put(conn, :method, "HEAD"), "/head")
      assert html_response(conn, 200) == ""
    end
  end

  defp error_mock(status) when is_integer(status) do
    ClientMock
    |> expect(:request, fn :get, "/status/" <> _, _, _, _ ->
      {:error, status}
    end)
  end

  describe "returns error on" do
    test "500", %{conn: conn} do
      error_mock(500)

      capture_log(fn -> ReverseProxy.call(conn, "/status/500") end) =~
        "[error] Elixir.Pleroma.ReverseProxy: request to /status/500 failed with HTTP status 500"
    end

    test "400", %{conn: conn} do
      error_mock(400)

      capture_log(fn -> ReverseProxy.call(conn, "/status/400") end) =~
        "[error] Elixir.Pleroma.ReverseProxy: request to /status/400 failed with HTTP status 400"
    end

    test "204", %{conn: conn} do
      ClientMock
      |> expect(:request, fn :get, "/status/204", _, _, _ -> {:ok, 204, [], %{}} end)

      capture_log(fn ->
        conn = ReverseProxy.call(conn, "/status/204")
        assert conn.resp_body == "Request failed: No Content"
        assert conn.halted
      end) =~
        "[error] Elixir.Pleroma.ReverseProxy: request to \"/status/204\" failed with HTTP status 204"
    end
  end

  test "streaming", %{conn: conn} do
    stream_mock(21)
    conn = ReverseProxy.call(conn, "/stream-bytes/200")
    assert conn.state == :chunked
    assert byte_size(conn.resp_body) == 200
    assert Plug.Conn.get_resp_header(conn, "content-type") == ["application/octet-stream"]
  end

  defp headers_mock(_) do
    ClientMock
    |> expect(:request, fn :get, "/headers", headers, _, _ ->
      Registry.register(Pleroma.ReverseProxy.ClientMock, "/headers", 0)
      {:ok, 200, [{"content-type", "application/json"}], %{url: "/headers", headers: headers}}
    end)
    |> expect(:stream_body, 2, fn %{url: url, headers: headers} = client ->
      case Registry.lookup(Pleroma.ReverseProxy.ClientMock, url) do
        [{_, 0}] ->
          Registry.update_value(Pleroma.ReverseProxy.ClientMock, url, &(&1 + 1))
          headers = for {k, v} <- headers, into: %{}, do: {String.capitalize(k), v}
          {:ok, Jason.encode!(%{headers: headers}), client}

        [{_, 1}] ->
          Registry.unregister(Pleroma.ReverseProxy.ClientMock, url)
          :done
      end
    end)

    :ok
  end

  describe "keep request headers" do
    setup [:headers_mock]

    test "header passes", %{conn: conn} do
      conn =
        Plug.Conn.put_req_header(
          conn,
          "accept",
          "text/html"
        )
        |> ReverseProxy.call("/headers")

      %{"headers" => headers} = json_response(conn, 200)
      assert headers["Accept"] == "text/html"
    end

    test "header is filtered", %{conn: conn} do
      conn =
        Plug.Conn.put_req_header(
          conn,
          "accept-language",
          "en-US"
        )
        |> ReverseProxy.call("/headers")

      %{"headers" => headers} = json_response(conn, 200)
      refute headers["Accept-Language"]
    end
  end

  test "returns 400 on non GET, HEAD requests", %{conn: conn} do
    conn = ReverseProxy.call(Map.put(conn, :method, "POST"), "/ip")
    assert conn.status == 400
  end

  describe "cache resp headers" do
    test "returns headers", %{conn: conn} do
      ClientMock
      |> expect(:request, fn :get, "/cache/" <> ttl, _, _, _ ->
        {:ok, 200, [{"cache-control", "public, max-age=" <> ttl}], %{}}
      end)
      |> expect(:stream_body, fn _ -> :done end)

      conn = ReverseProxy.call(conn, "/cache/10")
      assert {"cache-control", "public, max-age=10"} in conn.resp_headers
    end

    test "add cache-control", %{conn: conn} do
      ClientMock
      |> expect(:request, fn :get, "/cache", _, _, _ ->
        {:ok, 200, [{"ETag", "some ETag"}], %{}}
      end)
      |> expect(:stream_body, fn _ -> :done end)

      conn = ReverseProxy.call(conn, "/cache")
      assert {"cache-control", "public"} in conn.resp_headers
    end
  end

  defp disposition_headers_mock(headers) do
    ClientMock
    |> expect(:request, fn :get, "/disposition", _, _, _ ->
      Registry.register(Pleroma.ReverseProxy.ClientMock, "/disposition", 0)

      {:ok, 200, headers, %{url: "/disposition"}}
    end)
    |> expect(:stream_body, 2, fn %{url: "/disposition"} = client ->
      case Registry.lookup(Pleroma.ReverseProxy.ClientMock, "/disposition") do
        [{_, 0}] ->
          Registry.update_value(Pleroma.ReverseProxy.ClientMock, "/disposition", &(&1 + 1))
          {:ok, "", client}

        [{_, 1}] ->
          Registry.unregister(Pleroma.ReverseProxy.ClientMock, "/disposition")
          :done
      end
    end)
  end

  describe "response content disposition header" do
    test "not atachment", %{conn: conn} do
      disposition_headers_mock([
        {"content-type", "image/gif"},
        {"content-length", 0}
      ])

      conn = ReverseProxy.call(conn, "/disposition")

      assert {"content-type", "image/gif"} in conn.resp_headers
    end

    test "with content-disposition header", %{conn: conn} do
      disposition_headers_mock([
        {"content-disposition", "attachment; filename=\"filename.jpg\""},
        {"content-length", 0}
      ])

      conn = ReverseProxy.call(conn, "/disposition")

      assert {"content-disposition", "attachment; filename=\"filename.jpg\""} in conn.resp_headers
    end
  end

  describe "integration tests" do
    @describetag :integration

    test "with hackney client", %{conn: conn} do
      client = Pleroma.Config.get([Pleroma.ReverseProxy.Client])
      Pleroma.Config.put([Pleroma.ReverseProxy.Client], Pleroma.ReverseProxy.Client.Hackney)

      on_exit(fn ->
        Pleroma.Config.put([Pleroma.ReverseProxy.Client], client)
      end)

      conn = ReverseProxy.call(conn, "http://httpbin.org/stream-bytes/10")

      assert byte_size(conn.resp_body) == 10
      assert conn.state == :chunked
      assert conn.status == 200
    end

    test "with tesla client with gun adapter", %{conn: conn} do
      client = Pleroma.Config.get([Pleroma.ReverseProxy.Client])
      Pleroma.Config.put([Pleroma.ReverseProxy.Client], Pleroma.ReverseProxy.Client.Tesla)
      adapter = Application.get_env(:tesla, :adapter)
      Application.put_env(:tesla, :adapter, Tesla.Adapter.Gun)

      api = Pleroma.Config.get([Pleroma.Gun.API])
      Pleroma.Config.put([Pleroma.Gun.API], Pleroma.Gun.API.Gun)
      {:ok, _} = Pleroma.Gun.Connections.start_link(Pleroma.Gun.Connections)

      conn = ReverseProxy.call(conn, "http://httpbin.org/stream-bytes/10")

      assert byte_size(conn.resp_body) == 10
      assert conn.state == :chunked
      assert conn.status == 200

      on_exit(fn ->
        Pleroma.Config.put([Pleroma.ReverseProxy.Client], client)
        Application.put_env(:tesla, :adapter, adapter)
        Pleroma.Config.put([Pleroma.Gun.API], api)
      end)
    end

    test "with tesla client with gun adapter with ssl", %{conn: conn} do
      client = Pleroma.Config.get([Pleroma.ReverseProxy.Client])
      Pleroma.Config.put([Pleroma.ReverseProxy.Client], Pleroma.ReverseProxy.Client.Tesla)
      adapter = Application.get_env(:tesla, :adapter)
      Application.put_env(:tesla, :adapter, Tesla.Adapter.Gun)

      api = Pleroma.Config.get([Pleroma.Gun.API])
      Pleroma.Config.put([Pleroma.Gun.API], Pleroma.Gun.API.Gun)
      {:ok, _} = Pleroma.Gun.Connections.start_link(Pleroma.Gun.Connections)

      conn = ReverseProxy.call(conn, "https://httpbin.org/stream-bytes/10")

      assert byte_size(conn.resp_body) == 10
      assert conn.state == :chunked
      assert conn.status == 200

      on_exit(fn ->
        Pleroma.Config.put([Pleroma.ReverseProxy.Client], client)
        Application.put_env(:tesla, :adapter, adapter)
        Pleroma.Config.put([Pleroma.Gun.API], api)
      end)
    end

    test "tesla client with gun client follow redirects", %{conn: conn} do
      client = Pleroma.Config.get([Pleroma.ReverseProxy.Client])
      Pleroma.Config.put([Pleroma.ReverseProxy.Client], Pleroma.ReverseProxy.Client.Tesla)
      adapter = Application.get_env(:tesla, :adapter)
      Application.put_env(:tesla, :adapter, Tesla.Adapter.Gun)

      api = Pleroma.Config.get([Pleroma.Gun.API])
      Pleroma.Config.put([Pleroma.Gun.API], Pleroma.Gun.API.Gun)
      {:ok, _} = Pleroma.Gun.Connections.start_link(Pleroma.Gun.Connections)

      conn = ReverseProxy.call(conn, "https://httpbin.org/redirect/5")

      assert conn.state == :chunked
      assert conn.status == 200

      on_exit(fn ->
        Pleroma.Config.put([Pleroma.ReverseProxy.Client], client)
        Application.put_env(:tesla, :adapter, adapter)
        Pleroma.Config.put([Pleroma.Gun.API], api)
      end)
    end
  end
end
