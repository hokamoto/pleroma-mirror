# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Test.MfcCase do
  use ExUnit.CaseTemplate

  alias Pleroma.Web.Auth.Authenticator

  setup do
    default_app_layout = Authenticator.auth_template()
    Pleroma.Config.put(:app_layout, "app_mfc.html")

    default_authenticator = Authenticator.implementation()
    Pleroma.Config.put(Authenticator, Pleroma.Web.Auth.MfcAuthenticator)

    on_exit(fn ->
      Pleroma.Config.put(Authenticator, default_authenticator)
      Pleroma.Config.put(:app_layout, default_app_layout)
    end)

    :ok
  end
end
