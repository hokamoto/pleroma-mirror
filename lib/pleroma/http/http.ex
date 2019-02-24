# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.HTTP do
  @moduledoc """

  """

  alias Pleroma.HTTP.Connection
  alias Pleroma.HTTP.RequestBuilder, as: Builder

  @type t :: __MODULE__

  @doc """
  Builds and perform http request.

  # Arguments:
  `method` - :get, :post, :put, :delete
  `url`
  `body`
  `headers` - a keyworld list of headers, e.g. `[{"content-type", "text/plain"}]`
  `options` - custom, per-request middleware or adapter options

  # Returns:
  `{:ok, %Tesla.Env{}}` or `{:error, error}`

  """
  def request(method, url, body \\ "", headers \\ [], options \\ []) do
    options =
      process_request_options(options)
      |> process_sni_options(url)

    params = Keyword.get(options, :params, [])

    # Tesla will not timeout when given an incorrect URL,
    # so we'll add a temporary workaround to make sure that
    # a URL is valid our side
    # See: issues/672, merge_requests/862 
    url
    |> validate_url()
    |> case do
      {:ok, _} ->
        %{}
        |> Builder.method(method)
        |> Builder.headers(headers)
        |> Builder.opts(options)
        |> Builder.url(url)
        |> Builder.add_param(:body, :body, body)
        |> Builder.add_param(:query, :query, params)
        |> Enum.into([])
        |> (&Tesla.request(Connection.new(), &1)).()

      {:error, reason} ->
        {:error, reason}
    end
  end

  if Mix.env() == :test do
    defp validate_url(url), do: {:ok, url}
  else
    defp validate_url(url) do
      url
      |> URI.parse()
      |> Map.get(:host)
      |> to_charlist()
      |> :inet.gethostbyname()
      |> case do
        {:ok, _} -> {:ok, url}
        {:error, reason} -> {:error, reason}
      end
    end
  end

  defp process_sni_options(options, nil), do: options

  defp process_sni_options(options, url) do
    uri = URI.parse(url)
    host = uri.host |> to_charlist()

    case uri.scheme do
      "https" -> options ++ [ssl: [server_name_indication: host]]
      _ -> options
    end
  end

  def process_request_options(options) do
    config = Application.get_env(:pleroma, :http, [])
    proxy = Keyword.get(config, :proxy_url, nil)

    case proxy do
      nil -> options
      _ -> options ++ [proxy: proxy]
    end
  end

  @doc """
  Performs GET request.

  See `Pleroma.HTTP.request/5`
  """
  def get(url, headers \\ [], options \\ []),
    do: request(:get, url, "", headers, options)

  @doc """
  Performs POST request.

  See `Pleroma.HTTP.request/5`
  """
  def post(url, body, headers \\ [], options \\ []),
    do: request(:post, url, body, headers, options)
end
