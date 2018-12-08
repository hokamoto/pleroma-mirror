defmodule Pleroma.Uploaders.MFC.Client do
  use Tesla
  require Logger

  def client() do
    middleware = [
      {Tesla.Middleware.BaseUrl,
       Pleroma.Config.get!([Pleroma.Uploaders.MFC, :video_conversion, :endpoint])},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware)
  end

  @spec convert(Tesla.Client.t(), String.t()) :: :ok | :duplicate | {:error, String.t()}
  def convert(client, path) do
    config = Pleroma.Config.get!([Pleroma.Uploaders.MFC, :video_conversion])

    data = %{
      "client" => Keyword.fetch!(config, :client),
      "secret" => Keyword.fetch!(config, :secret),
      "source_key" => path,
      "dest_key" => Path.rootname(path) <> "." <> "mp4"
    }

    case post(client, "/api/v1/videos", data) do
      {:ok, %{status: 200}} ->
        :ok

      {:ok, %{status: 500, body: %{"error" => "Destination object already exists"}}} ->
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
end
