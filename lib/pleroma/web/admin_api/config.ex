# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.AdminAPI.Config do
  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__
  alias Pleroma.Repo

  @type t :: %__MODULE__{}

  schema "config" do
    field(:key, :string)
    field(:value, :binary)

    timestamps()
  end

  @spec get_by_key(String.t()) :: Config.t() | nil
  def get_by_key(key), do: Repo.get_by(Config, key: key)

  @spec changeset(Config.t(), map()) :: Changeset.t()
  def changeset(config, params \\ %{}) do
    config
    |> cast(params, [:key, :value])
    |> validate_required([:key, :value])
    |> unique_constraint(:key)
  end

  @spec create(map()) :: {:ok, Config.t()} | {:error, Changeset.t()}
  def create(%{key: key, value: value}) do
    %Config{}
    |> changeset(%{key: key, value: prepare_value(value)})
    |> Repo.insert()
  end

  @spec update(Config.t(), map()) :: {:ok, Config} | {:error, Changeset.t()}
  def update(%Config{} = config, %{value: value}) do
    config
    |> change(value: prepare_value(value))
    |> Repo.update()
  end

  @spec update_or_create(map()) :: {:ok, Config.t()} | {:error, Changeset.t()}
  def update_or_create(%{key: key} = params) do
    with %Config{} = config <- Config.get_by_key(key) do
      Config.update(config, params)
    else
      nil -> Config.create(params)
    end
  end

  @spec delete(String.t()) :: {:ok, Config.t()} | {:error, Changeset.t()}
  def delete(key) do
    with %Config{} = config <- Config.get_by_key(key) do
      Repo.delete(config)
    else
      nil -> {:error, "Config with key #{key} not found"}
    end
  end

  @spec convert_value(binary()) :: term()
  def convert_value(value), do: :erlang.binary_to_term(value)

  @spec prepare_value(String.t()) :: binary()
  def prepare_value(value), do: :erlang.term_to_binary(value)
end
