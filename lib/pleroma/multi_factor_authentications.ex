defmodule Pleroma.MultiFactorAuthentications do
  @moduledoc """
  The MultiFactorAuthentications context.
  """

  alias Comeonin.Pbkdf2
  alias Pleroma.User
  alias Pleroma.Web.Auth.TOTP

  alias Pleroma.MultiFactorAuthentications.Changeset
  alias Pleroma.MultiFactorAuthentications.Settings

  alias Pleroma.Repo
  alias Pleroma.Web.CommonAPI.Utils

  @doc "Returns enabled methods of user"
  def supported_methods(user) do
    settings = fetch_settings(user)

    Settings.mfa_methods()
    |> Enum.map(fn m -> [m, enable_method?(m, settings)] end)
    |> Enum.into(%{}, fn [m, v] -> {m, v} end)
    |> Enum.reduce(
      [],
      fn
        {k, true}, acc -> acc ++ [k]
        _, acc -> acc
      end
    )
    |> Enum.join(",")
  end

  @doc "Checks that user enabled MFA"
  def require?(user) do
    fetch_settings(user).enabled
  end

  @doc """
  Display MFA settings of user
  """
  def mfa_settings(user) do
    settings = fetch_settings(user)

    Settings.mfa_methods()
    |> Enum.map(fn m -> [m, enable_method?(m, settings)] end)
    |> Enum.into(%{enabled: settings.enabled}, fn [a, b] -> {a, b} end)
  end

  @doc false
  def fetch_settings(%User{} = user) do
    user.multi_factor_authentication_settings || %Settings{}
  end

  @doc "clears backup codes"
  def invalidate_backup_code(%User{} = user, hash_code) do
    %{backup_codes: codes} = fetch_settings(user)

    user
    |> Changeset.cast_backup_codes(codes -- [hash_code])
    |> Repo.update()
  end

  @doc "generates backup codes"
  @spec generate_backup_codes(User.t()) :: {:ok, list(binary)} | {:error, String.t()}
  def generate_backup_codes(%User{} = user) do
    with codes <- TOTP.generate_backup_codes(),
         hashed_codes <- Enum.map(codes, fn code -> Pbkdf2.hashpwsalt(code) end),
         %Ecto.Changeset{valid?: true} = changeset <-
           Changeset.cast_backup_codes(user, hashed_codes),
         {:ok, _} <- Repo.update(changeset) do
      {:ok, codes}
    else
      {:error, msg} ->
        %{error: msg}
    end
  end

  @doc """
  Generates secret key and set delivery_type to 'app' for TOTP method.
  """
  @spec setup_totp(User.t()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def setup_totp(user) do
    user
    |> Changeset.setup_totp(%{secret: TOTP.generate_secret(), delivery_type: "app"})
    |> Repo.update()
  end

  @doc """
  Confirms the TOTP method for user.

  `attrs`:
    `password` - current user password
    `code` - TOTP token
  """
  @spec confirm_totp(User.t(), map()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t() | String.t() | atom()}
  def confirm_totp(%User{} = user, attrs) do
    with settings <- user.multi_factor_authentication_settings.totp,
         {:ok, _user} <- Utils.confirm_current_password(user, attrs["password"]),
         {:ok, :pass} <- TOTP.validate_token(settings.secret, attrs["code"]) do
      user
      |> Changeset.confirm_totp()
      |> Repo.update()
    end
  end

  @doc """
  Disables the TOTP method for user.

  `attrs`:
    `password` - current user password
  """
  @spec disable_totp(User.t(), map) :: {:ok, User.t()} | {:error, Ecto.Changeset.t() | String.t()}
  def disable_totp(%User{} = user, attrs) do
    with {:ok, user} <- Utils.confirm_current_password(user, attrs["password"]) do
      user
      |> Changeset.disable_totp()
      |> Changeset.disable()
      |> Repo.update()
    end
  end

  @doc """
  Force disable MFA for user. (for admin).
  """
  @spec disable(User.t()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def disable(%User{} = user) do
    user
    |> Changeset.disable_totp()
    |> Changeset.disable(true)
    |> Repo.update()
  end

  @doc """
  Checks that user enabled method MFA.
  """
  def enable_method?(method, settings) do
    with {:ok, %{confirmed: true} = _} <- Map.fetch(settings, method) do
      true
    else
      _ -> false
    end
  end

  @doc """
  Checks that user has enabled at least one method
  """
  def has_confirmed_method?(settings) do
    Settings.mfa_methods()
    |> Enum.map(fn m -> enable_method?(m, settings) end)
    |> Enum.any?()
  end
end
