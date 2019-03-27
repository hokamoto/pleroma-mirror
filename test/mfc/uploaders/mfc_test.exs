defmodule Pleroma.Uploaders.MFCTest do
  use Pleroma.DataCase
  import Tesla.Mock

  alias Pleroma.Config
  alias Pleroma.Uploaders.MFC

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
      "audio_sample_rate" => 44_100,
      "audio_channels" => 2
    },
    "status" => "ok"
  }

  describe "uploads video files" do
    test "returns a preview url of video" do
      origin_path = "test/fixtures/video.mp4_original"

      mock(fn
        %{method: :post, url: "http://test.test/api/v1/videos"} ->
          pid = :global.whereis_name({MFC, origin_path})
          conversion_result = %{meta: @video_meta, path: origin_path}
          send(pid, {MFC, {:ok, conversion_result}})
          %Tesla.Env{status: 200, body: "ok"}
      end)

      file = %Pleroma.Upload{
        id: "video.mp4",
        content_type: "video/mp4",
        tempfile: "test/fixtures/video.mp4",
        path: "test/fixtures/video.mp4",
        name: "video.mp4"
      }

      assert {:ok, {:upload_result, %{meta: video_meta, url_spec: url_spec}}} = MFC.put_file(file)

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

      {:ok, {:upload_result, upload_result}} = MFC.put_file(file)

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

  describe "generates preview urls" do
    setup do
      video_config = [MFC, :video_conversion, :postfix_preview_name]
      image_config = [MFC, :image_conversion, :postfix_preview_name]
      video_postfix = Config.get(video_config)

      image_postfix = Config.get(image_config)

      Config.put(video_config, ".video.jpg")

      Config.put(image_config, ".image.jpg")

      on_exit(fn ->
        Config.put(video_config, video_postfix)
        Config.put(image_config, image_postfix)
      end)
    end

    test "generates preview url for images" do
      assert MFC.preview_url(
               "image/webp",
               "https://pleroma.gov/f72cf8edfad39b5c0608e71f140f2b882f409e00006821467a46dc4822a942fa.png?name=corndog.png"
             ) ==
               "https://pleroma.gov/f72cf8edfad39b5c0608e71f140f2b882f409e00006821467a46dc4822a942fa.png.image.jpg?name=corndog.png"
    end

    test "generates preview url for videos" do
      assert MFC.preview_url(
               "video/webm",
               "https://pleroma.gov/f26ad03462b03c20f033825c32a9b44b00d550358a4f0424d104fa5b2c48a5e9.webm?name=jotaro_yes.webm"
             ) ==
               "https://pleroma.gov/f26ad03462b03c20f033825c32a9b44b00d550358a4f0424d104fa5b2c48a5e9.webm.video.jpg?name=jotaro_yes.webm"
    end

    test "returns the same url if asked to generate a preview url for an unsupported type" do
      assert MFC.preview_url(
               "application/octet-stream",
               "https://pleroma.gov/518c7a756a9b3cc1a5a202fb8ca7bc1f141e6c4b8b4e1d0f9b7e79339f8c5867.sfc?name=badapple.sfc"
             ) ==
               "https://pleroma.gov/518c7a756a9b3cc1a5a202fb8ca7bc1f141e6c4b8b4e1d0f9b7e79339f8c5867.sfc?name=badapple.sfc"
    end
  end
end
