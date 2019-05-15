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

  def supported_challenge_types(user) do
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

  def require?(user) do
    fetch_settings(user).enabled
  end

  def mfa_settings(user) do
    settings = fetch_settings(user)

    Settings.mfa_methods()
    |> Enum.map(fn m -> [m, enable_method?(m, settings)] end)
    |> Enum.into(%{enabled: settings.enabled}, fn [a, b] -> {a, b} end)
  end

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

  def setup_totp(user) do
    user
    |> Changeset.setup_totp(%{secret: TOTP.generate_secret(), delivery_type: "app"})
    |> Repo.update()
  end

  def confirm_totp(%User{} = user, attrs) do
    with settings <- user.multi_factor_authentication_settings.totp,
         {:ok, _user} <- Utils.confirm_current_password(user, attrs["password"]),
         {:ok, :pass} <- TOTP.validate_token(settings.secret, attrs["code"]) do
      user
      |> Changeset.confirm_totp()
      |> Repo.update()
    end
  end

  def disable_totp(%User{} = user, attrs) do
    with {:ok, user} <- Utils.confirm_current_password(user, attrs["password"]) do
      user
      |> Changeset.disable_totp()
      |> Changeset.disable()
      |> Repo.update()
    end
  end

  def disable(%User{} = user) do
    user
    |> Changeset.disable_totp()
    |> Changeset.disable(true)
    |> Repo.update()
  end

  def enable_method?(method, settings) do
    with {:ok, %{confirmed: true} = _} <- Map.fetch(settings, method) do
      true
    else
      _ -> false
    end
  end

  def has_confirmed_method?(settings) do
    Settings.mfa_methods()
    |> Enum.map(fn m -> enable_method?(m, settings) end)
    |> Enum.any?()
  end
end
