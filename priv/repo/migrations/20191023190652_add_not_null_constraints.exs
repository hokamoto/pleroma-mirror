defmodule Pleroma.Repo.Migrations.AddNotNullConstraints do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      modify(:data, :map, null: false)
      modify(:local, :boolean, null: false, default: true)
    end

    alter table(:activity_expirations) do
      modify(:activity_id, references(:activities, type: :uuid, on_delete: :delete_all),
        null: false
      )
    end

    alter table(:apps) do
      modify(:client_name, :string, null: false)
      modify(:redirect_uris, :string, null: false)
    end

    alter table(:bookmarks) do
      modify(:user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false)

      modify(:activity_id, references(:activities, type: :uuid, on_delete: :delete_all),
        null: false
      )
    end

    alter table(:config) do
      modify(:key, :string, null: false)
      modify(:value, :binary, null: false)
    end

    alter table(:conversation_participation_recipient_ships) do
      modify(:user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false)

      modify(:participation_id, references(:conversation_participations, on_delete: :delete_all),
        null: false
      )
    end

    alter table(:conversation_participation) do
      modify(:user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false)
      modify(:conversation_id, references(:conversations, on_delete: :delete_all), null: false)
      modify(:read, :boolean, null: false)
    end

    alter table(:filters) do
      modify(:user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false)
      modify(:filter_id, :integer, null: false)
      modify(:hide, :boolean, null: false)
      modify(:whole_word, :boolean, null: false)
    end

    alter table(:instances) do
      modify(:host, :string, null: false)
    end

    alter table(:lists) do
      modify(:user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false)
    end

    alter table(:markers) do
      modify(:user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false)
    end

    alter table(:moderation_log) do
      modify(:data, :map, null: false)
    end

    alter table(:notifications) do
      modify(:user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false)

      modify(:activity_id, references(:activities, type: :uuid, on_delete: :delete_all),
        null: false
      )

      modify(:seen, :boolean, null: false)
    end

    alter table(:oauth_authorizations) do
      modify(:app_id, references(:apps), null: false)
      modify(:user_id, references(:users), null: false)
      modify(:token, :boolean, null: false)
      modify(:used, :boolean, null: false)
    end

    alter table(:oauth_tokens) do
      modify(:app_id, references(:apps), null: false)
      modify(:user_id, references(:users), null: false)
    end

    alter table(:objects) do
      modify(:data, :map, null: false)
    end

    alter table(:password_reset_tokens) do
      modify(:token, :string, null: false)
      modify(:user_id, references(:users), null: false)
      modify(:used, :boolean, null: false)
    end

    alter table(:push_subscriptions) do
      modify(:user_id, references(:users, on_delete: :delete_all), null: false)
      modify(:token_id, references(:oauth_tokens, on_delete: :delete_all), null: false)
      modify(:endpoint, :string, null: false)
      modify(:key_p256dh, :string, null: false)
      modify(:key_auth, :string, null: false)
      modify(:data, :map, null: false)
    end

    alter table(:registrations) do
      modify(:user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false)
      modify(:provider, :string, null: false)
      modify(:uid, :string, null: false)
      modify(:info, :map, null: false)
    end

    alter table(:scheduled_activities) do
      modify(:user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false)
    end

    alter table(:thread_mutes) do
      modify(:user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false)
      modify(:context, :string, null: false)
    end

    alter table(:user_invite_tokens) do
      modify(:token, :string, null: false)
      modify(:used, :boolean, null: false)
      modify(:uses, :integer, null: false)
      modify(:invite_type, :string, null: false)
    end

    alter table(:users) do
      modify(:following, {:array, :string}, null: false)
      modify(:local, :boolean, null: false)
      modify(:tags, {:array, :string}, null: false)
      modify(:banner, :map, null: false)
      modify(:background, :map, null: false)
      modify(:source_data, :map, null: false)
      modify(:note_count, :integer, null: false)
      modify(:follower_count, :integer, null: false)
      modify(:following_count, :integer, null: false)
      modify(:confirmation_token, :string, null: false)
      modify(:default_scope, :string, null: false)
      modify(:blocks, {:array, :string}, null: false)
      modify(:domain_blocks, {:array, :string}, null: false)
      modify(:mutes, {:array, :string}, null: false)
      modify(:muted_reblogs, {:array, :string}, null: false)
      modify(:muted_notifications, {:array, :string}, null: false)
      modify(:subscribers, {:array, :string}, null: false)
      modify(:settings, :map, null: false)
      modify(:magic_key, :string, null: false)
      modify(:uri, :string, null: false)
      modify(:unread_conversation_count, :integer, null: false)
      modify(:pinned_activities, {:array, :string}, null: false)
      modify(:email_notifications, :map, null: false)
      modify(:mascot, :map, null: false)
      modify(:mascot, {:array, :map}, null: false)
      modify(:pleroma_settings_store, :map, null: false)
      modify(:fields, {:array, :map}, null: false)
      modify(:raw_fields, {:array, :map}, null: false)
      modify(:notification_settings, :map, null: false)
    end
  end
end
