defmodule Pleroma.MultiFactorAuthentications.Settings do
  use Ecto.Schema

  @primary_key false

  embedded_schema do
    field(:enabled, :boolean, default: false)
    field(:backup_codes, {:array, :string}, default: [])

    embeds_one :totp, TOTP, on_replace: :delete, primary_key: false do
      field(:secret, :string)
      # app | sms
      field(:delivery_type, :string)
      field(:confirmed, :boolean, default: false)
    end

    embeds_one :u2f, U2f, on_replace: :delete, primary_key: false do
      field(:key_handle, :string)
      field(:public_key, :string)
      field(:confirmed, :boolean, default: false)
    end
  end
end
