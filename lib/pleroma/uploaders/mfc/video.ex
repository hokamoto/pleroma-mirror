defmodule Pleroma.Uploaders.MFC.Video do
  @moduledoc """
  The module represents functions to upload videos and take screenshot.
  """

  require Logger

  defmodule Client do
    use Tesla

    def client() do
      middleware = [
        {
          Tesla.Middleware.BaseUrl,
          Pleroma.Config.get!([Pleroma.Uploaders.MFC, :video_conversion, :endpoint])
        },
        Tesla.Middleware.JSON
      ]

      Tesla.client(middleware)
    end
  end

  @video_ext ".mp4"
  @convert_path "/api/v1/videos"
  @default_postfix_preview ".preview.jpg"

  @doc "Uploads video to take screenshot."
  @spec convert(Tesla.Client.t(), String.t()) :: :ok | :duplicate | {:error, String.t()}
  def convert(client, path) do
    config = Pleroma.Config.get!([Pleroma.Uploaders.MFC, :video_conversion])

    data = %{
      "client" => Keyword.fetch!(config, :client),
      "secret" => Keyword.fetch!(config, :secret),
      "source_key" => path,
      "dest_key" => Path.rootname(path) <> @video_ext,
      "still_key" => build_preview_url(Path.rootname(path) <> @video_ext),
      "still_seek_percentage" => 50
    }

    case Client.post(client, @convert_path, data) do
      {:ok, %{status: 200}} ->
        :ok

      {:ok, %{status: 500, body: %{"error" => "destination_key_already_exists"}}} ->
        :duplicate

      {:ok, client = %{status: status}} ->
        Logger.error(
          "#{__MODULE__}: HTTP request to conversion service failed: #{inspect(client)}"
        )

        {:error, "Conversion error: #{status}"}

      error ->
        Logger.error(
          "#{__MODULE__}: HTTP request to conversion service failed: #{inspect(error)}"
        )

        {:error, "Conversion error"}
    end
  end

  @doc "Build preview url"
  @spec build_preview_url(String.t()) :: String.t()
  def build_preview_url(path) do
    postfix_preview_name =
      [Pleroma.Uploaders.MFC, :video_conversion, :postfix_preview_name]
      |> Pleroma.Config.get(@default_postfix_preview)

    uri = URI.parse(path)

    %URI{uri | path: uri.path <> postfix_preview_name}
    |> to_string
  end
end
