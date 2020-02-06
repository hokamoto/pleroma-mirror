# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Helpers.JWT do
  use Joken.Config
  alias Pleroma.Web.Endpoint

  @impl true
  def token_config do
    add_claim(default_claims(skip: [:aud]), "aud", &Endpoint.url/0, &(&1 == Endpoint.url()))
  end
end
