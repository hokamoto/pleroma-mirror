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
    jid = username <> "@" <> host
    rid = System.unique_integer([:monotonic, :positive])

    req_body = """
      <body
        content="text/xml; charset=utf-8"
        hold="1"
        rid="#{rid}"
        to="#{host}"
        ver="1.6"
        wait="60"
        xml:lang="en"
        xmlns="http://jabber.org/protocol/httpbind"
        xmlns:xmpp="urn:xmpp:xbosh"
        xmpp:version="1.0"/>
    """

    xmpp_host = "p.devs.live"
    %Tesla.Env{body: body} = Tesla.post!("https://" <> xmpp_host <> "/http-bind", req_body)
    sid = xpath(body, ~x"//body/@sid")
    rid2 = System.unique_integer([:monotonic, :positive])

    auth_string =
      <<jid::binary, 0::8, username::binary, 0::8, password::binary>>
      |> Base.encode64()

    req_body2 = """
      <body
        rid="#{rid2}"
        sid="#{sid}"
        xmlns="http://jabber.org/protocol/httpbind">
        <auth mechanism="PLAIN" xmlns="urn:ietf:params:xml:ns:xmpp-sasl">
          #{auth_string}
        </auth>
      </body>
    """

    %Tesla.Env{body: body2} = Tesla.post!("https://" <> xmpp_host <> "/http-bind", req_body2)

    case xpath(body2, ~x"//success") do
      nil ->
        {:error, "Invalid Username or Password"}

      _ ->
        {:ok, sid}
    end
  end
end
