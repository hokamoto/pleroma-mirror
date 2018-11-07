defmodule Pleroma.Web.OAuth.OAuthController do
  use Pleroma.Web, :controller

  alias Pleroma.Web.OAuth.{Authorization, Token, App}
  alias Pleroma.{Repo, User}
  alias Comeonin.Pbkdf2

  plug(:fetch_session)
  plug(:fetch_flash)

  action_fallback(Pleroma.Web.OAuth.FallbackController)

  def authorize(conn, params) do
    render(conn, "show.html", %{
      response_type: params["response_type"],
      client_id: params["client_id"],
      scope: params["scope"],
      redirect_uri: params["redirect_uri"],
      state: params["state"],
      name: params["name"],
      password: params["password"],
      registration: params["registration"]
    })
  end

  defp get_or_create_mfc_user(mfc_id, nickname) do
    mfc_id = to_string(mfc_id)
    user = Repo.get_by(User, mfc_id: mfc_id)

    cond do
      user ->
        user

      nickname ->
        with {:ok, user} <-
               User.mfc_register_changeset(%User{}, %{
                 nickname: nickname,
                 mfc_id: mfc_id,
                 name: nickname
               })
               |> Repo.insert() do
          user
        end

      true ->
        nil
    end
  end

  def create_authorization(conn, %{
        "authorization" =>
          %{
            "name" => name,
            "password" => password,
            "client_id" => client_id,
            "redirect_uri" => redirect_uri
          } = params
      }) do
    with {_, {:ok, user_data}} <- {:mfc_auth, Pleroma.Web.Mfc.Login.authenticate(name, password)},
         true <-
           user_data["access_level"] >=
             Application.get_env(:pleroma, :mfc) |> Keyword.get(:minimum_access_level),
         {_, %User{} = user} <-
           {:user_get, get_or_create_mfc_user(user_data["user_id"], user_data["username"])},
         %App{} = app <- Repo.get_by(App, client_id: client_id),
         {:ok, auth} <- Authorization.create_authorization(app, user) do
      # Special case: Local MastodonFE.
      redirect_uri =
        if redirect_uri == "." do
          mastodon_api_url(conn, :login)
        else
          redirect_uri
        end

      cond do
        redirect_uri == "urn:ietf:wg:oauth:2.0:oob" ->
          render(conn, "results.html", %{
            auth: auth
          })

        true ->
          connector = if String.contains?(redirect_uri, "?"), do: "&", else: "?"
          url = "#{redirect_uri}#{connector}"
          url_params = %{:code => auth.token}

          url_params =
            if params["state"] do
              Map.put(url_params, :state, params["state"])
            else
              url_params
            end

          url = "#{url}#{Plug.Conn.Query.encode(url_params)}"

          redirect(conn, external: url)
      end
    else
      {:user_get, _} ->
        conn
        |> Pleroma.Web.OAuth.OAuthController.authorize(Map.put(params, "registration", true))

      e ->
        e
    end
  end

  # TODO
  # - proper scope handling
  def token_exchange(conn, %{"grant_type" => "authorization_code"} = params) do
    with %App{} = app <- get_app_from_request(conn, params),
         fixed_token = fix_padding(params["code"]),
         %Authorization{} = auth <-
           Repo.get_by(Authorization, token: fixed_token, app_id: app.id),
         {:ok, token} <- Token.exchange_token(app, auth),
         {:ok, inserted_at} <- DateTime.from_naive(token.inserted_at, "Etc/UTC") do
      response = %{
        token_type: "Bearer",
        access_token: token.token,
        refresh_token: token.refresh_token,
        created_at: DateTime.to_unix(inserted_at),
        expires_in: 60 * 10,
        scope: "read write follow"
      }

      json(conn, response)
    else
      _error ->
        put_status(conn, 400)
        |> json(%{error: "Invalid credentials"})
    end
  end

  # TODO
  # - investigate a way to verify the user wants to grant read/write/follow once scope handling is done
  def token_exchange(
        conn,
        %{"grant_type" => "password", "username" => name, "password" => password} = params
      ) do
    with %App{} = app <- get_app_from_request(conn, params),
         %User{} = user <- User.get_by_nickname_or_email(name),
         true <- Pbkdf2.checkpw(password, user.password_hash),
         {:ok, auth} <- Authorization.create_authorization(app, user),
         {:ok, token} <- Token.exchange_token(app, auth) do
      response = %{
        token_type: "Bearer",
        access_token: token.token,
        refresh_token: token.refresh_token,
        expires_in: 60 * 10,
        scope: "read write follow"
      }

      json(conn, response)
    else
      _error ->
        put_status(conn, 400)
        |> json(%{error: "Invalid credentials"})
    end
  end

  def token_exchange(
        conn,
        %{"grant_type" => "password", "name" => name, "password" => password} = params
      ) do
    params =
      params
      |> Map.delete("name")
      |> Map.put("username", name)

    token_exchange(conn, params)
  end

  def token_revoke(conn, %{"token" => token} = params) do
    with %App{} = app <- get_app_from_request(conn, params),
         %Token{} = token <- Repo.get_by(Token, token: token, app_id: app.id),
         {:ok, %Token{}} <- Repo.delete(token) do
      json(conn, %{})
    else
      _error ->
        # RFC 7009: invalid tokens [in the request] do not cause an error response
        json(conn, %{})
    end
  end

  defp fix_padding(token) do
    token
    |> Base.url_decode64!(padding: false)
    |> Base.url_encode64()
  end

  defp get_app_from_request(conn, params) do
    # Per RFC 6749, HTTP Basic is preferred to body params
    {client_id, client_secret} =
      with ["Basic " <> encoded] <- get_req_header(conn, "authorization"),
           {:ok, decoded} <- Base.decode64(encoded),
           [id, secret] <-
             String.split(decoded, ":")
             |> Enum.map(fn s -> URI.decode_www_form(s) end) do
        {id, secret}
      else
        _ -> {params["client_id"], params["client_secret"]}
      end

    if client_id && client_secret do
      Repo.get_by(
        App,
        client_id: client_id,
        client_secret: client_secret
      )
    else
      nil
    end
  end
end
