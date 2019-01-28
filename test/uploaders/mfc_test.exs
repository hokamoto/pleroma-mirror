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

  describe "uploads image files" do
    test "returns a url" do
      mock(fn
        %{method: :post, url: "http://test.test/api/v1/images"} ->
          json(["output_resize1000x1000.png"])
      end)

      file = %Pleroma.Upload{
        id: "image_tmp.jpg",
        content_type: "image/jpg",
        tempfile: "test/fixtures/image_tmp.jpg",
        path: "some_path/image_tmp.jpg",
        name: "image_tmp.jpg"
      }

      assert {
               :ok,
               {:file, "some_path/image_tmp.jpg"}
             } = Pleroma.Uploaders.MFC.put_file(file)
    end
  end

  describe "uploads not video\image files" do
  end
end
