# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.FederationFailure do
  use Ecto.Schema

  alias Pleroma.Activity
  alias Pleroma.FederationFailure
  alias Pleroma.FlakeId
  alias Pleroma.Repo

  import Ecto.Changeset
  import Ecto.Query

  @type t :: %__MODULE__{}

  schema "federation_failures" do
    field(:recipient, :string)
    field(:transport, :string)
    field(:data, :map)
    field(:retries_count, :integer, default: 0)

    belongs_to(:activity, Activity, type: FlakeId)

    timestamps()
  end

  def changeset(federation_failure, params \\ %{}) do
    federation_failure
    |> cast(params, [:activity_id, :recipient, :transport, :data, :retries_count])
    |> validate_required([:activity_id, :recipient, :transport, :data])
    |> foreign_key_constraint(:activity_id)
    |> unique_constraint(:activity_id,
      name: :federation_failures_activity_id_recipient_transport_index
    )
  end

  def create_or_rewrite_with(%{activity_id: nil}), do: :noop

  def create_or_rewrite_with(%{} = params) do
    %FederationFailure{}
    |> changeset(params)
    |> Repo.insert(
      on_conflict: :replace_all_except_primary_key,
      conflict_target: [:activity_id, :recipient, :transport]
    )
  end

  def delete_by(%{activity_id: nil}), do: :noop

  def delete_by(%{activity_id: activity_id, recipient: recipient, transport: transport}) do
    from(ff in FederationFailure,
      where:
        ff.activity_id == ^activity_id and ff.recipient == ^recipient and
          ff.transport == ^transport
    )
    |> Repo.delete_all()
  end
end
