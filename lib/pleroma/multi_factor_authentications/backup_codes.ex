# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.MultiFactorAuthentications.BackupCodes do
  @moduledoc """
  This module represents functions to generate backup codes.
  """
  alias Pleroma.Config

  @config_ns [:instance, :multi_factor_authentication]

  @doc """
  Generates a backup codes.
  """
  @spec generate(Keyword.t()) :: list(String.t())
  def generate(opts \\ []) do
    number_of_codes = Keyword.get(opts, :number_of_codes, default_backup_codes_number())
    code_length = Keyword.get(opts, :code_length, default_backup_codes_code_length())

    Enum.map(1..number_of_codes, fn _ ->
      :crypto.strong_rand_bytes(div(code_length, 2))
      |> Base.encode16(case: :lower)
    end)
  end

  defp default_backup_codes_number,
    do: Config.get(@config_ns ++ [:backup_codes, :number], 5)

  defp default_backup_codes_code_length,
    do: Config.get(@config_ns ++ [:backup_codes, :code_length], 16)
end
