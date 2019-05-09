defmodule Pleroma.MultiFactorAuthentications.Token do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pleroma.FlakeId
  alias Pleroma.Repo
  alias Pleroma.User
  alias Pleroma.Web.OAuth.Token, as: OAuthToken

  @expires 300

  schema "mfa_tokens" do
    field(:token, :string)
    field(:valid_until, :naive_datetime_usec)
    field(:scopes, {:array, :string}, default: [])

    belongs_to(:user, User, type: FlakeId)

    timestamps()
  end

  def create_token(user, scopes \\ []) do
    %__MODULE__{scopes: scopes}
    |> assign_user(user)
    |> put_token
    |> put_valid_until
    |> Repo.insert()
  end

  defp assign_user(changeset, user) do
    changeset
    |> put_assoc(:user, user)
    |> validate_required([:user])
  end

  defp put_token(changeset) do
    changeset
    |> change(%{token: OAuthToken.Utils.generate_token()})
    |> validate_required([:token])
    |> unique_constraint(:token)
  end

  defp put_valid_until(changeset) do
    expires_in = NaiveDateTime.add(NaiveDateTime.utc_now(), @expires)

    changeset
    |> change(%{valid_until: expires_in})
    |> validate_required([:valid_until])
  end
end
