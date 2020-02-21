defmodule Pleroma.Web.FedSockets.IngesterWorker do
  use Pleroma.Workers.WorkerHelper, queue: "ingestion_queue"

  alias Pleroma.Object.Fetcher
  alias Pleroma.User
  alias Pleroma.Web.ActivityPub.Utils
  alias Pleroma.Web.Federator

  @impl Oban.Worker
  def perform(%{"op" => "ingest", "object" => ingestee}, _job) do
    IO.puts("#{inspect(self())} - starting ingestion")

    try do
      ingestee
      |> Jason.decode!()
      |> do_ingestion()

      IO.puts("#{inspect(self())} - finished ingestion")
    rescue
      e ->
        IO.inspect(e, label: "#{inspect(self())} - ingestion error")
    end
  end

  defp do_ingestion(%{"nickname" => nickname} = params) do
    with %User{} = recipient <- User.get_cached_by_nickname(nickname),
         {:ok, %User{} = actor} <- User.get_or_fetch_by_ap_id(params["actor"]),
         true <- Utils.recipient_in_message(recipient, actor, params),
         params <- Utils.maybe_splice_recipient(recipient.ap_id, params) do
      case Federator.incoming_ap_doc(params) do
        {:error, reason} ->
          {:error, reason}

        {:ok, object} ->
          {:ok, object}
      end
    end
  end

  defp do_ingestion(%{"type" => "Create", "object" => %{"id" => object_id}}) do
    case Fetcher.fetch_object_from_id(object_id) do
      {:error, reason} ->
        {:error, reason}

      {:ok, object} ->
        {:ok, object}
    end
  end

  defp do_ingestion(params) do
    case Federator.incoming_ap_doc(params) do
      {:error, reason} ->
        {:error, reason}

      {:ok, object} ->
        {:ok, object}
    end
  end
end
