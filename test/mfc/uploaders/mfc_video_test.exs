defmodule Pleroma.Uploaders.MFCVideoTest do
  use Pleroma.Web.ConnCase
  import Pleroma.Factory
  import Tesla.Mock

  @video_meta %{
    "source_key" => "video.mp4",
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
      "frame_rate" => "13500000/451451",
      "audio_stream" => "aac (mp4a / 0x6134706d), 44100 Hz, stereo, fltp, 134472 bit/s",
      "audio_codec" => "aac",
      "audio_sample_rate" => 44_100,
      "audio_channels" => 2
    },
    "status" => "ok"
  }

  @video_without_audio %{
    "source_key" => "test/fixtures/video.mp4",
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
      content_type: "video/mp4",
      filename: "video.mp4",
      path: "test/fixtures/video.mp4"
    }

    {:ok, %{upload: upload}}
  end

  test "video callback", %{conn: conn, upload: upload} do
    user = insert(:user)

    mock(fn
      %{method: :post, url: "http://test.test/api/v1/videos"} = env ->
        response = Jason.decode!(env.body)
        video_meta = Map.put(@video_meta, "source_key", response["source_key"])
        post(conn, "/api/pleroma/uploaders/mfc/success", video_meta)
        %Tesla.Env{status: 200, body: %{}}
    end)

    conn =
      conn
      |> assign(:user, user)
      |> post("/api/statusnet/media/upload", %{"media" => upload})

    expected_meta = %{
      "aspect" => 1.7821782178217822,
      "audio_bitrate" => "44100 Hz",
      "audio_channels" => "stereo",
      "audio_encode" => "aac (mp4a / 0x6134706d)",
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
      "width" => 720
    }

    assert response(conn, 200)
    assert [%{data: %{"meta" => meta}}] = Pleroma.Repo.all(Pleroma.Object)
    assert expected_meta == meta
  end

  test "video without audio", %{conn: conn, upload: upload} do
    user = insert(:user)

    mock(fn
      %{method: :post, url: "http://test.test/api/v1/videos"} = env ->
        response = Jason.decode!(env.body)
        video_meta = Map.put(@video_without_audio, "source_key", response["source_key"])
        post(conn, "/api/pleroma/uploaders/mfc/success", video_meta)
        %Tesla.Env{status: 200, body: %{}}
    end)

    conn =
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
      "width" => 720
    }

    assert response(conn, 200)
    assert [%{data: %{"meta" => meta}}] = Pleroma.Repo.all(Pleroma.Object)
    assert expected_meta == meta
  end
end
