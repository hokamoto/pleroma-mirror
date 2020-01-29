# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Crypto do
  @spec random_string(integer, keyword) :: String.t()
  def random_string(length, opts \\ []) do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(opts)
  end
end
