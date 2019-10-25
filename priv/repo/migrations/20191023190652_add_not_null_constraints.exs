defmodule Pleroma.Repo.Migrations.AddNotNullConstraints do
  use Ecto.Migration

  def change do
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
    ALTER COLUMN hide SET NOT NULL,
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
    ALTER COLUMN activity_id SET NOT NULL,
    ALTER COLUMN seen SET NOT NULL")

    execute("ALTER TABLE oauth_authorizations
    ALTER COLUMN app_id SET NOT NULL,
    ALTER COLUMN user_id SET NOT NULL,
    ALTER COLUMN token SET NOT NULL,
    ALTER COLUMN used SET NOT NULL")

    execute("ALTER TABLE oauth_tokens
    ALTER COLUMN app_id SET NOT NULL,
    ALTER COLUMN user_id SET NOT NULL")

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
    ALTER COLUMN user_id SET NOT NULL,
    ALTER COLUMN provider SET NOT NULL,
    ALTER COLUMN uid SET NOT NULL,
    ALTER COLUMN info SET NOT NULL")

    execute("ALTER TABLE scheduled_activities
    ALTER COLUMN user_id SET NOT NULL")

    execute("ALTER TABLE thread_mutes
    ALTER COLUMN user_id SET NOT NULL,
    ALTER COLUMN context SET NOT NULL")

    execute("ALTER TABLE user_invite_tokens
    ALTER COLUMN token SET NOT NULL,
    ALTER COLUMN used SET NOT NULL,
    ALTER COLUMN uses SET NOT NULL,
    ALTER COLUMN invite_type SET NOT NULL")

    execute("ALTER TABLE users
    ALTER COLUMN following SET NOT NULL,
    ALTER COLUMN local SET NOT NULL,
    ALTER COLUMN tags SET NOT NULL,
    ALTER COLUMN banner SET NOT NULL,
    ALTER COLUMN background SET NOT NULL,
    ALTER COLUMN source_data SET NOT NULL,
    ALTER COLUMN note_count SET NOT NULL,
    ALTER COLUMN follower_count SET NOT NULL,
    ALTER COLUMN following_count SET NOT NULL,
    ALTER COLUMN confirmation_token SET NOT NULL,
    ALTER COLUMN default_scope SET NOT NULL,
    ALTER COLUMN blocks SET NOT NULL,
    ALTER COLUMN domain_blocks SET NOT NULL,
    ALTER COLUMN mutes SET NOT NULL,
    ALTER COLUMN muted_reblogs SET NOT NULL,
    ALTER COLUMN muted_notifications SET NOT NULL,
    ALTER COLUMN subscribers SET NOT NULL,
    ALTER COLUMN settings SET NOT NULL,
    ALTER COLUMN magic_key SET NOT NULL,
    ALTER COLUMN uri SET NOT NULL,
    ALTER COLUMN unread_conversation_count SET NOT NULL,
    ALTER COLUMN pinned_activities SET NOT NULL,
    ALTER COLUMN email_notifications SET NOT NULL,
    ALTER COLUMN mascot SET NOT NULL,
    ALTER COLUMN emoji SET NOT NULL,
    ALTER COLUMN pleroma_settings_store SET NOT NULL,
    ALTER COLUMN fields SET NOT NULL,
    ALTER COLUMN raw_fields SET NOT NULL,
    ALTER COLUMN notification_settings SET NOT NULL")
  end
end
