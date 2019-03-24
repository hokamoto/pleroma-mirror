defmodule Mix.Tasks.Mfc.PushNotesToShare do
  use Mix.Task
  alias Mix.Tasks.Pleroma.Common

  import Ecto.Query

  def run([]) do
    Common.start_pleroma()

    q =
      from(a in Pleroma.Activity,
        where: fragment("?->>'type' = ?", a.data, "Create"),
        where:
          fragment("activity_visibility(?, ?, ?) = ?", a.actor, a.recipients, a.data, "public")
      )

    activities =
      q
      |> Pleroma.Repo.all()

    IO.inspect("Pushing #{length(activities)} activities")

    activities
    |> Enum.each(fn activity ->
      IO.inspect("Pushing #{activity.id}")
      res = Pleroma.Web.Mfc.Api.notify_status_creation(activity)
      IO.inspect("Result: #{inspect(res)}")
      IO.inspect("waiting 200ms")
      :timer.sleep(200)
    end)
  end
end
