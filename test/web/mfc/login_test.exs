defmodule Pleroma.Web.Mfc.LoginTest do
  use Pleroma.DataCase
  alias Pleroma.Web.Mfc.Login

  test "Correctly hashes a given data set" do
    data = %{
      :t => 1_540_567_397,
      :username => "testcam20",
      :passcode => "abc",
      :client_version => "reddit_1_0_0",
      :client_ip => "1.2.3.4",
      :server_ip => "10.176.244.13"
    }

    assert Login.hash(data) == "27d1c53d862446d662d71b317dde113fe792a33392e967e4cb4b30c7b48d9bd9"
  end

  test "given a username and passcode, it generates the complete data set" do
    username = "lain"
    passcode = "123435"

    data = Login.login_data(username, passcode)

    assert data.t
    assert data.client_version
    assert data.client_ip
    assert data.server_ip
  end

  test "it calls to the login endpoint to get the passcode" do
    username = "lain"
    password = "wired"

    Tesla.Mock.mock(fn
      %{method: :post} ->
        %Tesla.Env{
          status: 200,
          headers: [
            {"set-cookie",
             "passcode=3nKHVtb3QDkNgKt3wsSnuak38vkHM5I6; expires=Thu, 28-Oct-2038 13:12:01 GMT; path=/; domain=myfreecams.com"},
            {"set-cookie",
             "username=lain; expires=Thu, 28-Oct-2038 13:14:27 GMT; path=/; domain=myfreecams.com"}
          ]
        }
    end)

    assert Login.get_passcode(username, password) == "3nKHVtb3QDkNgKt3wsSnuak38vkHM5I6"
  end

  test "it authenticates using a data set" do
    data = %{
      :t => 1_540_567_397,
      :username => "testcam20",
      :passcode => "abc",
      :client_version => "reddit_1_0_0",
      :client_ip => "1.2.3.4",
      :server_ip => "10.176.244.13"
    }

    assert false
  end
end
