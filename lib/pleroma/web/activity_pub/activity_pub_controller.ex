defmodule Pleroma.Web.ActivityPub.ActivityPubController do
  use GenServer, :cast
  use Pleroma.Web, :controller
  alias Pleroma.{User, Repo, Object, Activity}
  alias Pleroma.Web.ActivityPub.{ObjectView, UserView, Transmogrifier}
  alias Pleroma.Web.ActivityPub.ActivityPub
  alias Pleroma.Web.Federator

  require Logger

  action_fallback(:errors)

  def user(conn, %{"nickname" => nickname}) do
    with %User{} = user <- User.get_cached_by_nickname(nickname),
         {:ok, user} <- Pleroma.Web.WebFinger.ensure_keys_present(user) do
      conn
      |> put_resp_header("content-type", "application/activity+json")
      |> json(UserView.render("user.json", %{user: user}))
    end
  end

  def object(conn, %{"uuid" => uuid}) do
    with ap_id <- o_status_url(conn, :object, uuid),
         %Object{} = object <- Object.get_cached_by_ap_id(ap_id) do
      conn
      |> put_resp_header("content-type", "application/activity+json")
      |> json(ObjectView.render("object.json", %{object: object}))
    end
  end

  def following(conn, %{"nickname" => nickname, "page" => page}) do
    with %User{} = user <- User.get_cached_by_nickname(nickname),
         {:ok, user} <- Pleroma.Web.WebFinger.ensure_keys_present(user) do
      {page, _} = Integer.parse(page)

      conn
      |> put_resp_header("content-type", "application/activity+json")
      |> json(UserView.render("following.json", %{user: user, page: page}))
    end
  end

  def following(conn, %{"nickname" => nickname}) do
    with %User{} = user <- User.get_cached_by_nickname(nickname),
         {:ok, user} <- Pleroma.Web.WebFinger.ensure_keys_present(user) do
      conn
      |> put_resp_header("content-type", "application/activity+json")
      |> json(UserView.render("following.json", %{user: user}))
    end
  end

  def followers(conn, %{"nickname" => nickname, "page" => page}) do
    with %User{} = user <- User.get_cached_by_nickname(nickname),
         {:ok, user} <- Pleroma.Web.WebFinger.ensure_keys_present(user) do
      {page, _} = Integer.parse(page)

      conn
      |> put_resp_header("content-type", "application/activity+json")
      |> json(UserView.render("followers.json", %{user: user, page: page}))
    end
  end

  def followers(conn, %{"nickname" => nickname}) do
    with %User{} = user <- User.get_cached_by_nickname(nickname),
         {:ok, user} <- Pleroma.Web.WebFinger.ensure_keys_present(user) do
      conn
      |> put_resp_header("content-type", "application/activity+json")
      |> json(UserView.render("followers.json", %{user: user}))
    end
  end

  def outbox(conn, %{"nickname" => nickname, "max_id" => max_id}) do
    with %User{} = user <- User.get_cached_by_nickname(nickname),
         {:ok, user} <- Pleroma.Web.WebFinger.ensure_keys_present(user) do
      conn
      |> put_resp_header("content-type", "application/activity+json")
      |> json(UserView.render("outbox.json", %{user: user, max_id: max_id}))
    end
  end

  def outbox(conn, %{"nickname" => nickname}) do
    outbox(conn, %{"nickname" => nickname, "max_id" => nil})
  end

  # TODO: Ensure that this inbox is a recipient of the message
  # WV: this does not work for any of my Mastodon accounts!
  #def inbox(%{assigns: %{valid_signature: true}} = conn, params) do
  #  Federator.enqueue(:incoming_ap_doc, params)
  #  json(conn, "ok")
  #end

# WV this is where I could hook in a "bot" to create PNGs from coordinates
# WV What I have is: I can detect the nickname and get the content
# WV The content is HTML so I'd need some additional parsing before I can use my own parser
# WV But what I want to do is of course put this functionality somewhere else and if possible make it asynchronous
  def inbox(conn, params) do
    headers = Enum.into(conn.req_headers, %{})
    #  IO.inspect(params)
    res = if is_map(params) and Map.has_key?(params,"nickname") and Map.has_key?(params,"object") do
        if params["nickname"] == "pixelbot" do
          if is_map(params["object"]) and Map.has_key?(params["object"],"content") do
            content =  params["object"]["content"]
            Logger.warn("Content: " <> content )
            GenServer.cast(Pleroma.Bots.PixelBot,content)
            :ok
          else
            Logger.warn("params[\"object\"] is not a map" )
            #IO.inspect(params)
            :nok
          end
        else
          Logger.warn("Nickname: <" <> params["nickname"]<>">")
          :nok
        end
    else
      #IO.inspect(params)
      :nok
    end
    Logger.info("HERE!")
    if !String.contains?(headers["signature"] || "", params["actor"]) do
      Logger.info("Signature not from author, relayed message, fetching from source")
      ActivityPub.fetch_object_from_id(params["object"]["id"])
    else
      Logger.info("Signature error")
      Logger.info("Could not validate #{params["actor"]}")
      Logger.info(inspect(conn.req_headers))
      # WV: do it anyway
      Logger.warn("IGNORING Signature error")
      #
      Federator.enqueue(:incoming_ap_doc, params)
    end

    json(conn, "ok")
  end

  def errors(conn, _e) do
    conn
    |> put_status(500)
    |> json("error")
  end
end
