defmodule Pleroma.Repo.Migrations.InsertThreadRecipientsInActivities do
  use Ecto.Migration

  import Ecto.Query

  def change do
    # update root activities
    from(a in Pleroma.Activity)
    |> join(:inner, [activity], o in Pleroma.Object,
      on:
        fragment(
          "(?->>'id') = COALESCE((?)->'object'->> 'id', (?)->>'object')",
          o.data,
          activity.data,
          activity.data
        )
    )
    |> preload([activity, object], object: object)
    |> where(
      [a, o],
      fragment(
        "?->>'inReplyTo' IS NULL",
        o.data
      )
    )
    |> Pleroma.RepoStreamer.chunk_stream(512)
    |> Stream.each(fn chunk ->
      Enum.each(chunk, fn %Pleroma.Activity{} = activity ->
        thread_recipients =
          Pleroma.Web.ActivityPub.ActivityPub.get_thread_recipients(activity.recipients)

        Pleroma.Repo.update!(
          Ecto.Changeset.change(activity, thread_recipients: thread_recipients)
        )
      end)
    end)
    |> Stream.run()

    # update activities with in_reply_to

    from(a in Pleroma.Activity)
    |> join(:inner, [activity], o in Pleroma.Object,
      on:
        fragment(
          "(?->>'id') = COALESCE((?)->'object'->> 'id', (?)->>'object')",
          o.data,
          activity.data,
          activity.data
        )
    )
    |> preload([activity, object], object: object)
    |> where(
      [a, o],
      fragment(
        "?->>'inReplyTo' IS NOT NULL",
        o.data
      )
    )
    |> Pleroma.RepoStreamer.chunk_stream(512)
    |> Stream.each(fn chunk ->
      Enum.each(chunk, fn %Pleroma.Activity{} = activity ->
        in_reply_to = Pleroma.Activity.get_in_reply_to_activity(activity)

        thread_recipients =
          Pleroma.Web.ActivityPub.ActivityPub.get_thread_recipients(
            activity.recipients,
            in_reply_to
          )

        Pleroma.Repo.update!(
          Ecto.Changeset.change(activity, thread_recipients: thread_recipients)
        )
      end)
    end)
    |> Stream.run()
  end
end
