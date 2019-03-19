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

  @default_audio_channel "stereo"

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

  # The the video API response format:
  #
  # {
  #   "source_key": "out_full.mp4",
  #   "dest_key": "out_full_n3.mp4",
  #   "still_key": "out_full_preview.png",
  #   "meta": {
  #     "duration": 15.11,
  #     "bitrate": 891066,
  #     "filesize": 1683002,
  #     "video_stream": "h264 (High) (avc1 / 0x31637661), yuv420p, 720x404 [SAR 1:1 DAR 180:101]",
  #     "video_codec": "h264",
  #     "colorspace": "yuv420p",
  #     "resolution": "720x404",
  #     "width": 720,
  #     "height": 404,
  #     "frame_rate": "13500000/451451",
  #     "audio_stream": "aac (mp4a / 0x6134706d), 44100 Hz, stereo, fltp, 134472 bit/s",
  #     "audio_codec": "aac",
  #     "audio_sample_rate": 44100,
  #     "audio_channels": 2
  #   },
  #   "status": "ok"
  # }
  #
  # Mastodon meta video media attachment format:
  #
  #  {
  #    "length": "0:00:28.40"                              =>
  #    "duration": 28.4,                                   => duration
  #    "audio_encode": "aac (LC) (mp4a / 0x6134706D)",     => derived from audio_stream
  #    "audio_bitrate": "44100 Hz",                        => audio_sample_rate
  #    "audio_channels": "stereo",                         => derived from audio_channels
  #    "fps": 30,                                          => derived from frame_rate
  #    "size": "848x480",                                  => resolution
  #    "width": 848,                                       => width
  #    "height": 480,                                      => height
  #    "aspect": 1.7666666666666666,                       => width / height
  #    "original": {
  #      "width": 848,                                     => width
  #      "height": 480,                                    => height
  #      "frame_rate": "255600/8519",                      => frame_rate
  #      "duration": 28.396667,                            => duration
  #      "bitrate": 1670865                                => bitrate
  #    },
  #    "small": {
  #      "width": 400,                                     => thumbnail width
  #      "height": 226,                                    => thumbnail height
  #      "size": "400x226",                                => thumbnail dimensions
  #      "aspect": 1.7699115044247788                      => thumbnail aspect
  #    }
  #  }
  #
  def parse_conversion_result(%{
        "dest_key" => path,
        "meta" =>
          %{
            "duration" => duration,
            "bitrate" => bitrate,
            "resolution" => resolution,
            "width" => width,
            "height" => height,
            "frame_rate" => frame_rate,
            "audio_stream" => audio_stream,
            "audio_sample_rate" => audio_sample_rate
          } = meta
      }) do
    aspect = width / height
    audio_channels = if meta["audio_channels"] == 1, do: "mono", else: @default_audio_channel

    meta = %{
      "duration" => duration,
      "audio_encode" => get_audio_encode(audio_stream),
      "audio_bitrate" => "#{audio_sample_rate} Hz",
      "audio_channels" => audio_channels,
      "fps" => get_fps(frame_rate),
      "size" => resolution,
      "width" => width,
      "height" => height,
      "aspect" => aspect,
      "original" => %{
        "width" => width,
        "height" => height,
        "frame_rate" => frame_rate,
        "duration" => duration,
        "bitrate" => bitrate
      },
      "small" => %{
        "width" => width,
        "height" => height,
        "size" => resolution,
        "aspect" => aspect
      }
    }

    {:ok, %{meta: meta, path: path}}
  end

  def parse_conversion_result(conversion_result) do
    Logger.error(
      "#{__MODULE__}: The conversion result doesn't match the expected format: #{
        inspect(conversion_result)
      }"
    )

    {:error, "Unknown format"}
  end

  def get_fps(frame_rate) do
    with [a, b] <- String.split(frame_rate, "/"),
         [{a, _}, {b, _}] when is_integer(a) and is_integer(b) <-
           Enum.map([a, b], &Integer.parse(&1)) do
      round(a / b)
    else
      _ -> nil
    end
  end

  def get_audio_encode(audio_stream) do
    audio_stream |> String.split(",") |> List.first()
  end

  @doc "Build preview url"
  @spec build_preview_url(String.t()) :: String.t()
  def build_preview_url(path) do
    postfix_preview_name =
      [Pleroma.Uploaders.MFC, :video_conversion, :postfix_preview_name]
      |> Pleroma.Config.get(@default_postfix_preview)

    "#{path}#{postfix_preview_name}"
  end
end
