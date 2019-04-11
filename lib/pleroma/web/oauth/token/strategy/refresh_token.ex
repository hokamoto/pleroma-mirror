defmodule Pleroma.Web.OAuth.Token.Strategy.RefreshToken do
  @moduledoc """
  Functions for dealing with refresh token strategy.
  """

  alias Pleroma.Repo
  alias Pleroma.Web.OAuth.Token
  alias Pleroma.Web.OAuth.Token.Strategy.Revoke

  @doc """
  Will grant access token by refresh token.
  """
  @spec grant(Token.t(), map) :: {:ok, Token.t()} | {:error, any()}
  def grant(token, %{"grant_type" => "refresh_token"} = _request) do
    access_token = Repo.preload(token, [:user, :app])

    result =
      Repo.transaction(fn ->
        token_params = %{
          app: access_token.app,
          user: access_token.user,
          scopes: access_token.scopes
        }

        access_token
        |> Revoke.revoke()
        |> create_access_token(token_params)
      end)

    case result do
      {:ok, {:ok, token}} -> {:ok, token}
      {:error, reason} -> {:error, reason}
    end
  end

  defp create_access_token({:ok, _}, %{app: app, user: user} = token_params) do
    Token.create_token(app, user, token_params[:scopes])
  end
end
