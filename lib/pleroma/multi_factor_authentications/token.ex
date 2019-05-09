defmodule Pleroma.MultiFactorAuthentications.Token do
  use Ecto.Schema
  import Ecto.Query
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

  def get_by_token(token) do
    from(t in __MODULE__, where: t.token == ^token, preload: [:user])
    |> Repo.find_resource()
  end

  def validate(token) do
    with {:fetch_token, {:ok, token}} <- {:fetch_token, get_by_token(token)},
         {:expired, false} <- {:expired, is_expired?(token)} do
      {:ok, token}
    else
      {:expired, _} -> {:error, :expired_token}
      {:fetch_token, _} -> {:error, :not_found}
      error -> {:error, error}
    end
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

  def is_expired?(%__MODULE__{valid_until: valid_until}) do
    NaiveDateTime.diff(NaiveDateTime.utc_now(), valid_until) > 0
  end

  def is_expired?(_), do: false
end
