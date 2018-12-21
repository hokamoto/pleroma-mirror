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

  test "given a username, passcode and a client ip, it generates the complete data set" do
    username = "lain"
    passcode = "123435"
    client_ip = "10.69.69.1"

    data = Login.login_data(username, passcode, "10.69.69.1")

    assert data.t
    assert data.client_version
    assert data.client_ip == client_ip
    assert data.server_ip
  end

  test "it calls to the login endpoint to get the passcode" do
    url =
      Application.get_env(:pleroma, :mfc)
      |> Keyword.get(:passcode_cookie_endpoint)

    username = "lain"
    password = "wired"

    Tesla.Mock.mock(fn
      %{method: :post, url: ^url} ->
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

    assert {:ok, "3nKHVtb3QDkNgKt3wsSnuak38vkHM5I6"} ==
             Login.get_passcode(username, password, "127.77.77.77")
  end

  test "it returns an error instead of a passcode for non-successful calls" do
    url =
      Application.get_env(:pleroma, :mfc)
      |> Keyword.get(:passcode_cookie_endpoint)

    username = "lain"
    password = "wired"

    Tesla.Mock.mock(fn
      %{method: :post, url: ^url} ->
        %Tesla.Env{
          status: 401,
          body:
            "{\"id\":\"0 0\",\"responseVer\":1,\"method\":\"login\",\"result\":null,\"err\":1,\"errmsg\":\"Your username or password are incorrect.\"}"
        }
    end)

    assert {:error, _} = Login.get_passcode(username, password, "127.77.77.77")
  end

  test "it authenticates using a data set" do
    url =
      Application.get_env(:pleroma, :mfc)
      |> Keyword.get(:login_endpoint)

    Tesla.Mock.mock(fn
      %{method: :post, url: ^url} ->
        %Tesla.Env{
          body:
            "{\"id\":\"0 0\",\"responseVer\":1,\"method\":\"internal\\/login\\/passcode\",\"result\":{\"user_id\":3004379,\"username\":\"testcam20\",\"access_level\":1,\"avatar_url\":false},\"err\":0}",
          status: 200
        }
    end)

    data = %{
      :t => 1_540_567_397,
      :username => "testcam20",
      :passcode => "abc",
      :client_version => "reddit_1_0_0",
      :client_ip => "1.2.3.4",
      :server_ip => "10.176.244.13",
      :k => "somehash"
    }

    assert {:ok, result} = Login.authenticate(data)

    assert result == %{
             "user_id" => 3_004_379,
             "access_level" => 1,
             "avatar_url" => false,
             "username" => "testcam20"
           }
  end

  test "it returns an error on a non-200 response" do
    url =
      Application.get_env(:pleroma, :mfc)
      |> Keyword.get(:login_endpoint)

    Tesla.Mock.mock(fn
      %{method: :post, url: ^url} ->
        %Tesla.Env{
          status: 403
        }
    end)

    data = %{
      :t => 1_540_567_397,
      :username => "testcam20",
      :passcode => "abc",
      :client_version => "reddit_1_0_0",
      :client_ip => "1.2.3.4",
      :server_ip => "10.176.244.13",
      :k => "somehash"
    }

    assert {:error, _} = Login.authenticate(data)
  end

  test "it authenticates using a username and password" do
    username = "lain"
    password = "wired"
    ip = "127.77.77.77"

    url =
      Application.get_env(:pleroma, :mfc)
      |> Keyword.get(:login_endpoint)

    passcode_url =
      Application.get_env(:pleroma, :mfc)
      |> Keyword.get(:passcode_cookie_endpoint)

    Tesla.Mock.mock(fn
      %{method: :post, url: ^url} ->
        %Tesla.Env{
          body:
            "{\"id\":\"0 0\",\"responseVer\":1,\"method\":\"internal\\/login\\/passcode\",\"result\":{\"user_id\":3004379,\"username\":\"lain\",\"access_level\":1,\"avatar_url\":false},\"err\":0}",
          status: 200
        }

      %{method: :post, url: ^passcode_url} ->
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

    assert {:ok, result} = Login.authenticate(username, password, ip)

    assert result == %{
             "user_id" => 3_004_379,
             "access_level" => 1,
             "avatar_url" => false,
             "username" => "lain"
           }
  end

  test "it returns an error on failed auth using a username and password" do
    username = "lain"
    password = "wired"
    ip = "127.77.77.77"

    passcode_url =
      Application.get_env(:pleroma, :mfc)
      |> Keyword.get(:passcode_cookie_endpoint)

    Tesla.Mock.mock(fn
      %{method: :post, url: ^passcode_url} ->
        %Tesla.Env{
          status: 401
        }
    end)

    assert {:error, _} = Login.authenticate(username, password, ip)
  end
end
