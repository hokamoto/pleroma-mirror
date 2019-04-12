defmodule Pleroma.Web.OAuth.Token.Utils do
  @moduledoc """
  Auxiliary functions for dealing with tokens.
  """

  @doc "convert token inserted_at to unix timestamp"
  def format_created_at(%{inserted_at: inserted_at} = _token) do
    inserted_at
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.to_unix()
  end

  @doc false
  @spec generate_token(keyword()) :: binary()
  def generate_token(opts \\ []) do
    opts
    |> Keyword.get(:size, 32)
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
  end
end
