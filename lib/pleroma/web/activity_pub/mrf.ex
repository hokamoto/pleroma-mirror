# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.ActivityPub.MRF do
  @callback filter(Map.t()) :: {:ok | :reject, Map.t()}
  @callback serialise_config(Map.t()) :: Map.t()
  @callback deserialise_config(Map.t()) :: Map.t()

  alias Pleroma.Repo
  alias Pleroma.Web.ActiviyPub.MRF.KeywordPolicy, as: KP
  alias __MODULE__
  import Ecto.Changeset
  import Ecto.Query
  use Ecto.Schema

  @primary_key {:id, Pleroma.FlakeId, autogenerate: true}
  schema "mrf_policies" do
    field(:data, :map)
    field(:policy, :string)

    timestamps()
  end

  @doc false
  def changeset(schema, attrs) do
    schema
    |> cast(attrs, [:policy, :data])
    |> validate_required([:policy, :data])
  end

  @doc """
  This function takes a map of two fields:

  1. `:policy`, which is a PascalCase string representing the name of the policy.
     ex: "KeywordPolicy", "HellThread", etc.

  2. `:data`, which is the actual policy data. This field should be converted from the appropriate struct beforehand. Upstream code should normalise this data with a struct, but need to convert it to a map before sending it to `save_policy`, in order to strip the unnecessary fields.

  This function performs an upsert in the database and in the application environment. New values become instantaneously accessible with `Pleroma.Config.get`
  """
  @spec save_policy(%{policy: String.t(), data: map()}) :: :ok | {:error, String.t()}
  def save_policy(%{policy: policy} = attrs) do
    case policy do
      "KeywordPolicy" -> Pleroma.Config.put(:mrf_keyword, attrs.data)
      "RejectNonPublic" -> Pleroma.Config.put(:mrf_rejectnonpublic, attrs.data)
      "NormalizeMarkup" -> Pleroma.Config.put(:mrf_normalize_markup, attrs.data)
      "HellThread" -> Pleroma.Config.put(:mrf_hellthread, attrs.data)
      "Simple" -> Pleroma.Config.put(:mrf_simple, attrs.data)
      _ -> {:error, "Wrong MRF Policy name!"}
    end

    changeset = changeset(%MRF{}, attrs)
    Repo.insert(changeset, on_conflict: :replace_all, conflict_target: :data)
  end

  def config_update do
    # Put other policies in there
    for policy <- [KP] do
      spawn(fn -> policy.config_update() end)
    end
  end

  def filter(object) do
    get_policies()
    |> Enum.reduce({:ok, object}, fn
      policy, {:ok, object} ->
        policy.filter(object)

      _, error ->
        error
    end)
  end

  def get_policies() do
    Application.get_env(:pleroma, :instance, [])
    |> Keyword.get(:rewrite_policy, [])
    |> get_policies()
  end

  defp get_policies(policy) when is_atom(policy), do: [policy]
  defp get_policies(policies) when is_list(policies), do: policies
  defp get_policies(_), do: []
end
