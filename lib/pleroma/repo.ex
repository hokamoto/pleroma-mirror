# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Repo do
  use Ecto.Repo,
    otp_app: :pleroma,
    adapter: Ecto.Adapters.Postgres,
    migration_timestamps: [type: :naive_datetime_usec]

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

  @doc """
  Gets association from cache or loads if need
  """
  @spec get_assoc(struct(), atom()) :: {:ok, struct()} | {:error, :not_found}
  def get_assoc(model, association) do
    case Map.get(model, association) do
      %Ecto.Association.NotLoaded{} -> load_assoc(model, association)
      nil -> {:error, :not_found}
      assoc -> {:ok, assoc}
    end
  end

  defp load_assoc(model, association) do
    case __MODULE__.one(Ecto.assoc(model, association)) do
      nil -> {:error, :not_found}
      association -> {:ok, association}
    end
  end
end
