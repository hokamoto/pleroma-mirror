# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.MongooseIM.MongooseIMController do
  use Pleroma.Web, :controller
  alias Comeonin.Pbkdf2
  alias Pleroma.Repo
  alias Pleroma.User

  require Logger

  def user_exists(conn, %{"user" => username}) do
    with %User{} <- Repo.get_by(User, nickname: username, local: true) do
      conn
      |> json(true)
    else
      _ ->
        conn
        |> put_status(:not_found)
        |> json(false)
    end
  end

  def check_password(conn, %{"user" => username, "pass" => password}) do
    with %User{password_hash: password_hash} <-
           Repo.get_by(User, nickname: username, local: true),
         true <- Pbkdf2.checkpw(password, password_hash) do
      conn
      |> json(true)
    else
      false ->
        conn
        |> put_status(403)
        |> json(false)

      _ ->
        conn
        |> put_status(:not_found)
        |> json(false)
    end
  end

  def prebind(conn, _params) do
    user = conn.assigns.auth_user

    host = Pleroma.Web.Endpoint.host()
    jid = user.nickname <> "@" <> host
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

    response = %{
      "jid" => jid,
      "sid" => "",
      "rid" => rid
    }

    json(conn, response)
  end
end
