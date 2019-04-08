defmodule Pleroma.Uploaders.MFCGifTest do
  use Pleroma.Web.ConnCase
  import Pleroma.Factory
  import Tesla.Mock

  @video_meta %{
    "source_key" => "test/fixtures/image.gif",
    "dest_key" => "out_full_n3.mp4",
    "still_key" => "out_full_preview.png",
    "meta" => %{
      "duration" => 15.11,
      "bitrate" => 891_066,
      "filesize" => 1_683_002,
      "video_stream" => "h264 (High) (avc1 / 0x31637661), yuv420p, 720x404 [SAR 1:1 DAR 180:101]",
      "video_codec" => "h264",
      "colorspace" => "yuv420p",
      "resolution" => "720x404",
      "width" => 720,
      "height" => 404,
      "frame_rate" => "13500000/451451"
    },
    "status" => "ok"
  }

  setup do
    Pleroma.Config.put([Pleroma.Upload, :uploader], Pleroma.Uploaders.MFC)

    mock(fn env -> apply(HttpRequestMock, :request, [env]) end)

    upload = %Plug.Upload{
      content_type: "image/gif",
      filename: "image.gif",
      path: "test/fixtures/image.gif"
    }

    {:ok, %{upload: upload}}
  end

  test "gif callback", %{conn: conn, upload: upload} do
    user = insert(:user)

    mock(fn
      %{method: :post, url: "http://test.test/api/v1/videos"} = env ->
        response = Jason.decode!(env.body)
        video_meta = Map.put(@video_meta, "source_key", response["source_key"])
        post(conn, "/api/pleroma/uploaders/mfc/success", video_meta)
        %Tesla.Env{status: 200, body: %{}}
    end)

    res_conn =
      conn
      |> assign(:user, user)
      |> post("/api/statusnet/media/upload", %{"media" => upload})

    expected_meta = %{
      "aspect" => 1.7821782178217822,
      "duration" => 15.11,
      "fps" => 30,
      "height" => 404,
      "original" => %{
        "bitrate" => 891_066,
        "duration" => 15.11,
        "frame_rate" => "13500000/451451",
        "height" => 404,
        "width" => 720
      },
      "size" => "720x404",
      "small" => %{
        "aspect" => 1.7821782178217822,
        "height" => 404,
        "size" => "720x404",
        "width" => 720
      },
      "width" => 720,
      "content_type" => "image/gifv"
    }

    assert [%{data: %{"meta" => meta}}] = Pleroma.Repo.all(Pleroma.Object)
    assert expected_meta == meta
    assert response(res_conn, 200) =~ "image/gifv"
  end

  test "gif callback, mastodon version", %{conn: conn, upload: upload} do
    user = insert(:user)

    mock(fn
      %{method: :post, url: "http://test.test/api/v1/videos"} = env ->
        response = Jason.decode!(env.body)
        video_meta = Map.put(@video_meta, "source_key", response["source_key"])
        post(conn, "/api/pleroma/uploaders/mfc/success", video_meta)
        %Tesla.Env{status: 200, body: %{}}
    end)

    res_conn =
      conn
      |> assign(:user, user)
      |> post("/api/v1/media", %{"file" => upload})

    expected_meta = %{
      "aspect" => 1.7821782178217822,
      "duration" => 15.11,
      "fps" => 30,
      "height" => 404,
      "original" => %{
        "bitrate" => 891_066,
        "duration" => 15.11,
        "frame_rate" => "13500000/451451",
        "height" => 404,
        "width" => 720
      },
      "size" => "720x404",
      "small" => %{
        "aspect" => 1.7821782178217822,
        "height" => 404,
        "size" => "720x404",
        "width" => 720
      },
      "width" => 720,
      "content_type" => "image/gifv"
    }

    assert [%{data: %{"meta" => meta}}] = Pleroma.Repo.all(Pleroma.Object)
    assert expected_meta == meta
    assert json_response(res_conn, 200)["type"] == "gifv"
  end
end
