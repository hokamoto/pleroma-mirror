defmodule Pleroma.Web.OAuth.Token.Response do
  @moduledoc false

  @expires_in Pleroma.Config.get([:oauth2, :token_expires_in], 600)

  @doc false
  def build(user, token, opts \\ %{}) do
    %{
      token_type: "Bearer",
      access_token: token.token,
      refresh_token: token.refresh_token,
      expires_in: @expires_in,
      scope: Enum.join(token.scopes, " "),
      me: user.ap_id
    }
    |> Map.merge(opts)
  end
end
