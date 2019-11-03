# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.ExNickname do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Pleroma.ExNickname
  alias Pleroma.Repo
  alias Pleroma.User

  schema "ex_nicknames" do
    belongs_to(:user, User, type: FlakeId.Ecto.CompatType)
    field(:nickname, :string)

    timestamps()
  end

  def changeset(ex_nickname, params \\ %{}) do
    ex_nickname
    |> cast(params, [:user_id, :nickname])
    |> validate_required([:user_id, :nickname])
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:nickname)
  end

  def get_user_by_ex_nickname(ex_nickname) do
    query =
      from(
        ex_nickname in ExNickname,
        where: ex_nickname.nickname == ^ex_nickname,
        join: user in assoc(ex_nickname, :user),
        preload: [user: user]
      )

    with %ExNickname{user: user} = _ex_nickname <- Repo.one(query) do
      user
    end
  end
end
