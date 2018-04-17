defmodule Pleroma.HTTP do
  use HTTPoison.Base

  require HTTPoison

  defp parse_proxy_url(url) do
    uri = URI.parse(url)
    case uri.protocol do
      "socks" -> {:socks5 , uri.host, uri.port}
      _ -> {:connect , uri.host, uri.port}
    end
  end
  
  def process_request_options(options) do
    config = Application.get_env(:pleroma, :http, [])
    proxy = Keyword.get(config, :proxy_url, nil)

    case proxy do
      nil -> options
      _ -> options ++ [proxy: parse_proxy_url(proxy)]
    end
  end

  defp filter_opts_using_proxy_map(url, options, proxy_map) do
    uri = URI.parse(url)
    item = Enum.find(proxy_map, nil, fn (idx) -> Regex.match?(Regex.compile!(Enum.at(idx, 0)), uri.host) end)
    case item do
      nil -> options
      _ ->
        case Enum.at(item, 1) do
          nil -> Keyword.drop(options, [:proxy])
          "" -> Keyword.drop(options, [:proxy])
          _ -> Keyword.put(options, :proxy, parse_proxy_url(Enum.at(item, 1)))
        end
    end
  end

  defp process_opts(url, options) do
    config = Application.get_env(:pleroma, :http, [])
    proxy_map = Keyword.get(config, :proxy_map, nil)
    case proxy_map do
      nil -> options
      _ -> filter_opts_using_proxy_map(url, options, proxy_map)
    end
  end
  
  def request(method, url, body \\ "", headers \\ [], options \\ []) do
    HTTPoison.request(method, url, body, headers, process_opts(url, options))
  end

  def request!(method, url, body \\ "", headers \\ [], options \\ []) do
    HTTPoison.request!(method, url, body, headers, process_opts(url, options))
  end

end
