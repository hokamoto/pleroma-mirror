# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Repo do
  use Ecto.Repo,
    otp_app: :pleroma,
    adapter: Ecto.Adapters.Postgres,
    migration_timestamps: [type: :naive_datetime_usec]

  import Ecto.Query, only: [from: 2]

  defmodule Instrumenter do
    use Prometheus.EctoInstrumenter
  end

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end

  @doc "find resource based on prepared query"
  @spec find_resource(Ecto.Query.t()) :: {:ok, struct()} | {:error, :not_found}
  def find_resource(%Ecto.Query{} = query) do
    case one(query) do
      nil -> {:error, :not_found}
      resource -> {:ok, resource}
    end
  end

  def find_resource(_query), do: {:error, :not_found}

  @doc """
  Gets association from cache or loads if need

  ## Examples

    iex> Repo.get_assoc(token, :user)
    %User{}

  """
  @spec get_assoc(struct(), atom()) :: {:ok, struct()} | {:error, :not_found}
  def get_assoc(resource, association) do
    case preload(resource, association) do
      %{^association => assoc} when not is_nil(assoc) -> {:ok, assoc}
      _ -> {:error, :not_found}
    end
  end

  def paginate(query, %{page: page, page_size: page_size, total: true}) do
    %{
      items: paginate(query, %{page: page, page_size: page_size}),
      total: aggregate(query, :count, :id)
    }
  end

  def paginate(query, %{page: page, page_size: page_size}) do
    offset = (page - 1) * page_size

    from(q in query, limit: ^page_size, offset: ^offset)
    |> all()
  end
end
