# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.ActivityPub.ObjectValidators.Types.Anything do
  use Ecto.Type

  def type, do: :map

  def cast(object) do
    {:ok, object}
  end

  def dump(data) do
    {:ok, data}
  end

  def load(data) do
    {:ok, data}
  end
end
