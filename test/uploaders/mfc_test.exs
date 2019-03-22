defmodule Pleroma.Uploaders.MFCTest do
  use Pleroma.DataCase
  import Tesla.Mock

  @video_meta %{
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
      "frame_rate" => "13500000/451451",
      "audio_stream" => "aac (mp4a / 0x6134706d), 44100 Hz, stereo, fltp, 134472 bit/s",
      "audio_codec" => "aac",
      "audio_sample_rate" => 44100,
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

  describe "uploads video files" do
    test "returns a preview url of video" do
      origin_path = "test/fixtures/video.mp4_original"

      mock(fn
        %{method: :post, url: "http://test.test/api/v1/videos"} ->
          pid = :global.whereis_name({Pleroma.Uploaders.MFC, origin_path})
          conversion_result = %{meta: @video_meta, path: origin_path}
          send(pid, {Pleroma.Uploaders.MFC, {:ok, conversion_result}})
          %Tesla.Env{status: 200, body: "ok"}
      end)

      file = %Pleroma.Upload{
        id: "video.mp4",
        content_type: "video/mp4",
        tempfile: "test/fixtures/video.mp4",
        path: "test/fixtures/video.mp4",
        name: "video.mp4"
      }

      assert {:ok, {:upload_result, %{meta: video_meta, url_spec: url_spec}}} =
               Pleroma.Uploaders.MFC.put_file(file)

      assert video_meta == @video_meta
      assert {:file, "test/fixtures/video.mp4_original"} == url_spec
    end
  end

  @image_versions %{
    original: %{
      width: 2048,
      height: 2048,
      size: "2048x2048",
      aspect: 1.2484394506866416,
      method: "resize",
      dest_key: "original.png",
      content_type: "image/png"
    },
    small: %{
      width: 800,
      height: 800,
      size: "800x800",
      aspect: 1.2483426823049464,
      method: "smartcrop",
      dest_key: "small.png",
      content_type: "image/png"
    }
  }

  describe "uploads image files" do
    test "returns a url and meta from encoding-api" do
      mock(fn
        %{method: :post, url: "http://test.test/api/v2/images"} ->
          json(%{versions: @image_versions})
      end)

      file = %Pleroma.Upload{
        id: "image_tmp.jpg",
        content_type: "image/jpg",
        tempfile: "test/fixtures/image_tmp.jpg",
        path: "some_path/image_tmp.jpg",
        name: "image_tmp.jpg"
      }

      {:ok, {:upload_result, upload_result}} = Pleroma.Uploaders.MFC.put_file(file)

      assert upload_result ==
               %{
                 meta: %{
                   "original" => %{
                     "height" => 2048,
                     "width" => 2048,
                     "size" => "2048x2048",
                     "aspect" => 1.2484394506866416,
                     "method" => "resize",
                     "dest_key" => "original.png",
                     "content_type" => "image/png"
                   },
                   "small" => %{
                     "height" => 800,
                     "width" => 800,
                     "size" => "800x800",
                     "aspect" => 1.2483426823049464,
                     "method" => "smartcrop",
                     "dest_key" => "small.png",
                     "content_type" => "image/png"
                   }
                 },
                 url_spec: {:file, "some_path/image_tmp.jpg"}
               }
    end
  end

  describe "uploads not video\image files" do
  end
end
