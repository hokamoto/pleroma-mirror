defmodule Mix.Tasks.SetAdmin do
  use Mix.Task
  import Mix.Ecto
  alias Pleroma.{Repo, User}

  @shortdoc "Set admin status"
  def run([nickname | rest]) do
    ensure_started(Repo, [])

    admin =
      case rest do
        [admin] -> admin == "true"
        _ -> true
      end

    with %User{local: true} = user <- User.get_by_nickname(nickname) do
      info =
        user.info
        |> Map.put("is_admin", !!admin)

      cng = User.info_changeset(user, %{info: info})
      user = Repo.update!(cng)

      IO.puts("Admin status of #{nickname}: #{user.info["is_admin"]}")
    else
      _ ->
        IO.puts("No local user #{nickname}")
    end
  end
end
