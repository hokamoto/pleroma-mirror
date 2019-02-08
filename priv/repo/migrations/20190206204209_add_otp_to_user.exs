defmodule Pleroma.Repo.Migrations.AddOtpToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :otp_enabled, :boolean, default: false
      add :otp_secret, :string
      add :otp_backup_codes, {:array, :string}
    end

  end
end
