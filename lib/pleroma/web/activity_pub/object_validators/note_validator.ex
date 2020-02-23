# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.ActivityPub.ObjectValidators.NoteValidator do
  use Ecto.Schema

  alias Pleroma.Web.ActivityPub.ObjectValidators.Types

  import Ecto.Changeset
  import Pleroma.Web.ActivityPub.ObjectValidators.CommonValidations

  @primary_key false

  embedded_schema do
    field(:id, :string, primary_key: true)
    field(:to, {:array, :string}, default: [])
    field(:cc, {:array, :string}, default: [])
    field(:bto, {:array, :string}, default: [])
    field(:bcc, {:array, :string}, default: [])
    field(:tag, Types.Tags, default: [])
    field(:type, :string)
    field(:content, :string, default: "")
    field(:context, :string)
    field(:context_id, :integer)
    field(:actor, Types.ObjectID)
    field(:attributedTo, Types.ObjectID)
    field(:summary, :string)
    field(:published, Types.DateTime)
    field(:emoji, Types.Emoji, default: %{})
    field(:sensitive, :boolean, default: false)
    field(:attachment, Types.Attachments, default: [])
    field(:replies_count, :integer, default: 0)
    field(:like_count, :integer, default: 0)
    field(:announcement_count, :integer, default: 0)
    field(:inRepyTo, :string)

    field(:likes, {:array, :string}, default: [])
    field(:announcements, {:array, :string}, default: [])

    # see if needed
    field(:conversation, :string)
  end

  def cast_and_validate(data) do
    data
    |> cast_data()
    |> validate_data()
  end

  def cast_data(data) do
    cast(%__MODULE__{}, data, __schema__(:fields))
  end

  def validate_data(data_cng) do
    data_cng
    |> validate_inclusion(:type, ["Note"])
    # Note: :content is not listed as required, according to tests
    |> validate_required([:id, :actor, :to, :cc, :type, :context])
    |> validate_actor_presence()
  end
end
