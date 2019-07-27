defmodule Pleroma.XMPPTest do
  use ExUnit.Case

  alias Pleroma.XMPP

  @xmpp_host "xmpp.tld"

  @xmpp_sid "TestSessionID"

  @xmpp_init_response """
  <body sid='#{@xmpp_sid}'>
  <stream:features>
  <mechanisms xmlns='urn:ietf:params:xml:ns:xmpp-sasl'>
  <mechanism>PLAIN</mechanism>
  </mechanisms>
  <sm xmlns='urn:xmpp:sm:3'/>
  </stream:features>
  </body>
  """

  @xmpp_auth_ok_response """
  <body sid='#{@xmpp_sid}'>
  <success xmlns='urn:ietf:params:xml:ns:xmpp-sasl'/>
  </body>
  """

  @xmpp_auth_err_response """
  <body sid='#{@xmpp_sid}'>
  <failure xmlns='urn:ietf:params:xml:ns:xmpp-sasl'>
  <not-authorized/>
  </failure>
  </body>
  """

  describe "Prebind" do
    setup do
      xmpp_config = Application.get_env(:pleroma, :xmpp)
      Application.put_env(:pleroma, :xmpp, enabled: true, host: @xmpp_host)
      on_exit(fn -> Application.put_env(:pleroma, :xmpp, xmpp_config) end)

      username = "testuser"
      password = "testpassword"

      Tesla.Mock.mock(fn env ->
        body =
          case env.body =~ "sid=" do
            false ->
              @xmpp_init_response

            true ->
              [_, auth_string] = Regex.run(~r/\<auth.*?\>\s*?([^\s].*?)\s*?\<\/auth/usi, env.body)
              decoded_auth_string = Base.decode64!(auth_string)

              case String.split(decoded_auth_string, <<0>>) do
                [_jid, ^username, ^password] ->
                  @xmpp_auth_ok_response

                _ ->
                  @xmpp_auth_err_response
              end
          end

        %Tesla.Env{status: 200, body: body}
      end)

      {:ok, username: username, password: password}
    end

    test "Valid username and password", %{username: username, password: password} do
      assert XMPP.prebind(username, password) == {:ok, @xmpp_sid}
    end

    test "Invalid username and password", %{username: username, password: password} do
      assert XMPP.prebind(username, password <> "1") == {:error, "Invalid Username or Password"}
    end
  end
end
