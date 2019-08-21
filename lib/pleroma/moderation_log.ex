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

  @spec insert_log(
          subject_type :: String.t(),
          action :: String.t(),
          actor :: User.t(),
          subject :: User.t()
        ) :: {:ok, User.t()} | {:error, any}
  def insert_log(subject_type, action, %User{id: user_id}, %User{id: subject_id}) do
    Repo.insert(%ModerationLog{
      user_id: user_id,
      data: %{
        subject_type: subject_type,
        subject_id: subject_id,
        action: action
      }
    })
  end

  @spec get_log_entry(
          subject_type :: String.t(),
          action :: String.t(),
          actor :: User.t(),
          subject :: User.t()
        ) :: String.t()
  def get_log_entry(
        "user",
        action,
        %User{nickname: actor_nickname} = actor,
        %User{nickname: subject_nickname} = subject
      ) do
    %{
      actor: actor,
      action: action,
      subject: subject,
      message: "@#{actor_nickname} performed '#{action}' action on user @#{subject_nickname}"
    }
  end
end
