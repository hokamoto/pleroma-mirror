defmodule Mix.Tasks.Mfc.PushAccountsToShare do
  use Mix.Task
  alias Mix.Tasks.Pleroma.Common

  import Ecto.Query

  require Logger

  def run([]) do
    Common.start_pleroma()

    q =
      from(u in Pleroma.User,
        where: u.local == true,
        where: not is_nil(u.nickname)
      )

    q
    |> Pleroma.Repo.all()
    |> Enum.each(fn user ->
      Logger.info("Pushing #{user.nickname}, mfc id #{user.mfc_id}")
      res = Pleroma.Web.Mfc.Api.notify_account_creation(user)
      Logger.info("Result: #{inspect(res)}")
    end)
  end
end
