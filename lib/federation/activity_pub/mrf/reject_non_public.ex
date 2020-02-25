# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Federation.ActivityPub.MRF.RejectNonPublic do
  @moduledoc "Rejects non-public (followers-only, direct) activities"

  alias Pleroma.Config
  alias Pleroma.Helpers.Constants
  alias Pleroma.User

  @behaviour Pleroma.Federation.ActivityPub.MRF

  require Pleroma.Helpers.Constants

  @impl true
  def filter(%{"type" => "Create"} = object) do
    user = User.get_cached_by_ap_id(object["actor"])

    # Determine visibility
    visibility =
      cond do
        Constants.as_public() in object["to"] -> "public"
        Constants.as_public() in object["cc"] -> "unlisted"
        user.follower_address in object["to"] -> "followers"
        true -> "direct"
      end

    policy = Config.get(:mrf_rejectnonpublic)

    cond do
      visibility in ["public", "unlisted"] ->
        {:ok, object}

      visibility == "followers" and Keyword.get(policy, :allow_followersonly) ->
        {:ok, object}

      visibility == "direct" and Keyword.get(policy, :allow_direct) ->
        {:ok, object}

      true ->
        {:reject, nil}
    end
  end

  @impl true
  def filter(object), do: {:ok, object}

  @impl true
  def describe,
    do: {:ok, %{mrf_rejectnonpublic: Pleroma.Config.get(:mrf_rejectnonpublic) |> Enum.into(%{})}}
end