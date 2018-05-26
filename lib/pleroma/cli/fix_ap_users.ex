defmodule Pleroma.CLI.FixApUsers do
  import Ecto.Query
  alias Pleroma.{Repo, User}

  def run() do
    {:ok, _} = Application.ensure_all_started(:pleroma)
    q =
      from(
        u in User,
        where: fragment("? @> ?", u.info, ^%{"ap_enabled" => true}),
        where: u.local == false
      )

    users = Repo.all(q)

    Enum.each(users, fn user ->
      try do
        IO.puts("Fetching #{user.nickname}")
        Pleroma.Web.ActivityPub.Transmogrifier.upgrade_user_from_ap_id(user.ap_id, false)
      rescue
        e -> IO.inspect(e)
      end
    end)
  end
end
