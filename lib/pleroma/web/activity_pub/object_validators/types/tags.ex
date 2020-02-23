# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.ActivityPub.ObjectValidators.Types.Tags do
  alias Pleroma.Web.ActivityPub.Transmogrifier

  use Ecto.Type

  def type, do: {:array, :map}

  def cast(tags_list) when is_list(tags_list) do
    if Enum.all?(tags_list, &(is_map(&1) || is_binary(&1))) do
      {:ok, Transmogrifier.as2_tags(tags_list)}
    else
      :error
    end
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
