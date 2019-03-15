defmodule Pleroma.Web.Mfc.Utils do
  alias Pleroma.User
  alias Pleroma.Repo
  alias Pleroma.Web.Mfc.Api
  import Ecto.Query
  require Logger

  def model_online?(user) do
    {:ok, state} = Cachex.get(:model_state_cache, user.nickname)

    !!state
  end

  defp parse_model_states_body(body) do
    try do
      model_states =
        body
        |> String.split("<br>")
        |> Enum.drop(1)
        |> Enum.reduce(%{}, fn line, acc ->
          case String.split(line, ",") do
            [name, state, server, room_count] ->
              acc
              |> Map.put(name, %{state: state, server: server, room_count: room_count})

            _ ->
              acc
          end
        end)

      {:ok, model_states}
    rescue
      e -> e
    end
  end

  defp filter_public_streaming(model_states) do
    model_states
    |> Enum.filter(fn {_, %{state: state}} -> state != "90" end)
    |> (&{:ok, &1}).()
  end

  def update_online_status do
    endpoint = Pleroma.Config.get([:mfc, :models_state_endpoint])

    with {:ok, %{status: 200, body: body}} <- Tesla.get(endpoint),
         {:ok, model_states} <- parse_model_states_body(body),
         {:ok, model_states} <- filter_public_streaming(model_states) do
      Cachex.put_many(:model_state_cache, model_states)
    else
      e -> Logger.error("Could not fetch models' online state: #{inspect(e)}")
    end
  end

  defp get_ids_from_body(body) do
    with {:ok, %{"err" => 0, "data" => data}} <- Jason.decode(body) do
      Enum.map(data, fn
        %{"id" => id} -> to_string(id)
        %{"following_id" => id} -> to_string(id)
      end)
    else
      _ -> []
    end
  end

  defp get_ids_for_url(url, params) do
    with {:ok, %{status: 200, body: body}} <- Tesla.get(url, query: params),
         ids <- get_ids_from_body(body) do
      ids
    else
      _ -> []
    end
  end

  def sync_follows(user, params \\ %{})

  def sync_follows(%{mfc_id: mfc_id, info: %{mfc_follower_sync: true}} = user, params) do
    with friends <-
           get_ids_for_url("#{Pleroma.Config.get([:mfc, :friends_endpoint])}/#{mfc_id}", params),
         bookmarks <-
           get_ids_for_url("#{Pleroma.Config.get([:mfc, :bookmarks_endpoint])}/#{mfc_id}", params),
         twitter_friends <-
           get_ids_for_url(
             "#{Pleroma.Config.get([:mfc, :twitter_friends_endpoint])}/#{mfc_id}",
             params
           ),
         following <- Api.get_following_for_mfc_id(mfc_id, params),
         candidates <- Enum.uniq(friends ++ bookmarks ++ following ++ twitter_friends) do
      query =
        from(u in User,
          where: u.mfc_id in ^candidates
        )

      followeds =
        query
        |> Repo.all()

      {:ok, user} = User.follow_all(user, followeds)
      user
    end
  end

  def sync_follows(user, _params), do: user

  def tags_for_level(2), do: ["mfc_premium_member"]
  def tags_for_level(4), do: ["mfc_model"]
  def tags_for_level(_), do: []

  def get_or_create_mfc_user(mfc_id, nickname, avatar_url \\ nil) do
    mfc_id = to_string(mfc_id)
    user = Repo.get_by(User, mfc_id: mfc_id)

    cond do
      user ->
        user
        |> maybe_update_avatar(avatar_url)

      nickname ->
        with {:ok, user} <-
               User.mfc_register_changeset(%User{info: %{}}, %{
                 nickname: nickname,
                 mfc_id: mfc_id,
                 name: nickname
               })
               |> User.register() do
          Task.start(fn ->
            Pleroma.Web.Mfc.Utils.sync_follows(user)
          end)

          if Pleroma.Config.get([:mfc, :enable_account_creation_sync]) do
            Task.start(fn ->
              Pleroma.Web.Mfc.Api.notify_account_creation(user)
            end)
          end

          user
          |> maybe_update_avatar(avatar_url)
        end

      true ->
        nil
    end
  end

  def maybe_update_avatar(user, avatar_url) when is_list(avatar_url) do
    avatar_url = Enum.join(avatar_url, "300x300")

    cond do
      User.avatar_url(user) == avatar_url ->
        user

      is_map(user.avatar) && user.avatar["source"] != "mfc" ->
        user

      true ->
        data = %{
          "type" => "Image",
          "url" => [
            %{
              "type" => "Link",
              "href" => avatar_url
            }
          ],
          "name" => "Avatar",
          "source" => "mfc"
        }

        with cng <- Ecto.Changeset.change(user, %{avatar: data}),
             {:ok, user} <- User.update_and_set_cache(cng) do
          user
        else
          _ -> user
        end
    end
  end

  def maybe_update_avatar(user, _), do: user
end
