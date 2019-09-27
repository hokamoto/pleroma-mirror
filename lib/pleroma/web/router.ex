# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.Router do
  use Pleroma.Web, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
  end

  pipeline :oauth do
    plug(:fetch_session)
    plug(Pleroma.Plugs.OAuthPlug)
  end

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:fetch_session)
    plug(Pleroma.Plugs.OAuthPlug)
    plug(Pleroma.Plugs.BasicAuthDecoderPlug)
    plug(Pleroma.Plugs.UserFetcherPlug)
    plug(Pleroma.Plugs.SessionAuthenticationPlug)
    plug(Pleroma.Plugs.LegacyAuthenticationPlug)
    plug(Pleroma.Plugs.AuthenticationPlug)
    plug(Pleroma.Plugs.UserEnabledPlug)
    plug(Pleroma.Plugs.SetUserSessionIdPlug)
    plug(Pleroma.Plugs.EnsureUserKeyPlug)
    plug(Pleroma.Plugs.IdempotencyPlug)
  end

  pipeline :authenticated_api do
    plug(:accepts, ["json"])
    plug(:fetch_session)
    plug(Pleroma.Plugs.OAuthPlug)
    plug(Pleroma.Plugs.BasicAuthDecoderPlug)
    plug(Pleroma.Plugs.UserFetcherPlug)
    plug(Pleroma.Plugs.SessionAuthenticationPlug)
    plug(Pleroma.Plugs.LegacyAuthenticationPlug)
    plug(Pleroma.Plugs.AuthenticationPlug)
    plug(Pleroma.Plugs.UserEnabledPlug)
    plug(Pleroma.Plugs.SetUserSessionIdPlug)
    plug(Pleroma.Plugs.EnsureAuthenticatedPlug)
    plug(Pleroma.Plugs.IdempotencyPlug)
  end

  pipeline :admin_api do
    plug(:accepts, ["json"])
    plug(:fetch_session)
    plug(Pleroma.Plugs.OAuthPlug)
    plug(Pleroma.Plugs.BasicAuthDecoderPlug)
    plug(Pleroma.Plugs.UserFetcherPlug)
    plug(Pleroma.Plugs.SessionAuthenticationPlug)
    plug(Pleroma.Plugs.LegacyAuthenticationPlug)
    plug(Pleroma.Plugs.AuthenticationPlug)
    plug(Pleroma.Plugs.AdminSecretAuthenticationPlug)
    plug(Pleroma.Plugs.UserEnabledPlug)
    plug(Pleroma.Plugs.SetUserSessionIdPlug)
    plug(Pleroma.Plugs.EnsureAuthenticatedPlug)
    plug(Pleroma.Plugs.UserIsAdminPlug)
    plug(Pleroma.Plugs.IdempotencyPlug)
  end

  pipeline :mastodon_html do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(Pleroma.Plugs.OAuthPlug)
    plug(Pleroma.Plugs.BasicAuthDecoderPlug)
    plug(Pleroma.Plugs.UserFetcherPlug)
    plug(Pleroma.Plugs.SessionAuthenticationPlug)
    plug(Pleroma.Plugs.LegacyAuthenticationPlug)
    plug(Pleroma.Plugs.AuthenticationPlug)
    plug(Pleroma.Plugs.UserEnabledPlug)
    plug(Pleroma.Plugs.SetUserSessionIdPlug)
    plug(Pleroma.Plugs.EnsureUserKeyPlug)
  end

  pipeline :pleroma_html do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(Pleroma.Plugs.OAuthPlug)
    plug(Pleroma.Plugs.BasicAuthDecoderPlug)
    plug(Pleroma.Plugs.UserFetcherPlug)
    plug(Pleroma.Plugs.SessionAuthenticationPlug)
    plug(Pleroma.Plugs.AuthenticationPlug)
    plug(Pleroma.Plugs.EnsureUserKeyPlug)
  end

  pipeline :oauth_read_or_public do
    plug(Pleroma.Plugs.OAuthScopesPlug, %{
      scopes: ["read"],
      fallback: :proceed_unauthenticated
    })

    plug(Pleroma.Plugs.EnsurePublicOrAuthenticatedPlug)
  end

  pipeline :oauth_read do
    plug(Pleroma.Plugs.OAuthScopesPlug, %{scopes: ["read"]})
  end

  pipeline :oauth_write do
    plug(Pleroma.Plugs.OAuthScopesPlug, %{scopes: ["write"]})
  end

  pipeline :oauth_follow do
    plug(Pleroma.Plugs.OAuthScopesPlug, %{scopes: ["follow"]})
  end

  pipeline :oauth_push do
    plug(Pleroma.Plugs.OAuthScopesPlug, %{scopes: ["push"]})
  end

  pipeline :well_known do
    plug(:accepts, ["json", "jrd+json", "xml", "xrd+xml"])
  end

  pipeline :config do
    plug(:accepts, ["json", "xml"])
  end

  pipeline :pleroma_api do
    plug(:accepts, ["html", "json"])
  end

  pipeline :mailbox_preview do
    plug(:accepts, ["html"])

    plug(:put_secure_browser_headers, %{
      "content-security-policy" =>
        "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline' 'unsafe-eval'"
    })
  end

  pipeline :http_signature do
    plug(Pleroma.Web.Plugs.HTTPSignaturePlug)
    plug(Pleroma.Web.Plugs.MappedSignatureToIdentityPlug)
  end

  scope "/api/pleroma", Pleroma.Web.TwitterAPI do
    pipe_through(:pleroma_api)

    get("/password_reset/:token", PasswordController, :reset, as: :reset_password)
    post("/password_reset", PasswordController, :do_reset, as: :reset_password)
    get("/emoji", UtilController, :emoji)
    get("/captcha", UtilController, :captcha)
    get("/healthcheck", UtilController, :healthcheck)
  end

  scope "/api/pleroma", Pleroma.Web do
    pipe_through(:pleroma_api)
    post("/uploader_callback/:upload_path", UploaderController, :callback)
  end

  scope "/api/pleroma/admin", Pleroma.Web.AdminAPI do
    pipe_through([:admin_api, :oauth_write])

    post("/users/follow", AdminAPIController, :user_follow)
    post("/users/unfollow", AdminAPIController, :user_unfollow)

    delete("/users", AdminAPIController, :user_delete)
    post("/users", AdminAPIController, :users_create)
    patch("/users/:nickname/toggle_activation", AdminAPIController, :user_toggle_activation)
    put("/users/tag", AdminAPIController, :tag_users)
    delete("/users/tag", AdminAPIController, :untag_users)

    get("/users/:nickname/permission_group", AdminAPIController, :right_get)
    get("/users/:nickname/permission_group/:permission_group", AdminAPIController, :right_get)
    post("/users/:nickname/permission_group/:permission_group", AdminAPIController, :right_add)

    delete(
      "/users/:nickname/permission_group/:permission_group",
      AdminAPIController,
      :right_delete
    )

    put("/users/:nickname/activation_status", AdminAPIController, :set_activation_status)

    post("/relay", AdminAPIController, :relay_follow)
    delete("/relay", AdminAPIController, :relay_unfollow)

    post("/users/invite_token", AdminAPIController, :create_invite_token)
    get("/users/invites", AdminAPIController, :invites)
    post("/users/revoke_invite", AdminAPIController, :revoke_invite)
    post("/users/email_invite", AdminAPIController, :email_invite)

    get("/users/:nickname/password_reset", AdminAPIController, :get_password_reset)
    patch("/users/:nickname/force_password_reset", AdminAPIController, :force_password_reset)

    get("/users", AdminAPIController, :list_users)
    get("/users/:nickname", AdminAPIController, :user_show)
    get("/users/:nickname/statuses", AdminAPIController, :list_user_statuses)

    get("/reports", AdminAPIController, :list_reports)
    get("/reports/:id", AdminAPIController, :report_show)
    put("/reports/:id", AdminAPIController, :report_update_state)
    post("/reports/:id/respond", AdminAPIController, :report_respond)

    put("/statuses/:id", AdminAPIController, :status_update)
    delete("/statuses/:id", AdminAPIController, :status_delete)

    get("/config", AdminAPIController, :config_show)
    post("/config", AdminAPIController, :config_update)
    get("/config/migrate_to_db", AdminAPIController, :migrate_to_db)
    get("/config/migrate_from_db", AdminAPIController, :migrate_from_db)

    get("/moderation_log", AdminAPIController, :list_log)

    post("/reload_emoji", AdminAPIController, :reload_emoji)
  end

  scope "/api/pleroma/emoji", Pleroma.Web.PleromaAPI do
    scope "/packs" do
      # Modifying packs
      pipe_through([:admin_api, :oauth_write])

      post("/import_from_fs", EmojiAPIController, :import_from_fs)

      post("/:pack_name/update_file", EmojiAPIController, :update_file)
      post("/:pack_name/update_metadata", EmojiAPIController, :update_metadata)
      put("/:name", EmojiAPIController, :create)
      delete("/:name", EmojiAPIController, :delete)
      post("/download_from", EmojiAPIController, :download_from)
      post("/list_from", EmojiAPIController, :list_from)
    end

    scope "/packs" do
      # Pack info / downloading
      get("/", EmojiAPIController, :list_packs)
      get("/:name/download_shared/", EmojiAPIController, :download_shared)
    end
  end

  scope "/", Pleroma.Web.TwitterAPI do
    pipe_through(:pleroma_html)

    post("/main/ostatus", UtilController, :remote_subscribe)
    get("/ostatus_subscribe", UtilController, :remote_follow)

    scope [] do
      pipe_through(:oauth_follow)
      post("/ostatus_subscribe", UtilController, :do_remote_follow)
    end
  end

  scope "/api/pleroma", Pleroma.Web.TwitterAPI do
    pipe_through(:authenticated_api)

    scope [] do
      pipe_through(:oauth_write)

      post("/change_email", UtilController, :change_email)
      post("/change_password", UtilController, :change_password)
      post("/delete_account", UtilController, :delete_account)
      put("/notification_settings", UtilController, :update_notificaton_settings)
      post("/disable_account", UtilController, :disable_account)
    end

    scope [] do
      pipe_through(:oauth_follow)

      post("/blocks_import", UtilController, :blocks_import)
      post("/follow_import", UtilController, :follow_import)
    end
  end

  scope "/oauth", Pleroma.Web.OAuth do
    scope [] do
      pipe_through(:oauth)
      get("/authorize", OAuthController, :authorize)
    end

    post("/authorize", OAuthController, :create_authorization)
    post("/token", OAuthController, :token_exchange)
    post("/revoke", OAuthController, :token_revoke)
    get("/registration_details", OAuthController, :registration_details)

    scope [] do
      pipe_through(:browser)

      get("/prepare_request", OAuthController, :prepare_request)
      get("/:provider", OAuthController, :request)
      get("/:provider/callback", OAuthController, :callback)
      post("/register", OAuthController, :register)
    end
  end

  scope "/api/v1/pleroma", Pleroma.Web.PleromaAPI do
    pipe_through(:authenticated_api)

    scope [] do
      pipe_through(:oauth_read)
      get("/conversations/:id/statuses", PleromaAPIController, :conversation_statuses)
      get("/conversations/:id", PleromaAPIController, :conversation)

      scope "/subscription_notifications" do
        post("/clear", SubscriptionNotificationController, :clear)
        post("/dismiss", SubscriptionNotificationController, :dismiss)
        delete("/destroy_multiple", SubscriptionNotificationController, :destroy_multiple)
        get("/", SubscriptionNotificationController, :index)
        get("/:id", SubscriptionNotificationController, :show)
      end
    end

    scope [] do
      pipe_through(:oauth_write)
      patch("/conversations/:id", PleromaAPIController, :update_conversation)
      post("/notifications/read", PleromaAPIController, :read_notification)
    end
  end

  scope "/api/v1", Pleroma.Web.MastodonAPI do
    pipe_through(:authenticated_api)

    scope [] do
      pipe_through(:oauth_read)

      get("/accounts/verify_credentials", MastodonAPIController, :verify_credentials)

      get("/accounts/relationships", MastodonAPIController, :relationships)

      get("/accounts/:id/lists", MastodonAPIController, :account_lists)
      get("/accounts/:id/identity_proofs", MastodonAPIController, :empty_array)

      get("/follow_requests", FollowRequestController, :index)
      get("/blocks", MastodonAPIController, :blocks)
      get("/mutes", MastodonAPIController, :mutes)

      get("/timelines/home", TimelineController, :home)
      get("/timelines/direct", TimelineController, :direct)

      get("/favourites", MastodonAPIController, :favourites)
      get("/bookmarks", MastodonAPIController, :bookmarks)

      get("/notifications", NotificationController, :index)
      get("/notifications/:id", NotificationController, :show)
      post("/notifications/clear", NotificationController, :clear)
      post("/notifications/dismiss", NotificationController, :dismiss)
      delete("/notifications/destroy_multiple", NotificationController, :destroy_multiple)

      get("/scheduled_statuses", ScheduledActivityController, :index)
      get("/scheduled_statuses/:id", ScheduledActivityController, :show)

      get("/lists", ListController, :index)
      get("/lists/:id", ListController, :show)
      get("/lists/:id/accounts", ListController, :list_accounts)

      get("/domain_blocks", DomainBlockController, :index)

      get("/filters", FilterController, :index)

      get("/suggestions", MastodonAPIController, :suggestions)

      get("/conversations", MastodonAPIController, :conversations)
      post("/conversations/:id/read", MastodonAPIController, :conversation_read)

      get("/endorsements", MastodonAPIController, :empty_array)
    end

    scope [] do
      pipe_through(:oauth_write)

      patch("/accounts/update_credentials", MastodonAPIController, :update_credentials)

      post("/statuses", StatusController, :create)
      delete("/statuses/:id", StatusController, :delete)

      post("/statuses/:id/reblog", StatusController, :reblog)
      post("/statuses/:id/unreblog", StatusController, :unreblog)
      post("/statuses/:id/favourite", StatusController, :favourite)
      post("/statuses/:id/unfavourite", StatusController, :unfavourite)
      post("/statuses/:id/pin", StatusController, :pin)
      post("/statuses/:id/unpin", StatusController, :unpin)
      post("/statuses/:id/bookmark", StatusController, :bookmark)
      post("/statuses/:id/unbookmark", StatusController, :unbookmark)
      post("/statuses/:id/mute", StatusController, :mute_conversation)
      post("/statuses/:id/unmute", StatusController, :unmute_conversation)

      put("/scheduled_statuses/:id", ScheduledActivityController, :update)
      delete("/scheduled_statuses/:id", ScheduledActivityController, :delete)

      post("/polls/:id/votes", MastodonAPIController, :poll_vote)

      post("/media", MastodonAPIController, :upload)
      put("/media/:id", MastodonAPIController, :update_media)

      delete("/lists/:id", ListController, :delete)
      post("/lists", ListController, :create)
      put("/lists/:id", ListController, :update)

      post("/lists/:id/accounts", ListController, :add_to_list)
      delete("/lists/:id/accounts", ListController, :remove_from_list)

      post("/filters", FilterController, :create)
      get("/filters/:id", FilterController, :show)
      put("/filters/:id", FilterController, :update)
      delete("/filters/:id", FilterController, :delete)

      patch("/pleroma/accounts/update_avatar", MastodonAPIController, :update_avatar)
      patch("/pleroma/accounts/update_banner", MastodonAPIController, :update_banner)
      patch("/pleroma/accounts/update_background", MastodonAPIController, :update_background)

      get("/pleroma/mascot", MastodonAPIController, :get_mascot)
      put("/pleroma/mascot", MastodonAPIController, :set_mascot)

      post("/reports", MastodonAPIController, :reports)
    end

    scope [] do
      pipe_through(:oauth_follow)

      post("/follows", MastodonAPIController, :follow)
      post("/accounts/:id/follow", MastodonAPIController, :follow)

      post("/accounts/:id/unfollow", MastodonAPIController, :unfollow)
      post("/accounts/:id/block", MastodonAPIController, :block)
      post("/accounts/:id/unblock", MastodonAPIController, :unblock)
      post("/accounts/:id/mute", MastodonAPIController, :mute)
      post("/accounts/:id/unmute", MastodonAPIController, :unmute)

      post("/follow_requests/:id/authorize", FollowRequestController, :authorize)
      post("/follow_requests/:id/reject", FollowRequestController, :reject)

      post("/domain_blocks", DomainBlockController, :create)
      delete("/domain_blocks", DomainBlockController, :delete)

      post("/pleroma/accounts/:id/subscribe", MastodonAPIController, :subscribe)
      post("/pleroma/accounts/:id/unsubscribe", MastodonAPIController, :unsubscribe)
    end

    scope [] do
      pipe_through(:oauth_push)

      post("/push/subscription", SubscriptionController, :create)
      get("/push/subscription", SubscriptionController, :get)
      put("/push/subscription", SubscriptionController, :update)
      delete("/push/subscription", SubscriptionController, :delete)
    end
  end

  scope "/api/web", Pleroma.Web.MastodonAPI do
    pipe_through([:authenticated_api, :oauth_write])

    put("/settings", MastodonAPIController, :put_settings)
  end

  scope "/api/v1", Pleroma.Web.MastodonAPI do
    pipe_through(:api)

    post("/accounts", MastodonAPIController, :account_register)

    get("/instance", MastodonAPIController, :masto_instance)
    get("/instance/peers", MastodonAPIController, :peers)
    post("/apps", MastodonAPIController, :create_app)
    get("/apps/verify_credentials", MastodonAPIController, :verify_app_credentials)
    get("/custom_emojis", MastodonAPIController, :custom_emojis)

    get("/statuses/:id/card", StatusController, :card)

    get("/statuses/:id/favourited_by", StatusController, :favourited_by)
    get("/statuses/:id/reblogged_by", StatusController, :reblogged_by)

    get("/trends", MastodonAPIController, :empty_array)

    get("/accounts/search", SearchController, :account_search)

    post(
      "/pleroma/accounts/confirmation_resend",
      MastodonAPIController,
      :account_confirmation_resend
    )

    scope [] do
      pipe_through(:oauth_read_or_public)

      get("/timelines/public", TimelineController, :public)
      get("/timelines/tag/:tag", TimelineController, :hashtag)
      get("/timelines/list/:list_id", TimelineController, :list)

      get("/statuses", StatusController, :index)
      get("/statuses/:id", StatusController, :show)
      get("/statuses/:id/context", StatusController, :context)

      get("/polls/:id", MastodonAPIController, :get_poll)

      get("/accounts/:id/statuses", MastodonAPIController, :user_statuses)
      get("/accounts/:id/followers", MastodonAPIController, :followers)
      get("/accounts/:id/following", MastodonAPIController, :following)
      get("/accounts/:id", MastodonAPIController, :user)

      get("/search", SearchController, :search)

      get("/pleroma/accounts/:id/favourites", MastodonAPIController, :user_favourites)
    end
  end

  scope "/api/v2", Pleroma.Web.MastodonAPI do
    pipe_through([:api, :oauth_read_or_public])
    get("/search", SearchController, :search2)
  end

  scope "/api", Pleroma.Web do
    pipe_through(:config)

    get("/help/test", TwitterAPI.UtilController, :help_test)
    post("/help/test", TwitterAPI.UtilController, :help_test)
    get("/statusnet/config", TwitterAPI.UtilController, :config)
    get("/statusnet/version", TwitterAPI.UtilController, :version)
    get("/pleroma/frontend_configurations", TwitterAPI.UtilController, :frontend_configurations)
  end

  scope "/api", Pleroma.Web do
    pipe_through(:api)

    get(
      "/account/confirm_email/:user_id/:token",
      TwitterAPI.Controller,
      :confirm_email,
      as: :confirm_email
    )
  end

  scope "/api", Pleroma.Web, as: :authenticated_twitter_api do
    pipe_through(:authenticated_api)

    get("/oauth_tokens", TwitterAPI.Controller, :oauth_tokens)
    delete("/oauth_tokens/:id", TwitterAPI.Controller, :revoke_token)

    scope [] do
      pipe_through(:oauth_read)

      post("/qvitter/statuses/notifications/read", TwitterAPI.Controller, :notifications_read)
    end
  end

  pipeline :ap_service_actor do
    plug(:accepts, ["activity+json", "json"])
  end

  pipeline :ostatus do
    plug(:accepts, ["html", "xml", "atom", "activity+json", "json"])
  end

  pipeline :oembed do
    plug(:accepts, ["json", "xml"])
  end

  scope "/", Pleroma.Web do
    pipe_through(:ostatus)
    pipe_through(:http_signature)

    get("/objects/:uuid", OStatus.OStatusController, :object)
    get("/activities/:uuid", OStatus.OStatusController, :activity)
    get("/notice/:id", OStatus.OStatusController, :notice)
    get("/notice/:id/embed_player", OStatus.OStatusController, :notice_player)
    get("/users/:nickname/feed", OStatus.OStatusController, :feed)
    get("/users/:nickname", OStatus.OStatusController, :feed_redirect)

    post("/users/:nickname/salmon", OStatus.OStatusController, :salmon_incoming)
    post("/push/hub/:nickname", Websub.WebsubController, :websub_subscription_request)
    get("/push/subscriptions/:id", Websub.WebsubController, :websub_subscription_confirmation)
    post("/push/subscriptions/:id", Websub.WebsubController, :websub_incoming)

    get("/mailer/unsubscribe/:token", Mailer.SubscriptionController, :unsubscribe)
  end

  pipeline :activitypub do
    plug(:accepts, ["activity+json", "json"])
    plug(Pleroma.Web.Plugs.HTTPSignaturePlug)
    plug(Pleroma.Web.Plugs.MappedSignatureToIdentityPlug)
  end

  scope "/", Pleroma.Web.ActivityPub do
    # XXX: not really ostatus
    pipe_through(:ostatus)

    get("/users/:nickname/outbox", ActivityPubController, :outbox)
    get("/objects/:uuid/likes", ActivityPubController, :object_likes)
  end

  pipeline :activitypub_client do
    plug(:accepts, ["activity+json", "json"])
    plug(:fetch_session)
    plug(Pleroma.Plugs.OAuthPlug)
    plug(Pleroma.Plugs.BasicAuthDecoderPlug)
    plug(Pleroma.Plugs.UserFetcherPlug)
    plug(Pleroma.Plugs.SessionAuthenticationPlug)
    plug(Pleroma.Plugs.LegacyAuthenticationPlug)
    plug(Pleroma.Plugs.AuthenticationPlug)
    plug(Pleroma.Plugs.UserEnabledPlug)
    plug(Pleroma.Plugs.SetUserSessionIdPlug)
    plug(Pleroma.Plugs.EnsureUserKeyPlug)
  end

  scope "/", Pleroma.Web.ActivityPub do
    pipe_through([:activitypub_client])

    scope [] do
      pipe_through(:oauth_read)
      get("/api/ap/whoami", ActivityPubController, :whoami)
      get("/users/:nickname/inbox", ActivityPubController, :read_inbox)
    end

    scope [] do
      pipe_through(:oauth_write)
      post("/users/:nickname/outbox", ActivityPubController, :update_outbox)
    end

    scope [] do
      pipe_through(:oauth_read_or_public)
      get("/users/:nickname/followers", ActivityPubController, :followers)
      get("/users/:nickname/following", ActivityPubController, :following)
    end
  end

  scope "/", Pleroma.Web.ActivityPub do
    pipe_through(:activitypub)
    post("/inbox", ActivityPubController, :inbox)
    post("/users/:nickname/inbox", ActivityPubController, :inbox)
  end

  scope "/relay", Pleroma.Web.ActivityPub do
    pipe_through(:ap_service_actor)

    get("/", ActivityPubController, :relay)

    scope [] do
      pipe_through(:http_signature)
      post("/inbox", ActivityPubController, :inbox)
    end

    get("/following", ActivityPubController, :following, assigns: %{relay: true})
    get("/followers", ActivityPubController, :followers, assigns: %{relay: true})
  end

  scope "/internal/fetch", Pleroma.Web.ActivityPub do
    pipe_through(:ap_service_actor)

    get("/", ActivityPubController, :internal_fetch)
    post("/inbox", ActivityPubController, :inbox)
  end

  scope "/.well-known", Pleroma.Web do
    pipe_through(:well_known)

    get("/host-meta", WebFinger.WebFingerController, :host_meta)
    get("/webfinger", WebFinger.WebFingerController, :webfinger)
    get("/nodeinfo", Nodeinfo.NodeinfoController, :schemas)
  end

  scope "/nodeinfo", Pleroma.Web do
    get("/:version", Nodeinfo.NodeinfoController, :nodeinfo)
  end

  scope "/", Pleroma.Web.MastodonAPI do
    pipe_through(:mastodon_html)

    get("/web/login", MastodonAPIController, :login)
    delete("/auth/sign_out", MastodonAPIController, :logout)

    post("/auth/password", MastodonAPIController, :password_reset)

    scope [] do
      pipe_through(:oauth_read)
      get("/web/*path", MastodonAPIController, :index)
    end
  end

  pipeline :remote_media do
  end

  scope "/proxy/", Pleroma.Web.MediaProxy do
    pipe_through(:remote_media)

    get("/:sig/:url", MediaProxyController, :remote)
    get("/:sig/:url/:filename", MediaProxyController, :remote)
  end

  if Pleroma.Config.get(:env) == :dev do
    scope "/dev" do
      pipe_through([:mailbox_preview])

      forward("/mailbox", Plug.Swoosh.MailboxPreview, base_path: "/dev/mailbox")
    end
  end

  scope "/", Pleroma.Web.MongooseIM do
    get("/user_exists", MongooseIMController, :user_exists)
    get("/check_password", MongooseIMController, :check_password)
  end

  scope "/", Fallback do
    get("/registration/:token", RedirectController, :registration_page)
    get("/:maybe_nickname_or_id", RedirectController, :redirector_with_meta)
    get("/api*path", RedirectController, :api_not_implemented)
    get("/*path", RedirectController, :redirector)

    options("/*path", RedirectController, :empty)
  end
end
