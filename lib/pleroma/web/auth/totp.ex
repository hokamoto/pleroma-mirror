defmodule Pleroma.Web.Auth.TOTP do
  @moduledoc """
  This module represents functions to create secrets for
  TOTP Application as well as validate them with a time based token.
  """
  alias Pleroma.Config

  @config_ns [:instance, :two_factor_authentication]

  @doc """
  https://github.com/google/google-authenticator/wiki/Key-Uri-Format
  """
  def provisioning_uri(secret, label, opts \\ []) do
    query =
      %{
        secret: secret,
        issuer: Keyword.get(opts, :issuer, default_issuer()),
        digits: Keyword.get(opts, :digits, default_digits()),
        period: Keyword.get(opts, :period, default_period())
      }
      |> Enum.filter(fn {_, v} -> not is_nil(v) end)
      |> Enum.into(%{})
      |> URI.encode_query()

    %URI{scheme: "otpauth", host: "totp/", path: label, query: query}
    |> URI.to_string()
  end

  defp default_period, do: Config.get(@config_ns ++ [:period])
  defp default_digits, do: Config.get(@config_ns ++ [:digits])

  defp default_issuer,
    do: Config.get(@config_ns ++ [:issuer], Config.get([:instance, :name]))

  defp default_backup_codes_number,
    do: Config.get(@config_ns ++ [:backup_codes, :number], 5)

  defp default_backup_codes_code_length,
    do: Config.get(@config_ns ++ [:backup_codes, :code_length], 16)

  @doc "Creates a random Base 32 encoded string"
  def generate_secret do
    :crypto.strong_rand_bytes(10)
    |> Base.encode32()
  end

  @doc "Generates a valid token based on a secret"
  def generate_token(secret) do
    :pot.totp(secret)
  end

  @doc """
  Generates a backup codes.
  """
  @spec generate_backup_codes(Keyword.t()) :: list(String.t())
  def generate_backup_codes(opts \\ []) do
    number_of_codes = Keyword.get(opts, :number_of_codes, default_backup_codes_number())
    code_length = Keyword.get(opts, :code_length, default_backup_codes_code_length())

    Enum.map(1..number_of_codes, fn _ ->
      :crypto.strong_rand_bytes(div(code_length, 2))
      |> Base.encode16(case: :lower)
    end)
  end

  @doc """
  Validates a given token based on a secret.

  optional options:
  `token_length` default `6`
  `interval_length` default `30`
  `window` default 0

  Returns {:ok, :pass} if the token is valid and
  {:error, :invalid_token} if it is not.
  """
  @spec validate_token(String.t(), String.t()) ::
          {:ok, :pass} | {:error, :invalid_token | :invalid_secret_and_token}
  def validate_token(secret, token)
      when is_binary(secret) and is_binary(token) do
    opts = [
      token_length: default_digits(),
      interval_length: default_period()
    ]

    validate_token(secret, token, opts)
  end

  def validate_token(_, _), do: {:error, :invalid_secret_and_token}

  @doc "See `validate_token/2`"
  @spec validate_token(String.t(), String.t(), Keyword.t()) ::
          {:ok, :pass} | {:error, :invalid_token | :invalid_secret_and_token}
  def validate_token(secret, token, options)
      when is_binary(secret) and is_binary(token) do
    case :pot.valid_totp(token, secret, options) do
      true -> {:ok, :pass}
      false -> {:error, :invalid_token}
    end
  end

  def validate_token(_, _, _), do: {:error, :invalid_secret_and_token}
end
