defmodule Mix.Tasks.RemoveStaff do
  use Mix.Task
  import Mix.Ecto
  alias Pleroma.{Repo, User}

  @shortdoc "Removes admin or moderator status from a user"
  def run([nickname | rest]) do
    ensure_started(Repo, [])

    with %User{local: true} = user <- User.get_by_nickname(nickname) do
      info =
        user.info
        |> Map.put("is_moderator", false)
        |> Map.put("is_admin", false)

      cng = User.info_changeset(user, %{info: info})
      user = Repo.update!(cng)

      IO.puts("Moderator status of #{nickname}: #{user.info["is_moderator"]}")
      IO.puts("Admin status of #{nickname}: #{user.info["is_admin"]}")
    else
      _ ->
        IO.puts("No local user #{nickname}")
    end
  end
end
