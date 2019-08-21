defmodule Pleroma.ModerationLog do
  use Ecto.Schema
  alias Pleroma.ModerationLog
  alias Pleroma.Repo
  alias Pleroma.User

  schema "moderation_log" do
    field(:data, :map)

    timestamps()
  end

  @spec insert_log(%{actor: User, subject: User, action: String.t()}) ::
          {:ok, ModerationLog} | {:error, any}
  def insert_log(%{actor: %User{} = actor, subject: %User{} = subject, action: action}) do
    Repo.insert(%ModerationLog{
      data: %{
        actor: user_to_map(actor),
        action: action,
        subject: user_to_map(subject)
      }
    })
  end

  def insert_log(%{
        actor: %User{} = actor,
        followed: %User{} = followed,
        follower: %User{} = follower,
        action: "follow"
      }) do
    Repo.insert(%ModerationLog{
      data: %{
        actor: user_to_map(actor),
        action: "follow",
        followed: user_to_map(followed),
        follower: user_to_map(follower)
      }
    })
  end

  def insert_log(%{
        actor: %User{} = actor,
        followed: %User{} = followed,
        follower: %User{} = follower,
        action: "unfollow"
      }) do
    Repo.insert(%ModerationLog{
      data: %{
        actor: user_to_map(actor),
        action: "unfollow",
        followed: user_to_map(followed),
        follower: user_to_map(follower)
      }
    })
  end

  def insert_log(%{
        actor: %User{} = actor,
        nicknames: nicknames,
        tags: tags,
        action: action
      }) do
    Repo.insert(%ModerationLog{
      data: %{
        actor: user_to_map(actor),
        nicknames: nicknames,
        tags: tags,
        action: action
      }
    })
  end

  defp user_to_map(%User{} = user) do
    user
    |> Map.from_struct()
    |> Map.take([:id, :nickname])
    |> Map.put(:type, "user")
  end

  def get_log_entry_message(%ModerationLog{
        inserted_at: time,
        data: %{
          "actor" => %{"nickname" => actor_nickname},
          "action" => action,
          "followed" => %{"nickname" => followed_nickname},
          "follower" => %{"nickname" => follower_nickname}
        }
      }) do
    "[#{time}] @#{actor_nickname} made @#{follower_nickname} #{action} @#{followed_nickname}"
  end

  @spec get_log_entry_message(ModerationLog) :: String.t()
  def get_log_entry_message(%ModerationLog{
        inserted_at: time,
        data: %{
          "actor" => %{"nickname" => actor_nickname},
          "action" => "delete",
          "subject" => %{"nickname" => subject_nickname, "type" => "user"}
        }
      }) do
    "[#{time}] @#{actor_nickname} deleted user @#{subject_nickname}"
  end

  @spec get_log_entry_message(ModerationLog) :: String.t()
  def get_log_entry_message(%ModerationLog{
        inserted_at: time,
        data: %{
          "actor" => %{"nickname" => actor_nickname},
          "action" => "create",
          "subject" => %{"nickname" => subject_nickname, "type" => "user"}
        }
      }) do
    "[#{time}] @#{actor_nickname} created user @#{subject_nickname}"
  end

  @spec get_log_entry_message(ModerationLog) :: String.t()
  def get_log_entry_message(%ModerationLog{
        inserted_at: time,
        data: %{
          "actor" => %{"nickname" => actor_nickname},
          "action" => "activate",
          "subject" => %{"nickname" => subject_nickname, "type" => "user"}
        }
      }) do
    "[#{time}] @#{actor_nickname} activated user @#{subject_nickname}"
  end

  @spec get_log_entry_message(ModerationLog) :: String.t()
  def get_log_entry_message(%ModerationLog{
        inserted_at: time,
        data: %{
          "actor" => %{"nickname" => actor_nickname},
          "action" => "deactivate",
          "subject" => %{"nickname" => subject_nickname, "type" => "user"}
        }
      }) do
    "[#{time}] @#{actor_nickname} deactivated user @#{subject_nickname}"
  end

  @spec get_log_entry_message(ModerationLog) :: String.t()
  def get_log_entry_message(%ModerationLog{
        inserted_at: time,
        data: %{
          "actor" => %{"nickname" => actor_nickname},
          "nicknames" => nicknames,
          "tags" => tags,
          "action" => "tag"
        }
      }) do
    nicknames_string =
      nicknames
      |> Enum.map(&"@#{&1}")
      |> Enum.join(", ")

    tags_string = tags |> Enum.join(", ")

    "[#{time}] @#{actor_nickname} tagged users: #{nicknames_string} with #{tags_string}"
  end

  @spec get_log_entry_message(ModerationLog) :: String.t()
  def get_log_entry_message(%ModerationLog{
        inserted_at: time,
        data: %{
          "actor" => %{"nickname" => actor_nickname},
          "nicknames" => nicknames,
          "tags" => tags,
          "action" => "untag"
        }
      }) do
    nicknames_string =
      nicknames
      |> Enum.map(&"@#{&1}")
      |> Enum.join(", ")

    tags_string = tags |> Enum.join(", ")

    "[#{time}] @#{actor_nickname} removed tags: #{tags_string} from users: #{nicknames_string}"
  end
end
