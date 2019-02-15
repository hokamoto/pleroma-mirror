defmodule Mix.Tasks.Mfc.PushAccountsToShare do
  use Mix.Task
  alias Mix.Tasks.Pleroma.Common

  import Ecto.Query

  def run([]) do
    Common.start_pleroma()

    q =
      from(u in Pleroma.User,
        where: u.local == true,
        where: not is_nil(u.nickname)
      )

    users =
      q
      |> Pleroma.Repo.all()

    IO.inspect("Pushing #{length(users)} users")

    users
    |> Enum.each(fn user ->
      IO.inspect("Pushing #{user.nickname}, mfc id #{user.mfc_id}")
      res = Pleroma.Web.Mfc.Api.notify_account_creation(user)
      IO.inspect("Result: #{inspect(res)}")
      IO.inspect("waiting a second")
      :timer.sleep(1000)
    end)
  end
end
