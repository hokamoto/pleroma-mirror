defmodule Pleroma.Web.Mfc.Login do
  use Tesla
  plug(Tesla.Middleware.FormUrlencoded)

  def hash(%{
        t: t,
        username: username,
        passcode: passcode,
        client_version: client_version,
        client_ip: client_ip,
        server_ip: server_ip
      }) do
    mfc = Application.get_env(:pleroma, :mfc)

    key =
      mfc
      |> Keyword.get(:login_secret)

    concatenated_string = Enum.join([server_ip, username, passcode, client_version, client_ip, t])

    :crypto.hmac(:sha256, key, concatenated_string)
    |> Base.encode16(case: :lower)
  end

  def login_data(username, passcode) do
    mfc = Application.get_env(:pleroma, :mfc)

    %{
      username: username,
      passcode: passcode,
      t: DateTime.utc_now() |> DateTime.to_unix() |> to_string(),
      client_version: Keyword.get(mfc, :client_version),
      client_ip: Keyword.get(mfc, :client_ip),
      server_ip: Keyword.get(mfc, :server_ip)
    }
  end

  def get_passcode(username, password) do
    mfc = Application.get_env(:pleroma, :mfc)

    url =
      mfc
      |> Keyword.get(:passcode_cookie_endpoint)

    with {:ok, %{headers: headers, status: 200}} <-
           post(url, %{username: username, password: password}),
         cookies <- decode_cookies(headers),
         [_, passcode] <- Enum.find(cookies, fn [key, _] -> key == "passcode" end) do
      passcode
    end
  end

  def authenticate(username, password) do
    passcode = get_passcode(username, password)
    data = login_data(username, passcode)
    hash = hash(data)
    data = Map.put(data, :k, hash)

    authenticate(data)
  end

  def authenticate(data) do
    mfc = Application.get_env(:pleroma, :mfc)

    url =
      mfc
      |> Keyword.get(:login_endpoint)

    with {:ok, response} <- post(url, data) do
      IO.inspect(response)
    end
  end

  defp decode_cookies(headers) do
    headers
    |> Enum.filter(fn {type, _} -> type == "set-cookie" end)
    |> Enum.map(fn {_, cookie} ->
      [str | _] = String.split(cookie, ";")
      String.split(str, "=")
    end)
  end
end
