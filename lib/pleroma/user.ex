defmodule Pleroma.User do
  use Ecto.Schema

  import Ecto.{Changeset, Query}
  alias Pleroma.{Repo, User, Object, Web, Activity, Notification}
  alias Comeonin.Pbkdf2
  alias Pleroma.Web.{OStatus, Websub}
  alias Pleroma.Web.ActivityPub.{Utils, ActivityPub}

  schema "users" do
    field(:bio, :string)
    field(:email, :string)
    field(:name, :string)
    field(:nickname, :string)
    field(:password_hash, :string)
    field(:password, :string, virtual: true)
    field(:password_confirmation, :string, virtual: true)
    field(:following, {:array, :string}, default: [])
    field(:ap_id, :string)
    field(:avatar, :map)
    field(:local, :boolean, default: true)
    field(:info, :map, default: %{})
    field(:follower_address, :string)
    field(:search_distance, :float, virtual: true)
    has_many(:notifications, Notification)

    timestamps()
  end

  def avatar_url(user) do
    case user.avatar do
      %{"url" => [%{"href" => href} | _]} -> href
      _ -> "#{Web.base_url()}/images/avi.png"
    end
  end

  def banner_url(user) do
    case user.info["banner"] do
      %{"url" => [%{"href" => href} | _]} -> href
      _ -> "#{Web.base_url()}/images/banner.png"
    end
  end

  def ap_id(%User{nickname: nickname}) do
    "#{Web.base_url()}/users/#{nickname}"
  end

  def ap_followers(%User{} = user) do
    "#{ap_id(user)}/followers"
  end

  def follow_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:following])
    |> validate_required([:following])
  end

  def info_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:info])
    |> validate_required([:info])
  end

  def user_info(%User{} = user) do
    oneself = if user.local, do: 1, else: 0

    %{
      following_count: length(user.following) - oneself,
      note_count: user.info["note_count"] || 0,
      follower_count: user.info["follower_count"] || 0
    }
  end

  @email_regex ~r/^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/
  def remote_user_creation(params) do
    changes =
      %User{}
      |> cast(params, [:bio, :name, :ap_id, :nickname, :info, :avatar])
      |> validate_required([:name, :ap_id, :nickname])
      |> unique_constraint(:nickname)
      |> validate_format(:nickname, @email_regex)
      |> validate_length(:bio, max: 5000)
      |> validate_length(:name, max: 100)
      |> put_change(:local, false)

    if changes.valid? do
      case changes.changes[:info]["source_data"] do
        %{"followers" => followers} ->
          changes
          |> put_change(:follower_address, followers)

        _ ->
          followers = User.ap_followers(%User{nickname: changes.changes[:nickname]})

          changes
          |> put_change(:follower_address, followers)
      end
    else
      changes
    end
  end

  def update_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:bio, :name])
    |> unique_constraint(:nickname)
    |> validate_format(:nickname, ~r/^[a-zA-Z\d]+$/)
    |> validate_length(:bio, max: 5000)
    |> validate_length(:name, min: 1, max: 100)
  end

  def upgrade_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:bio, :name, :info, :follower_address, :avatar])
    |> unique_constraint(:nickname)
    |> validate_format(:nickname, ~r/^[a-zA-Z\d]+$/)
    |> validate_length(:bio, max: 5000)
    |> validate_length(:name, max: 100)
  end

  def password_update_changeset(struct, params) do
    changeset =
      struct
      |> cast(params, [:password, :password_confirmation])
      |> validate_required([:password, :password_confirmation])
      |> validate_confirmation(:password)

    if changeset.valid? do
      hashed = Pbkdf2.hashpwsalt(changeset.changes[:password])

      changeset
      |> put_change(:password_hash, hashed)
    else
      changeset
    end
  end

  def reset_password(user, data) do
    update_and_set_cache(password_update_changeset(user, data))
  end

  def register_changeset(struct, params \\ %{}) do
    changeset =
      struct
      |> cast(params, [:bio, :email, :name, :nickname, :password, :password_confirmation])
      |> validate_required([:email, :name, :nickname, :password, :password_confirmation])
      |> validate_confirmation(:password)
      |> unique_constraint(:email)
      |> unique_constraint(:nickname)
      |> validate_format(:nickname, ~r/^[a-zA-Z\d]+$/)
      |> validate_format(:email, @email_regex)
      |> validate_length(:bio, max: 1000)
      |> validate_length(:name, min: 1, max: 100)

    if changeset.valid? do
      hashed = Pbkdf2.hashpwsalt(changeset.changes[:password])
      ap_id = User.ap_id(%User{nickname: changeset.changes[:nickname]})
      followers = User.ap_followers(%User{nickname: changeset.changes[:nickname]})

      changeset
      |> put_change(:password_hash, hashed)
      |> put_change(:ap_id, ap_id)
      |> put_change(:following, [followers])
      |> put_change(:follower_address, followers)
    else
      changeset
    end
  end

  def follow(%User{} = follower, %User{info: info} = followed) do
    ap_followers = followed.follower_address

    if following?(follower, followed) or info["deactivated"] do
      {:error, "Could not follow user: #{followed.nickname} is already on your list."}
    else
      if !followed.local && follower.local && !ap_enabled?(followed) do
        Websub.subscribe(follower, followed)
      end

      following =
        [ap_followers | follower.following]
        |> Enum.uniq()

      follower =
        follower
        |> follow_changeset(%{following: following})
        |> update_and_set_cache

      {:ok, _} = update_follower_count(followed)

      follower
    end
  end

  def unfollow(%User{} = follower, %User{} = followed) do
    ap_followers = followed.follower_address

    if following?(follower, followed) and follower.ap_id != followed.ap_id do
      following =
        follower.following
        |> List.delete(ap_followers)

      {:ok, follower} =
        follower
        |> follow_changeset(%{following: following})
        |> update_and_set_cache

      {:ok, followed} = update_follower_count(followed)

      {:ok, follower, Utils.fetch_latest_follow(follower, followed)}
    else
      {:error, "Not subscribed!"}
    end
  end

  def following?(%User{} = follower, %User{} = followed) do
    Enum.member?(follower.following, followed.follower_address)
  end

  def get_by_ap_id(ap_id) do
    Repo.get_by(User, ap_id: ap_id)
  end

  def update_and_set_cache(changeset) do
    with {:ok, user} <- Repo.update(changeset) do
      Cachex.set(:user_cache, "ap_id:#{user.ap_id}", user)
      Cachex.set(:user_cache, "nickname:#{user.nickname}", user)
      Cachex.set(:user_cache, "user_info:#{user.id}", user_info(user))
      {:ok, user}
    else
      e -> e
    end
  end

  def invalidate_cache(user) do
    Cachex.del(:user_cache, "ap_id:#{user.ap_id}")
    Cachex.del(:user_cache, "nickname:#{user.nickname}")
  end

  def get_cached_by_ap_id(ap_id) do
    key = "ap_id:#{ap_id}"
    Cachex.get!(:user_cache, key, fallback: fn _ -> get_by_ap_id(ap_id) end)
  end

  def get_cached_by_nickname(nickname) do
    nickname = nickname_to_ascii(nickname)
    key = "nickname:#{nickname}"
    Cachex.get!(:user_cache, key, fallback: fn _ -> get_or_fetch_by_nickname(nickname) end)
  end

  def get_by_nickname(nickname) do
    Repo.get_by(User, nickname: nickname_to_ascii(nickname))
  end

  def get_by_nickname_or_email(nickname_or_email) do
    case user = Repo.get_by(User, nickname: nickname_to_ascii(nickname_or_email)) do
      %User{} -> user
      nil -> Repo.get_by(User, email: nickname_or_email)
    end
  end

  def get_cached_user_info(user) do
    key = "user_info:#{user.id}"
    Cachex.get!(:user_cache, key, fallback: fn _ -> user_info(user) end)
  end

  def fetch_by_nickname(nickname) do
    nickname = nickname_to_ascii(nickname)
    ap_try = ActivityPub.make_user_from_nickname(nickname)

    case ap_try do
      {:ok, user} -> {:ok, user}
      _ -> OStatus.make_user(nickname)
    end
  end

  def get_or_fetch_by_nickname(nickname) do
    with %User{} = user <- get_by_nickname(nickname) do
      user
    else
      _e ->
        with [_nick, _domain] <- String.split(nickname, "@"),
             {:ok, user} <- fetch_by_nickname(nickname) do
          user
        else
          _e -> nil
        end
    end
  end

  def get_followers_query(%User{id: id, follower_address: follower_address}) do
    from(
      u in User,
      where: fragment("? <@ ?", ^[follower_address], u.following),
      where: u.id != ^id
    )
  end

  def get_followers(user) do
    q = get_followers_query(user)

    {:ok, Repo.all(q)}
  end

  def get_friends_query(%User{id: id, following: following}) do
    from(
      u in User,
      where: u.follower_address in ^following,
      where: u.id != ^id
    )
  end

  def get_friends(user) do
    q = get_friends_query(user)

    {:ok, Repo.all(q)}
  end

  def increase_note_count(%User{} = user) do
    note_count = (user.info["note_count"] || 0) + 1
    new_info = Map.put(user.info, "note_count", note_count)

    cs = info_changeset(user, %{info: new_info})

    update_and_set_cache(cs)
  end

  def decrease_note_count(%User{} = user) do
    note_count = user.info["note_count"] || 0
    note_count = if note_count <= 0, do: 0, else: note_count - 1
    new_info = Map.put(user.info, "note_count", note_count)

    cs = info_changeset(user, %{info: new_info})

    update_and_set_cache(cs)
  end

  def update_note_count(%User{} = user) do
    note_count_query =
      from(
        a in Object,
        where: fragment("?->>'actor' = ? and ?->>'type' = 'Note'", a.data, ^user.ap_id, a.data),
        select: count(a.id)
      )

    note_count = Repo.one(note_count_query)

    new_info = Map.put(user.info, "note_count", note_count)

    cs = info_changeset(user, %{info: new_info})

    update_and_set_cache(cs)
  end

  def update_follower_count(%User{} = user) do
    follower_count_query =
      from(
        u in User,
        where: ^user.follower_address in u.following,
        where: u.id != ^user.id,
        select: count(u.id)
      )

    follower_count = Repo.one(follower_count_query)

    new_info = Map.put(user.info, "follower_count", follower_count)

    cs = info_changeset(user, %{info: new_info})

    update_and_set_cache(cs)
  end

  def get_notified_from_activity(%Activity{recipients: to}) do
    query =
      from(
        u in User,
        where: u.ap_id in ^to,
        where: u.local == true
      )

    Repo.all(query)
  end

  def get_recipients_from_activity(%Activity{recipients: to}) do
    query =
      from(
        u in User,
        where: u.ap_id in ^to,
        or_where: fragment("? && ?", u.following, ^to)
      )

    query = from(u in query, where: u.local == true)

    Repo.all(query)
  end

  def search(query, resolve) do
    # strip the beginning @ off if there is a query
    query = String.trim_leading(query, "@")

    if resolve do
      User.get_or_fetch_by_nickname(query)
    end

    inner =
      from(
        u in User,
        select_merge: %{
          search_distance:
            fragment(
              "? <-> (? || ?)",
              ^query,
              u.nickname,
              u.name
            )
        }
      )

    q =
      from(
        s in subquery(inner),
        order_by: s.search_distance,
        limit: 20
      )

    Repo.all(q)
  end

  def block(user, %{ap_id: ap_id}) do
    blocks = user.info["blocks"] || []
    new_blocks = Enum.uniq([ap_id | blocks])
    new_info = Map.put(user.info, "blocks", new_blocks)

    cs = User.info_changeset(user, %{info: new_info})
    update_and_set_cache(cs)
  end

  def unblock(user, %{ap_id: ap_id}) do
    blocks = user.info["blocks"] || []
    new_blocks = List.delete(blocks, ap_id)
    new_info = Map.put(user.info, "blocks", new_blocks)

    cs = User.info_changeset(user, %{info: new_info})
    update_and_set_cache(cs)
  end

  def blocks?(user, %{ap_id: ap_id}) do
    blocks = user.info["blocks"] || []
    Enum.member?(blocks, ap_id)
  end

  def local_user_query() do
    from(u in User, where: u.local == true)
  end

  def deactivate(%User{} = user) do
    new_info = Map.put(user.info, "deactivated", true)
    cs = User.info_changeset(user, %{info: new_info})
    update_and_set_cache(cs)
  end

  def delete(%User{} = user) do
    {:ok, user} = User.deactivate(user)

    # Remove all relationships
    {:ok, followers} = User.get_followers(user)

    followers
    |> Enum.each(fn follower -> User.unfollow(follower, user) end)

    {:ok, friends} = User.get_friends(user)

    friends
    |> Enum.each(fn followed -> User.unfollow(user, followed) end)

    query = from(a in Activity, where: a.actor == ^user.ap_id)

    Repo.all(query)
    |> Enum.each(fn activity ->
      case activity.data["type"] do
        "Create" ->
          ActivityPub.delete(Object.get_by_ap_id(activity.data["object"]["id"]))

        # TODO: Do something with likes, follows, repeats.
        _ ->
          "Doing nothing"
      end
    end)

    :ok
  end

  def get_or_fetch_by_ap_id(ap_id) do
    if user = get_by_ap_id(ap_id) do
      user
    else
      ap_try = ActivityPub.make_user_from_ap_id(ap_id)

      case ap_try do
        {:ok, user} ->
          user

        _ ->
          case OStatus.make_user(ap_id) do
            {:ok, user} -> user
            _ -> {:error, "Could not fetch by AP id"}
          end
      end
    end
  end

  # AP style
  def public_key_from_info(%{
        "source_data" => %{"publicKey" => %{"publicKeyPem" => public_key_pem}}
      }) do
    key =
      :public_key.pem_decode(public_key_pem)
      |> hd()
      |> :public_key.pem_entry_decode()

    {:ok, key}
  end

  # OStatus Magic Key
  def public_key_from_info(%{"magic_key" => magic_key}) do
    {:ok, Pleroma.Web.Salmon.decode_key(magic_key)}
  end

  def get_public_key_for_ap_id(ap_id) do
    with %User{} = user <- get_or_fetch_by_ap_id(ap_id),
         {:ok, public_key} <- public_key_from_info(user.info) do
      {:ok, public_key}
    else
      _ -> :error
    end
  end

  defp blank?(""), do: nil
  defp blank?(n), do: n

  def insert_or_update_user(data) do
    data =
      data
      |> Map.put(:name, blank?(data[:name]) || data[:nickname])

    cs = User.remote_user_creation(data)
    Repo.insert(cs, on_conflict: :replace_all, conflict_target: :nickname)
  end

  def ap_enabled?(%User{info: info}), do: info["ap_enabled"]
  def ap_enabled?(_), do: false

  def get_or_fetch(uri_or_nickname) do
    if String.starts_with?(uri_or_nickname, "http") do
      get_or_fetch_by_ap_id(uri_or_nickname)
    else
      get_or_fetch_by_nickname(uri_or_nickname)
    end
  end

  defp nickname_to_ascii("@" <> nickname) do
    "@" <> nickname_to_ascii(nickname)
  end

  defp nickname_to_ascii(nickname) do
    if Keyword.get(Application.get_env(:pleroma, :instance), :enable_idna) do
      nickname =
        nickname
        |> String.strip()

      case String.split(nickname, "@", parts: 2) do
        [user, domain] ->
          domain =
            domain
            |> to_charlist()
            |> :idna.to_ascii()
            |> to_string()

          user <> "@" <> domain

        [user] ->
          user
      end
    else
      nickname
    end
  end
end
