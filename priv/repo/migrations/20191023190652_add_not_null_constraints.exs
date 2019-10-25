defmodule Pleroma.Repo.Migrations.AddNotNullConstraints do
  use Ecto.Migration

  def up do
    # modify/3 function will require index recreation, so using execute/1 instead

    execute("ALTER TABLE activities
    ALTER COLUMN data SET NOT NULL,
    ALTER COLUMN local SET NOT NULL")

    execute("ALTER TABLE activity_expirations
    ALTER COLUMN activity_id SET NOT NULL")

    execute("ALTER TABLE apps
    ALTER COLUMN client_name SET NOT NULL,
    ALTER COLUMN redirect_uris SET NOT NULL")

    execute("ALTER TABLE bookmarks
    ALTER COLUMN user_id SET NOT NULL,
    ALTER COLUMN activity_id SET NOT NULL")

    execute("ALTER TABLE config
    ALTER COLUMN key SET NOT NULL,
    ALTER COLUMN value SET NOT NULL")

    execute("ALTER TABLE conversation_participation_recipient_ships
    ALTER COLUMN user_id SET NOT NULL,
    ALTER COLUMN participation_id SET NOT NULL")

    execute("ALTER TABLE conversation_participations
    ALTER COLUMN user_id SET NOT NULL,
    ALTER COLUMN conversation_id SET NOT NULL,
    ALTER COLUMN read SET NOT NULL")

    execute("ALTER TABLE filters
    ALTER COLUMN user_id SET NOT NULL,
    ALTER COLUMN filter_id SET NOT NULL,
    ALTER COLUMN whole_word SET NOT NULL")

    execute("ALTER TABLE instances
    ALTER COLUMN host SET NOT NULL")

    execute("ALTER TABLE lists
    ALTER COLUMN user_id SET NOT NULL")

    execute("ALTER TABLE markers
    ALTER COLUMN user_id SET NOT NULL")

    execute("ALTER TABLE moderation_log
    ALTER COLUMN data SET NOT NULL")

    execute("ALTER TABLE notifications
    ALTER COLUMN user_id SET NOT NULL,
    ALTER COLUMN seen SET NOT NULL")

    execute("ALTER TABLE oauth_authorizations
    ALTER COLUMN app_id SET NOT NULL,
    ALTER COLUMN token SET NOT NULL,
    ALTER COLUMN used SET NOT NULL")

    execute("ALTER TABLE oauth_tokens
    ALTER COLUMN app_id SET NOT NULL")

    execute("ALTER TABLE objects
    ALTER COLUMN data SET NOT NULL")

    execute("ALTER TABLE password_reset_tokens
    ALTER COLUMN token SET NOT NULL,
    ALTER COLUMN user_id SET NOT NULL,
    ALTER COLUMN used SET NOT NULL")

    execute("ALTER TABLE push_subscriptions
    ALTER COLUMN user_id SET NOT NULL,
    ALTER COLUMN token_id SET NOT NULL,
    ALTER COLUMN endpoint SET NOT NULL,
    ALTER COLUMN key_p256dh SET NOT NULL,
    ALTER COLUMN key_auth SET NOT NULL,
    ALTER COLUMN data SET NOT NULL")

    execute("ALTER TABLE registrations
    ALTER COLUMN provider SET NOT NULL,
    ALTER COLUMN uid SET NOT NULL,
    ALTER COLUMN info SET NOT NULL")

    execute("ALTER TABLE scheduled_activities
    ALTER COLUMN user_id SET NOT NULL")

    execute("ALTER TABLE thread_mutes
    ALTER COLUMN user_id SET NOT NULL,
    ALTER COLUMN context SET NOT NULL")

    execute("ALTER TABLE user_invite_tokens
    ALTER COLUMN used SET NOT NULL,
    ALTER COLUMN uses SET NOT NULL,
    ALTER COLUMN invite_type SET NOT NULL")

    execute("ALTER TABLE users
    ALTER COLUMN following SET NOT NULL,
    ALTER COLUMN local SET NOT NULL,
    ALTER COLUMN background SET NOT NULL,
    ALTER COLUMN source_data SET NOT NULL,
    ALTER COLUMN note_count SET NOT NULL,
    ALTER COLUMN follower_count SET NOT NULL,
    ALTER COLUMN default_scope SET NOT NULL,
    ALTER COLUMN blocks SET NOT NULL,
    ALTER COLUMN domain_blocks SET NOT NULL,
    ALTER COLUMN mutes SET NOT NULL,
    ALTER COLUMN muted_reblogs SET NOT NULL,
    ALTER COLUMN muted_notifications SET NOT NULL,
    ALTER COLUMN subscribers SET NOT NULL,
    ALTER COLUMN unread_conversation_count SET NOT NULL,
    ALTER COLUMN pinned_activities SET NOT NULL,
    ALTER COLUMN email_notifications SET NOT NULL,
    ALTER COLUMN emoji SET NOT NULL,
    ALTER COLUMN pleroma_settings_store SET NOT NULL,
    ALTER COLUMN fields SET NOT NULL,
    ALTER COLUMN raw_fields SET NOT NULL,
    ALTER COLUMN notification_settings SET NOT NULL")
  end

  def down do
    execute("ALTER TABLE activities
    ALTER COLUMN data DROP NOT NULL,
    ALTER COLUMN local DROP NOT NULL")

    execute("ALTER TABLE activity_expirations
    ALTER COLUMN activity_id DROP NOT NULL")

    execute("ALTER TABLE apps
    ALTER COLUMN client_name DROP NOT NULL,
    ALTER COLUMN redirect_uris DROP NOT NULL")

    execute("ALTER TABLE bookmarks
    ALTER COLUMN user_id DROP NOT NULL,
    ALTER COLUMN activity_id DROP NOT NULL")

    execute("ALTER TABLE config
    ALTER COLUMN key DROP NOT NULL,
    ALTER COLUMN value DROP NOT NULL")

    execute("ALTER TABLE conversation_participation_recipient_ships
    ALTER COLUMN user_id DROP NOT NULL,
    ALTER COLUMN participation_id DROP NOT NULL")

    execute("ALTER TABLE conversation_participations
    ALTER COLUMN user_id DROP NOT NULL,
    ALTER COLUMN conversation_id DROP NOT NULL,
    ALTER COLUMN read DROP NOT NULL")

    execute("ALTER TABLE filters
    ALTER COLUMN user_id DROP NOT NULL,
    ALTER COLUMN filter_id DROP NOT NULL,
    ALTER COLUMN whole_word DROP NOT NULL")

    execute("ALTER TABLE instances
    ALTER COLUMN host DROP NOT NULL")

    execute("ALTER TABLE lists
    ALTER COLUMN user_id DROP NOT NULL")

    execute("ALTER TABLE markers
    ALTER COLUMN user_id DROP NOT NULL")

    execute("ALTER TABLE moderation_log
    ALTER COLUMN data DROP NOT NULL")

    execute("ALTER TABLE notifications
    ALTER COLUMN user_id DROP NOT NULL,
    ALTER COLUMN seen DROP NOT NULL")

    execute("ALTER TABLE oauth_authorizations
    ALTER COLUMN app_id DROP NOT NULL,
    ALTER COLUMN token DROP NOT NULL,
    ALTER COLUMN used DROP NOT NULL")

    execute("ALTER TABLE oauth_tokens
    ALTER COLUMN app_id DROP NOT NULL")

    execute("ALTER TABLE objects
    ALTER COLUMN data DROP NOT NULL")

    execute("ALTER TABLE password_reset_tokens
    ALTER COLUMN token DROP NOT NULL,
    ALTER COLUMN user_id DROP NOT NULL,
    ALTER COLUMN used DROP NOT NULL")

    execute("ALTER TABLE push_subscriptions
    ALTER COLUMN user_id DROP NOT NULL,
    ALTER COLUMN token_id DROP NOT NULL,
    ALTER COLUMN endpoint DROP NOT NULL,
    ALTER COLUMN key_p256dh DROP NOT NULL,
    ALTER COLUMN key_auth DROP NOT NULL,
    ALTER COLUMN data DROP NOT NULL")

    execute("ALTER TABLE registrations
    ALTER COLUMN provider DROP NOT NULL,
    ALTER COLUMN uid DROP NOT NULL,
    ALTER COLUMN info DROP NOT NULL")

    execute("ALTER TABLE scheduled_activities
    ALTER COLUMN user_id DROP NOT NULL")

    execute("ALTER TABLE thread_mutes
    ALTER COLUMN user_id DROP NOT NULL,
    ALTER COLUMN context DROP NOT NULL")

    execute("ALTER TABLE user_invite_tokens
    ALTER COLUMN used DROP NOT NULL,
    ALTER COLUMN uses DROP NOT NULL,
    ALTER COLUMN invite_type DROP NOT NULL")

    execute("ALTER TABLE users
    ALTER COLUMN following DROP NOT NULL,
    ALTER COLUMN local DROP NOT NULL,
    ALTER COLUMN background DROP NOT NULL,
    ALTER COLUMN source_data DROP NOT NULL,
    ALTER COLUMN note_count DROP NOT NULL,
    ALTER COLUMN follower_count DROP NOT NULL,
    ALTER COLUMN default_scope DROP NOT NULL,
    ALTER COLUMN blocks DROP NOT NULL,
    ALTER COLUMN domain_blocks DROP NOT NULL,
    ALTER COLUMN mutes DROP NOT NULL,
    ALTER COLUMN muted_reblogs DROP NOT NULL,
    ALTER COLUMN muted_notifications DROP NOT NULL,
    ALTER COLUMN subscribers DROP NOT NULL,
    ALTER COLUMN unread_conversation_count DROP NOT NULL,
    ALTER COLUMN pinned_activities DROP NOT NULL,
    ALTER COLUMN email_notifications DROP NOT NULL,
    ALTER COLUMN emoji DROP NOT NULL,
    ALTER COLUMN pleroma_settings_store DROP NOT NULL,
    ALTER COLUMN fields DROP NOT NULL,
    ALTER COLUMN raw_fields DROP NOT NULL,
    ALTER COLUMN notification_settings DROP NOT NULL")
  end
end
