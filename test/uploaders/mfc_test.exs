defmodule Pleroma.Uploaders.MFCTest do
  use Pleroma.DataCase
  import Tesla.Mock

  describe "uploads video files" do
    test "returns a preview url of video" do
      origin_path = "test/fixtures/video.mp4_original"

      mock(fn
        %{method: :post, url: "http://test.test/api/v1/videos"} ->
          pid = :global.whereis_name({Pleroma.Uploaders.MFC, origin_path})
          send(pid, {Pleroma.Uploaders.MFC, {:ok, origin_path}})
          %Tesla.Env{status: 200, body: "ok"}
      end)

      file = %Pleroma.Upload{
        id: "video.mp4",
        content_type: "video/mp4",
        tempfile: "test/fixtures/video.mp4",
        path: "test/fixtures/video.mp4",
        name: "video.mp4"
      }

      assert {
               :ok,
               {:file, origin_path}
             } = Pleroma.Uploaders.MFC.put_file(file)
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
