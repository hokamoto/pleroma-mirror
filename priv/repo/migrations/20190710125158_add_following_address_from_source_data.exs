defmodule Pleroma.Storage.Repo.Migrations.AddFollowingAddressFromSourceData do
  use Ecto.Migration
  import Ecto.Query
  alias Pleroma.User
  require Logger

  def change do
    query =
      User.Query.build(%{
        external: true,
        legacy_active: true,
        order_by: :id
      })
      |> select([u], struct(u, [:id, :ap_id, :info]))

    Pleroma.Storage.Repo.stream(query)
    |> Enum.each(fn
      %{info: %{source_data: source_data}} = user ->
        user
        |> Ecto.Changeset.cast(
          %{following_address: source_data["following"]},
          [:following_address]
        )
        |> Pleroma.Storage.Repo.update()

      user ->
        Logger.warn("User #{user.id} / #{user.nickname} does not seem to have source_data")
    end)
  end
end
