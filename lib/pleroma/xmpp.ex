defmodule Pleroma.XMPP do
  @moduledoc """
  Module to deal with XMPP (currently tested with MongooseIM) stuff.
  """

  import SweetXml

  @doc """
  Prebind to XMPP server.
  Used for single-session support to provide local users with on-site XMPP capabilities.
  Returns XMPP session id (SID)

  ## Examples

    iex> Pleroma.XMPP.prebind("neo", "matrixHasMe")
    {:ok, "abcdef01234567890"}

    iex> Pleroma.XMPP.prebind("neo", "matrixHasYou")
    {:error, "Invalid username or password"}
  """
  @spec prebind(String.t(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def prebind(username, password) do
    host = Pleroma.Web.Endpoint.host()

    xmpp_host =
      :pleroma
      |> Application.get_env(:xmpp, [])
      |> Keyword.get(:host, host)

    jid = username <> "@" <> host

    params = %{
      host: host,
      xmpp_host: xmpp_host,
      jid: jid,
      username: username,
      password: password
    }

    params
    |> init_session()
    |> auth_session()
  end

  defp init_session(%{host: host, xmpp_host: xmpp_host} = params) do
    req_body = """
      <body
        content="text/xml; charset=utf-8"
        hold="1"
        rid="#{rid()}"
        to="#{host}"
        ver="1.6"
        wait="60"
        xml:lang="en"
        xmlns="http://jabber.org/protocol/httpbind"
        xmlns:xmpp="urn:xmpp:xbosh"
        xmpp:version="1.0"/>
    """

    %Tesla.Env{body: body} = Tesla.post!(xmpp_host <> "/http-bind", req_body)
    sid = xpath(body, ~x"//body/@sid")
    Map.put(params, :sid, sid)
  end

  defp auth_session(%{
         sid: sid,
         jid: jid,
         xmpp_host: xmpp_host,
         username: username,
         password: password
       }) do
    auth_string =
      <<jid::binary, 0::8, username::binary, 0::8, password::binary>>
      |> Base.encode64()

    req_body = """
      <body
        rid="#{rid()}"
        sid="#{sid}"
        xmlns="http://jabber.org/protocol/httpbind">
        <auth mechanism="PLAIN" xmlns="urn:ietf:params:xml:ns:xmpp-sasl">
          #{auth_string}
        </auth>
      </body>
    """

    %Tesla.Env{body: body} = Tesla.post!(xmpp_host <> "/http-bind", req_body)

    case xpath(body, ~x"//success") do
      nil ->
        {:error, "Invalid Username or Password"}

      _ ->
        {:ok, to_string(sid)}
    end
  end

  defp rid, do: System.unique_integer([:monotonic, :positive])
end
