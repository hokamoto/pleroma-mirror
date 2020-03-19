# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Storage.Repo.UnappliedMigrationsError do
  defexception message: "Unapplied Migrations detected"
end
