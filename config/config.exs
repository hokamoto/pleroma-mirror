#                                 .i;;;;i.
#                               iYcviii;vXY:
#                             .YXi       .i1c.
#                            .YC.     .    in7.
#                           .vc.   ......   ;1c.
#                           i7,   ..        .;1;
#                          i7,   .. ...      .Y1i
#                         ,7v     .6MMM@;     .YX,
#                        .7;.   ..IMMMMMM1     :t7.
#                       .;Y.     ;$MMMMMM9.     :tc.
#                       vY.   .. .nMMM@MMU.      ;1v.
#                      i7i   ...  .#MM@M@C. .....:71i
#                     it:   ....   $MMM@9;.,i;;;i,;tti
#                    :t7.  .....   0MMMWv.,iii:::,,;St.
#                   .nC.   .....   IMMMQ..,::::::,.,czX.
#                  .ct:   ....... .ZMMMI..,:::::::,,:76Y.
#                  c2:   ......,i..Y$M@t..:::::::,,..inZY
#                 vov   ......:ii..c$MBc..,,,,,,,,,,..iI9i
#                i9Y   ......iii:..7@MA,..,,,,,,,,,....;AA:
#               iIS.  ......:ii::..;@MI....,............;Ez.
#              .I9.  ......:i::::...8M1..................C0z.
#             .z9;  ......:i::::,.. .i:...................zWX.
#             vbv  ......,i::::,,.      ................. :AQY
#            c6Y.  .,...,::::,,..:t0@@QY. ................ :8bi
#           :6S. ..,,...,:::,,,..EMMMMMMI. ............... .;bZ,
#          :6o,  .,,,,..:::,,,..i#MMMMMM#v.................  YW2.
#         .n8i ..,,,,,,,::,,,,.. tMMMMM@C:.................. .1Wn
#         7Uc. .:::,,,,,::,,,,..   i1t;,..................... .UEi
#         7C...::::::::::::,,,,..        ....................  vSi.
#         ;1;...,,::::::,.........       ..................    Yz:
#          v97,.........                                     .voC.
#           izAotX7777777777777777777777777777777777777777Y7n92:
#             .;CoIIIIIUAA666666699999ZZZZZZZZZZZZZZZZZZZZ6ov.
#
#                          !!! ATTENTION !!!
# DO NOT EDIT THIS FILE! THIS FILE CONTAINS THE DEFAULT VALUES FOR THE CON-
# FIGURATION! EDIT YOUR SECRET FILE (either prod.secret.exs, dev.secret.exs).
#
# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :pleroma, ecto_repos: [Pleroma.Repo]

config :pleroma, Pleroma.Repo,
  types: Pleroma.PostgresTypes,
  telemetry_event: [Pleroma.Repo.Instrumenter]

config :pleroma, Pleroma.Captcha,
  enabled: false,
  seconds_valid: 60,
  method: Pleroma.Captcha.Kocaptcha

config :pleroma, :hackney_pools,
  federation: [
    max_connections: 50,
    timeout: 150_000
  ],
  media: [
    max_connections: 50,
    timeout: 150_000
  ],
  upload: [
    max_connections: 25,
    timeout: 300_000
  ]

config :pleroma, Pleroma.Captcha.Kocaptcha, endpoint: "https://captcha.kotobank.ch"

# Upload configuration
config :pleroma, Pleroma.Upload,
  uploader: Pleroma.Uploaders.Local,
  filters: [Pleroma.Upload.Filter.Dedupe],
  link_name: true,
  proxy_remote: false,
  proxy_opts: [
    redirect_on_failure: false,
    max_body_length: 25 * 1_048_576,
    http: [
      follow_redirect: true,
      pool: :upload
    ]
  ]

config :pleroma, Pleroma.Uploaders.Local, uploads: "uploads"

config :pleroma, Pleroma.Uploaders.S3,
  bucket: nil,
  public_endpoint: "https://s3.amazonaws.com"

config :pleroma, Pleroma.Uploaders.MDII,
  cgi: "https://mdii.sakura.ne.jp/mdii-post.cgi",
  files: "https://mdii.sakura.ne.jp"

config :pleroma, :emoji,
  shortcode_globs: ["/emoji/custom/**/*.png"],
  groups: [
    # Put groups that have higher priority than defaults here. Example in `docs/config/custom_emoji.md`
    Finmoji: "/finmoji/128px/*-128.png",
    Custom: ["/emoji/*.png", "/emoji/custom/*.png"]
  ]

config :pleroma, :uri_schemes,
  valid_schemes: [
    "https",
    "http",
    "dat",
    "dweb",
    "gopher",
    "ipfs",
    "ipns",
    "irc",
    "ircs",
    "magnet",
    "mailto",
    "mumble",
    "ssb",
    "xmpp"
  ]

websocket_config = [
  path: "/websocket",
  serializer: [
    {Phoenix.Socket.V1.JSONSerializer, "~> 1.0.0"},
    {Phoenix.Socket.V2.JSONSerializer, "~> 2.0.0"}
  ],
  timeout: 60_000,
  transport_log: false,
  compress: false
]

# Configures the endpoint
config :pleroma, Pleroma.Web.Endpoint,
  instrumenters: [Pleroma.Web.Endpoint.Instrumenter],
  url: [host: "localhost"],
  http: [
    dispatch: [
      {:_,
       [
         {"/api/v1/streaming", Pleroma.Web.MastodonAPI.WebsocketHandler, []},
         {"/websocket", Phoenix.Endpoint.CowboyWebSocket,
          {Phoenix.Transports.WebSocket,
           {Pleroma.Web.Endpoint, Pleroma.Web.UserSocket, websocket_config}}},
         {:_, Phoenix.Endpoint.Cowboy2Handler, {Pleroma.Web.Endpoint, []}}
       ]}
    ]
  ],
  protocol: "https",
  secret_key_base: "aK4Abxf29xU9TTDKre9coZPUgevcVCFQJe/5xP/7Lt4BEif6idBIbjupVbOrbKxl",
  signing_salt: "CqaoopA2",
  render_errors: [view: Pleroma.Web.ErrorView, accepts: ~w(json)],
  pubsub: [name: Pleroma.PubSub, adapter: Phoenix.PubSub.PG2],
  secure_cookie_flag: true,
  extra_cookie_attrs: [
    "SameSite=Lax"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :logger, :ex_syslogger,
  level: :debug,
  ident: "Pleroma",
  format: "$metadata[$level] $message",
  metadata: [:request_id]

config :quack,
  level: :warn,
  meta: [:all],
  webhook_url: "https://hooks.slack.com/services/YOUR-KEY-HERE"

config :mime, :types, %{
  "application/xml" => ["xml"],
  "application/xrd+xml" => ["xrd+xml"],
  "application/jrd+json" => ["jrd+json"],
  "application/activity+json" => ["activity+json"],
  "application/ld+json" => ["activity+json"]
}

config :pleroma, :websub, Pleroma.Web.Websub
config :pleroma, :ostatus, Pleroma.Web.OStatus
config :pleroma, :httpoison, Pleroma.HTTP
config :tesla, adapter: Tesla.Adapter.Hackney

# Configures http settings, upstream proxy etc.
config :pleroma, :http,
  proxy_url: nil,
  adapter: [
    ssl_options: [
      # We don't support TLS v1.3 yet
      versions: [:tlsv1, :"tlsv1.1", :"tlsv1.2"]
    ]
  ]

config :pleroma, :instance,
  name: "Pleroma",
  email: "example@example.com",
  notify_email: "noreply@example.com",
  description: "A Pleroma instance, an alternative fediverse server",
  limit: 5_000,
  remote_limit: 100_000,
  upload_limit: 16_000_000,
  avatar_upload_limit: 2_000_000,
  background_upload_limit: 4_000_000,
  banner_upload_limit: 4_000_000,
  registrations_open: true,
  federating: true,
  federation_reachability_timeout_days: 7,
  allow_relay: true,
  rewrite_policy: Pleroma.Web.ActivityPub.MRF.NoOpPolicy,
  public: true,
  quarantined_instances: [],
  managed_config: true,
  static_dir: "instance/static/",
  allowed_post_formats: [
    "text/plain",
    "text/html",
    "text/markdown"
  ],
  finmoji_enabled: true,
  mrf_transparency: true,
  autofollowed_nicknames: [],
  max_pinned_statuses: 1,
  no_attachment_links: false,
  welcome_user_nickname: nil,
  welcome_message: nil,
  max_report_comment_size: 1000,
  safe_dm_mentions: false

config :pleroma, :markup,
  # XXX - unfortunately, inline images must be enabled by default right now, because
  # of custom emoji.  Issue #275 discusses defanging that somehow.
  allow_inline_images: true,
  allow_headings: false,
  allow_tables: false,
  allow_fonts: false,
  scrub_policy: [
    Pleroma.HTML.Transform.MediaProxy,
    Pleroma.HTML.Scrubber.Default
  ]

# Deprecated, will be gone in 1.0
config :pleroma, :fe,
  theme: "pleroma-dark",
  logo: "/static/logo.png",
  logo_mask: true,
  logo_margin: "0.1em",
  background: "/static/aurora_borealis.jpg",
  redirect_root_no_login: "/main/all",
  redirect_root_login: "/main/friends",
  show_instance_panel: true,
  scope_options_enabled: false,
  formatting_options_enabled: false,
  collapse_message_with_subject: false,
  hide_post_stats: false,
  hide_user_stats: false,
  scope_copy: true,
  subject_line_behavior: "email",
  always_show_subject_input: true

config :pleroma, :frontend_configurations,
  pleroma_fe: %{
    theme: "pleroma-dark",
    logo: "/static/logo.png",
    background: "/images/city.jpg",
    redirectRootNoLogin: "/main/all",
    redirectRootLogin: "/main/friends",
    showInstanceSpecificPanel: true,
    scopeOptionsEnabled: false,
    formattingOptionsEnabled: false,
    collapseMessageWithSubject: false,
    hidePostStats: false,
    hideUserStats: false,
    scopeCopy: true,
    subjectLineBehavior: "email",
    alwaysShowSubjectInput: true
  },
  masto_fe: %{
    showInstanceSpecificPanel: true
  }

config :pleroma, :activitypub,
  accept_blocks: true,
  unfollow_blocked: true,
  outgoing_blocks: true,
  follow_handshake_timeout: 500

config :pleroma, :user, deny_follow_blocked: true

config :pleroma, :mrf_normalize_markup, scrub_policy: Pleroma.HTML.Scrubber.Default

config :pleroma, :mrf_rejectnonpublic,
  allow_followersonly: false,
  allow_direct: false

config :pleroma, :mrf_hellthread,
  delist_threshold: 10,
  reject_threshold: 20

config :pleroma, :mrf_simple,
  media_removal: [],
  media_nsfw: [],
  federated_timeline_removal: [],
  reject: [],
  accept: []

config :pleroma, :mrf_keyword,
  reject: [],
  federated_timeline_removal: [],
  replace: []

config :pleroma, :rich_media, enabled: true

config :pleroma, :media_proxy,
  enabled: false,
  proxy_opts: [
    redirect_on_failure: false,
    max_body_length: 25 * 1_048_576,
    http: [
      follow_redirect: true,
      pool: :media
    ]
  ]

config :pleroma, :chat, enabled: true

config :phoenix, :format_encoders, json: Jason

config :pleroma, :gopher,
  enabled: false,
  ip: {0, 0, 0, 0},
  port: 9999

config :pleroma, Pleroma.Web.Metadata,
  providers: [Pleroma.Web.Metadata.Providers.RelMe],
  unfurl_nsfw: false

config :pleroma, :suggestions,
  enabled: false,
  third_party_engine:
    "http://vinayaka.distsn.org/cgi-bin/vinayaka-user-match-suggestions-api.cgi?{{host}}+{{user}}",
  timeout: 300_000,
  limit: 23,
  web: "https://vinayaka.distsn.org/?{{host}}+{{user}}"

config :pleroma, :http_security,
  enabled: true,
  sts: false,
  sts_max_age: 31_536_000,
  ct_max_age: 2_592_000,
  referrer_policy: "same-origin"

config :cors_plug,
  max_age: 86_400,
  methods: ["POST", "PUT", "DELETE", "GET", "PATCH", "OPTIONS"],
  expose: [
    "Link",
    "X-RateLimit-Reset",
    "X-RateLimit-Limit",
    "X-RateLimit-Remaining",
    "X-Request-Id",
    "Idempotency-Key"
  ],
  credentials: true,
  headers: ["Authorization", "Content-Type", "Idempotency-Key"]

config :pleroma, Pleroma.User,
  restricted_nicknames: [
    ".well-known",
    "~",
    "about",
    "activities",
    "api",
    "auth",
    "dev",
    "friend-requests",
    "inbox",
    "internal",
    "main",
    "media",
    "nodeinfo",
    "notice",
    "oauth",
    "objects",
    "ostatus_subscribe",
    "pleroma",
    "proxy",
    "push",
    "registration",
    "relay",
    "settings",
    "status",
    "tag",
    "user-search",
    "users",
    "web"
  ]

config :pleroma, Pleroma.Web.Federator.RetryQueue,
  enabled: false,
  max_jobs: 20,
  initial_timeout: 30,
  max_retries: 5

config :pleroma_job_queue, :queues,
  federator_incoming: 50,
  federator_outgoing: 50,
  web_push: 50,
  mailer: 10,
  transmogrifier: 20,
  scheduled_activities: 10

config :pleroma, :fetch_initial_posts,
  enabled: false,
  pages: 5

config :auto_linker,
  opts: [
    scheme: true,
    extra: true,
    class: false,
    strip_prefix: false,
    new_window: false,
    rel: false
  ]

config :pleroma, :ldap,
  enabled: System.get_env("LDAP_ENABLED") == "true",
  host: System.get_env("LDAP_HOST") || "localhost",
  port: String.to_integer(System.get_env("LDAP_PORT") || "389"),
  ssl: System.get_env("LDAP_SSL") == "true",
  sslopts: [],
  tls: System.get_env("LDAP_TLS") == "true",
  tlsopts: [],
  base: System.get_env("LDAP_BASE") || "dc=example,dc=com",
  uid: System.get_env("LDAP_UID") || "cn"

oauth_consumer_strategies = String.split(System.get_env("OAUTH_CONSUMER_STRATEGIES") || "")

ueberauth_providers =
  for strategy <- oauth_consumer_strategies do
    strategy_module_name = "Elixir.Ueberauth.Strategy.#{String.capitalize(strategy)}"
    strategy_module = String.to_atom(strategy_module_name)
    {String.to_atom(strategy), {strategy_module, [callback_params: ["state"]]}}
  end

config :ueberauth,
       Ueberauth,
       base_path: "/oauth",
       providers: ueberauth_providers

config :etag_plug,
  generator: ETag.Generator.SHA1,
  methods: ["GET"],
  status_codes: [:ok, 200, :not_modified]

config :pleroma, :auth, oauth_consumer_strategies: oauth_consumer_strategies

config :pleroma, Pleroma.Emails.Mailer, adapter: Swoosh.Adapters.Sendmail

config :prometheus, Pleroma.Web.Endpoint.MetricsExporter, path: "/api/pleroma/app_metrics"

config :pleroma, Pleroma.ScheduledActivity,
  daily_user_limit: 25,
  total_user_limit: 300,
  enabled: true

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
