defmodule Pleroma.Web.Mfc.Utils do
  alias Pleroma.User
  alias Pleroma.Repo
  import Ecto.Query
  require Logger

  defp get_ids_from_body(body) do
    with {:ok, %{"err" => 0, "data" => data}} <- Jason.decode(body) do
      Enum.map(data, fn %{"id" => id} -> to_string(id) end)
    else
      _ -> []
    end
  end

  defp get_ids_for_url(url) do
    with {:ok, %{status: 200, body: body}} <- Tesla.get(url),
         ids <- get_ids_from_body(body) do
      ids
    else
      _ -> []
    end
  end

  def sync_follows(%{mfc_id: mfc_id} = user) do
    with friends <- get_ids_for_url("#{Pleroma.Config.get([:mfc, :friends_endpoint])}/#{mfc_id}"),
         bookmarks <-
           get_ids_for_url("#{Pleroma.Config.get([:mfc, :bookmarks_endpoint])}/#{mfc_id}"),
         following <-
           get_ids_for_url("#{Pleroma.Config.get([:mfc, :following_endpoint])}&user_id=#{mfc_id}"),
         candidates <- Enum.uniq(friends ++ bookmarks ++ following) do
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
               |> Repo.insert() do
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
