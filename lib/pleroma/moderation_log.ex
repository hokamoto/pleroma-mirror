defmodule Pleroma.ModerationLog do
  use Ecto.Schema
  alias Pleroma.FlakeId
  alias Pleroma.ModerationLog
  alias Pleroma.Repo
  alias Pleroma.User

  schema "moderation_log" do
    field(:data, :map)
    belongs_to(:user, User, type: FlakeId)

    timestamps()
  end

  @spec log_user_delete(actor :: User.t(), subject :: User.t()) :: {:ok, User.t()} | {:error, any}
  def log_user_delete(%User{id: user_id}, %User{id: subject_id}) do
    Repo.insert(%ModerationLog{
      user_id: user_id,
      data: %{
        subject_type: "user",
        subject_id: subject_id,
        action: "delete"
      }
    })
  end

  @spec log_entry(
          subject_type :: String.t(),
          action :: String.t(),
          actor :: User.t(),
          subject :: User.t()
        ) :: String.t()
  def log_entry(
        "user",
        action,
        %User{nickname: actor_nickname},
        %User{nickname: subject_nickname}
      ) do
    "@#{actor_nickname} performed '#{action}' action on user @#{subject_nickname}"
  end
end
