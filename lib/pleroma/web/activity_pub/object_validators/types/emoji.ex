# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.ActivityPub.ObjectValidators.Types.Emoji do
  use Ecto.Type

  def type, do: :map

  @doc "Casts to %{name => url} format"
  def cast(emoji) when is_map(emoji) do
    # To do: validate that all values are URIs?
    {:ok, emoji}
  end

  def cast(_) do
    :error
  end

  def dump(data) do
    {:ok, data}
  end

  def load(data) do
    {:ok, data}
  end
end
