defmodule Pleroma.Web.Mfc.Api do
  use Tesla
  plug(Tesla.Middleware.FormUrlencoded)

  def authenticated_request(method, url, data) do
    hmac_data = generate_hmac_data()

    data =
      data
      |> Map.merge(hmac_data)

    case method do
      :get -> request(method: method, url: url, query: data)
      _ -> request(method: method, url: url, body: data)
    end
  end

  def generate_hmac_data(time \\ nil, service_id \\ "2", client_ip \\ nil, secret \\ nil) do
    secret = secret || Pleroma.Config.get([:mfc, :share_hmac_secret])
    time = time || DateTime.utc_now() |> DateTime.to_unix() |> to_string()
    client_ip = client_ip || Pleroma.Config.get([:mfc, :server_ip])

    hashed_string = [client_ip, service_id, time] |> Enum.join()

    hmac =
      :sha256
      |> :crypto.hmac(secret, hashed_string)
      |> Base.encode16(case: :lower)

    %{
      gh: hmac,
      t: time,
      service_id: service_id
    }
  end

  def notify_account_creation(%Pleroma.User{
        mfc_id: mfc_id,
        inserted_at: inserted_at,
        nickname: nickname
      }) do
    url = Pleroma.Config.get([:mfc, :account_creation_endpoint])

    authenticated_request(:post, url, %{
      username: nickname,
      mfc_id: mfc_id,
      social_created_at: inserted_at |> DateTime.from_naive!("Etc/UTC") |> DateTime.to_unix()
    })
  end

  def notify_status_creation(activity) do
    url = Pleroma.Config.get([:mfc, :status_creation_endpoint])
    user = Pleroma.User.get_cached_by_ap_id(activity.actor)
    content = Pleroma.Web.MastodonAPI.StatusView.render_content(activity.data["object"])

    authenticated_request(:post, url, %{
      mfc_id: user.mfc_id,
      last_post_date:
        activity.inserted_at |> DateTime.from_naive!("Etc/UTC") |> DateTime.to_unix(),
      last_post_content: content,
      status_count: user.info.note_count,
      last_post_id: activity.id,
      last_post_url: activity.data["object"]["id"],
      in_reply_to_id: activity.data["object"]["inReplyToStatusId"]
    })
  end

  def notify_status_deletion(activity, deleter, deleted_at) do
    url = Pleroma.Config.get([:mfc, :status_deletion_endpoint])
    user = Pleroma.User.get_cached_by_ap_id(activity.actor)

    authenticated_request(:post, url, %{
      mfc_id: user.mfc_id,
      deleted_by_id: deleter.mfc_id,
      post_id: activity.id,
      deleted_at: deleted_at |> DateTime.from_naive!("Etc/UTC") |> DateTime.to_unix(),
    })
  end

  def get_following_for_mfc_id(id, params \\ %{}) do
    url = Pleroma.Config.get([:mfc, :following_endpoint_v2])

    with {:ok, %{status: 200, body: body}} <-
           authenticated_request(:get, url, Map.merge(params, %{user_id: id})),
         {:ok, %{"data" => data}} <- Jason.decode(body) do
      data
      |> Enum.map(fn %{"id" => id} -> to_string(id) end)
    else
      _ -> []
    end
  end
end
