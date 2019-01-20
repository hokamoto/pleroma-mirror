defmodule Pleroma.Uploaders.MFC do
  @behaviour Pleroma.Uploaders.Uploader

  alias Pleroma.Upload
  alias __MODULE__.Video
  alias __MODULE__.Image

  @conversion_wait :timer.minutes(2)
  @original_postprefix "_original"

  # TODO: With dedupe enabled, if two users upload the same file at the same time, this will bug (probably make an user
  # wait for a timeout).
  # A possible fix would be to create a Registry and share the upload key against multiple processes.
  # Some API would be needed in Pleroma to do start-up checks/supervision tree changes to do this properly.@

  def get_file(file), do: store().get_file(file)

  # put video file
  #
  def put_file(%Upload{content_type: "video" <> _} = upload) do
    with {:ok, {:file, path}} <- store().put_file(build_upload(upload)),
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
  def put_file(%Pleroma.Upload{content_type: "image" <> _} = upload) do
    with {:ok, {:file, path}} <- store().put_file(build_upload(upload)),
         {:ok, [path | _]} <- Image.convert(Image.Client.client(), path),
         do: {:ok, {:file, path}}
  end

  def put_file(upload) do
    store().put_file(upload)
  end

  def build_upload(upload) do
    %Upload{upload | path: "#{upload.path}#{@original_postprefix}"}
  end

  def preview_url("video", url), do: Video.build_preview_url(url)
  def preview_url("image", url), do: Image.build_preview_url(url)
  def preview_url(_type, href), do: href

  defp store do
    config()
    |> Keyword.get(:store, Pleroma.Uploaders.S3)
  end

  defp config, do: Pleroma.Config.get([__MODULE__], [])

  defp wait_for_conversion() do
    receive do
      {__MODULE__, {:ok, path}} -> {:ok, path}
      {__MODULE__, {:error, error}} -> {:error, error}
    after
      @conversion_wait -> {:error, "conversion timeout"}
    end
  end
end
