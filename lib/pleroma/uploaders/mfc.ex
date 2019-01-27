defmodule Pleroma.Uploaders.MFC do
  @behaviour Pleroma.Uploaders.Uploader

  alias Pleroma.Upload
  alias __MODULE__.Video
  alias __MODULE__.Image

  def get_file(file), do: store().get_file(file)

  # put video file
  #
  def put_file(%Upload{content_type: "video" <> _} = upload) do
    with {:ok, {:file, path}} <- store().put_file(rename_original_path(upload)),
         _ <- :global.register_name({__MODULE__, path}, self()),
         :ok <- Video.convert(Video.Client.client(), path),
         {:ok, path} <- wait_for_conversion() do
      {:ok, {:file, path}}
    else
      :duplicate ->
        {:ok, {:file, Path.rootname(upload.path) <> ".mp4"}}

      error = {:error, _} ->
        error
    end
  end

  # put image file
  #
  def put_file(%Upload{content_type: "image" <> _} = upload) do
    with {:ok, {:file, path}} <- store().put_file(upload),
         {:ok, _versions} <- Image.convert(Image.Client.client(), path) do
      {:ok, {:file, path}}
    else
      :duplicate ->
        {:ok, {:file, upload.path}}

      error = {:error, _} ->
        error
    end
  end

  def put_file(upload) do
    store().put_file(upload)
  end

  def preview_url("video", url), do: Video.build_preview_url(url)
  def preview_url("image", url), do: Image.build_preview_url(url)
  def preview_url(_type, href), do: href

  defp rename_original_path(upload) do
    %Upload{upload | path: upload.path <> "_original"}
  end

  defp store, do: Pleroma.Config.get([__MODULE__, :store], Pleroma.Uploaders.S3)

  defp wait_for_conversion() do
    receive do
      {__MODULE__, {:ok, path}} -> {:ok, path}
      {__MODULE__, {:error, error}} -> {:error, error}
    after
      conversion_wait() -> {:error, "conversion timeout"}
    end
  end

  defp conversion_wait do
    [__MODULE__, :video_conversion, :conversion_wait]
    |> Pleroma.Config.get(:timer.minutes(2))
  end
end
