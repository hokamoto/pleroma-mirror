# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.ActivityPub.ObjectValidator do
  @moduledoc """
  This module is responsible for validating an object (which can be an activity)
  and checking if it is both well formed and also compatible with our view of
  the system.
  """

  alias Pleroma.Object
  alias Pleroma.User
  alias Pleroma.Web.ActivityPub.ObjectValidators

  @spec validate(map(), keyword()) :: {:ok, map(), keyword()} | {:error, any()}
  def validate(object, meta)

  def validate(%{"type" => "Like"} = object, meta) do
    do_validate(ObjectValidators.LikeValidator, object, meta)
  end

  def validate(%{"type" => "Note"} = object, meta) do
    do_validate(ObjectValidators.NoteValidator, object, meta)
  end

  def validate(object, meta) do
    {:ok, object, meta}
  end

  defp do_validate(validator, object, meta) do
    with {:ok, object} <-
           validator
           |> apply(:cast_and_validate, [object])
           |> Ecto.Changeset.apply_action(:insert) do
      object =
        object
        |> Map.from_struct()
        |> stringify_keys()

      {:ok, object, meta}
    end
  end

  def stringify_keys(object) do
    Map.new(object, fn {key, val} -> {to_string(key), val} end)
  end

  def fetch_actor_and_object(object) do
    User.get_or_fetch_by_ap_id(object["actor"])
    Object.normalize(object["object"])
    :ok
  end
end
