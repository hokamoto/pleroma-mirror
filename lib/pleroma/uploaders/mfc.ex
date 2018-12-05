defmodule Pleroma.Uploaders.MFC do
  @behaviour Pleroma.Uploaders.Uploader
  alias Pleroma.Uploaders.S3
  alias __MODULE__.Client

  @conversion_wait :timer.minutes(2)

  def get_file(file) do
    S3.get_file(file)
  end

  def put_file(upload = %Pleroma.Upload{content_type: "video" <> _}) do
    with {:ok, {:file, path}} <-
           S3.put_file(%Pleroma.Upload{upload | path: upload.path <> "_original"}),
         _ <- :global.register_name({__MODULE__, path}, self()),
         client <- Client.client(),
         :ok <- Client.convert(client, path),
         {:ok, path} <- wait_for_conversion() do
      {:ok, {:file, path}}
    else
      error = {:error, _} -> error
    end
  end

  def put_file(upload) do
    S3.put_file(upload)
  end

  defp wait_for_conversion() do
    receive do
      {__MODULE__, {:ok, path}} -> {:ok, path}
      {__MODULE__, {:error, error}} -> {:error, error}
    after
      @conversion_wait -> {:error, "conversion timeout"}
    end
  end
end
