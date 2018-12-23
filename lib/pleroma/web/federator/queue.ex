defmodule Pleroma.Web.Federator.Queue do
  @moduledoc """
  """

  use Ecto.Schema
  import Ecto.{Changeset, Query}

  alias Pleroma.Repo

  schema "federation_queues" do
    field(:domain, :string)
    field(:success_at, :utc_datetime)
  end

  @doc """
  Refreshes time of successfully heard/sent an activity to a domain.
  """
  @spec refresh_timestamp(binary) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
  def refresh_timestamp(domain) do
    %__MODULE__{}
    |> cast(%{domain: domain, success_at: DateTime.utc_now()}, [:domain, :success_at])
    |> Repo.insert(on_conflict: [set: [success_at: DateTime.utc_now()]], conflict_target: :domain)
  end

  @doc """
  Checks last time we successfully heard/sent an activity to a domain.

  ## Arguments:
    `domain`
    `duration` - time (in sec) of period when assume that the domain is alive
  """
  @spec alive_domain?(binary(), integer()) :: boolean
  def alive_domain?(domain, duration) do
    query =
      from(
        q in __MODULE__,
        select: fragment("id"),
        where: q.domain == ^domain,
        where:
          fragment(
            "extract ('epoch' from age(current_timestamp, ?))  > ?",
            q.success_at,
            ^duration
          )
      )

    case Repo.one(query) do
      nil -> false
      _ -> true
    end
  end
end
