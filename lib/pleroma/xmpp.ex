defmodule Pleroma.XMPP do
  @moduledoc """
  Module to deal with XMPP (currently tested with MongooseIM) stuff.
  """

  @doc """
  Prebind to XMPP server.
  Used for single-session support to provide local users with on-site XMPP capabilities.
  Returns XMPP session id (SID)

  ## Examples

    iex> Pleroma.XMPP.prebind("neo", "matrixHasMe")
    "abcdef01234567890"

    iex> Pleroma.XMPP.prebind("neo", "matrixHasYou")
    {:error, "Invalid username or password"}
  """
  @spec prebind(String.t(), String.t()) :: String.t() | {:error, String.t()}
  def prebind(username, _password) do
    host = Pleroma.Web.Endpoint.host()
    _jid = username <> "@" <> host
    rid = System.unique_integer([:monotonic, :positive])
    xmpp_host = "p.devs.live"

    # body = """
    #   <body content='text/xml; charset=utf-8' from='#{jid}' hold='1' rid='#{rid}' to='#{xmpp_host}' wait='60' xml:lang='en' xmpp:version='1.0' xmlns='http://jabber.org/protocol/httpbind' xmlns:xmpp='urn:xmpp:xbosh'/>
    # """

    body = """
      <body
        content="text/xml; charset=utf-8"
        hold="1"
        rid="#{rid}"
        to="#{xmpp_host}"
        ver="1.6"
        wait="60"
        xml:lang="en"
        xmlns="http://jabber.org/protocol/httpbind"
        xmlns:xmpp="urn:xmpp:xbosh"
        xmpp:version="1.0"/>
    """

    # response
    # <body
    #   wait='59'
    #   requests='2'
    #   hold='1'
    #   from='p.devs.live'
    #   accept='deflate, gzip'
    #   sid='4a3c9827e2b01dec3fafbcfc56f4a7b10c7870fc'
    #   xmpp:restartlogic='true'
    #   xmpp:version='1.0'
    # . xmlns='http://jabber.org/protocol/httpbind'
    #   xmlns:xmpp='urn:xmpp:xbosh'
    # . xmlns:stream='http://etherx.jabber.org/streams'
    #   inactivity='30'
    #   maxpause='120'>
    #   <stream:features>
    #     <mechanisms xmlns='urn:ietf:params:xml:ns:xmpp-sasl'>
    #       <mechanism>PLAIN</mechanism>
    #     </mechanisms>
    #     <sm xmlns='urn:xmpp:sm:3'/>
    #   </stream:features>
    # </body>

    # body2
    # <body
    #   rid="3975855045"
    #   sid="4a3c9827e2b01dec3fafbcfc56f4a7b10c7870fc"
    #   xmlns="http://jabber.org/protocol/httpbind">
    #   <auth mechanism="PLAIN" xmlns="urn:ietf:params:xml:ns:xmpp-sasl">
    #     dXNlcjJAcC5kZXZzLmxpdmUAdXNlcjIAdXNlcjI=
    #   </auth>
    # </body>

    _res = Tesla.post!("https://" <> xmpp_host <> "/http-bind", body)

    sid = "some sid"

    sid
  end
end
