defmodule Pleroma.Repo.Migrations.AddOtpToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add_if_not_exists :otp_enabled, :boolean, default: false
      add_if_not_exists :otp_secret, :string
      add_if_not_exists :otp_backup_codes, {:array, :string}
    end

  end
end
