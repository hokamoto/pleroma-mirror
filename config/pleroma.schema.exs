@moduledoc """
A schema is a keyword list which represents how to map, transform, and validate
configuration values parsed from the .conf file. The following is an explanation of
each key in the schema definition in order of appearance, and how to use them.

See the moduledoc for `Conform.Schema.Validator` for more details and examples.
"""
[
  extends: [],
  import: [],
  mappings: [
    "pleroma.uploads.directory": [
      commented: false,
      datatype: :binary,
      default: "uploads",
      doc: "Uploads directory.",
      hidden: false,
      to: "pleroma.Elixir.Pleroma.Upload.uploads"
    ],
    "pleroma.http.proxy_url": [
      commented: false,
      datatype: :binary,
      doc: "Upstream HTTP proxy.",
      hidden: false,
      default: nil,
      to: "pleroma.http.proxy_url"
    ],
    "pleroma.chat.enabled": [
      commented: false,
      datatype: :atom,
      default: true,
      doc: "Enables chat.",
      hidden: false,
      to: "pleroma.chat.enabled"
    ],
    "pleroma.db.adapter": [
      commented: false,
      datatype: :atom,
      default: Ecto.Adapters.Postgres,
      doc: "Database adapter.",
      hidden: false,
      to: "pleroma.Elixir.Pleroma.Repo.adapter"
    ],
    "pleroma.db.username": [
      commented: false,
      datatype: :binary,
      default: "postgres",
      doc: "Database username.",
      hidden: false,
      to: "pleroma.Elixir.Pleroma.Repo.username"
    ],
    "pleroma.db.password": [
      commented: false,
      datatype: :binary,
      default: "postgres",
      doc: "Database password.",
      hidden: false,
      to: "pleroma.Elixir.Pleroma.Repo.password"
    ],
    "pleroma.db.database": [
      commented: false,
      datatype: :binary,
      default: "pleroma_dev",
      doc: "Database name.",
      hidden: false,
      to: "pleroma.Elixir.Pleroma.Repo.database"
    ],
    "pleroma.db.hostname": [
      commented: false,
      datatype: :binary,
      default: "localhost",
      doc: "Database hostname.",
      hidden: false,
      to: "pleroma.Elixir.Pleroma.Repo.hostname"
    ],
    "pleroma.db.pool_size": [
      commented: false,
      datatype: :integer,
      default: 10,
      doc: "Database pool size.",
      hidden: false,
      to: "pleroma.Elixir.Pleroma.Repo.pool_size"
    ],
    "pleroma.web.secret_key_base": [
      commented: false,
      datatype: :binary,
      default: "UNSECURE_CHANGE_ME",
      doc: "Secret key.",
      hidden: false,
      to: "pleroma.Elixir.Pleroma.Web.Endpoint.secret_key_base"
    ],
    "pleroma.url.host": [
      commented: false,
      datatype: :binary,
      default: "instance.domain.com",
      doc: "Instance host.",
      hidden: false,
      to: "pleroma.Elixir.Pleroma.Web.Endpoint.url.host"
    ],
    "pleroma.url.scheme": [
      commented: true,
      datatype: :binary,
      default: "https",
      doc: "Instance scheme.",
      hidden: false,
      to: "pleroma.Elixir.Pleroma.Web.Endpoint.url.port"
    ],
    "pleroma.url.port": [
      commented: true,
      datatype: :integer,
      default: 443,
      doc: "Instance port.",
      hidden: false,
      to: "pleroma.Elixir.Pleroma.Web.Endpoint.url.port"
    ],
    "pleroma.http.ip": [
      commented: false,
      datatype: :binary,
      default: "0.0.0.0",
      doc: "Web server: bind host.",
      hidden: false,
      to: "pleroma.Elixir.Pleroma.Web.Endpoint.http.ip"
    ],
    "pleroma.http.port": [
      commented: false,
      datatype: :integer,
      default: 4000,
      doc: "Web server: bind port.",
      hidden: false,
      to: "pleroma.Elixir.Pleroma.Web.Endpoint.http.port"
    ],
    "pleroma.instance.upload_limit": [
      commented: false,
      datatype: :integer,
      default: 16000000,
      doc: "Instance upload limit.",
      hidden: false,
      to: "pleroma.instance.upload_limit"
    ],
    "pleroma.instance.federating": [
      commented: false,
      datatype: :atom,
      default: true,
      doc: "Instance federation.",
      hidden: false,
      to: "pleroma.instance.federating"
    ],
    # TODO transform
    "pleroma.instance.rewrite_policies": [
      commented: false,
      datatype: [list: :atom],
      default: [Pleroma.Web.ActivityPub.MRF.NoOpPolicy],
      doc: "Instance rewrite policies.",
      hidden: false,
      to: "pleroma.instance.rewrite_policy"
    ],
    "pleroma.instance.public": [
      commented: false,
      datatype: :atom,
      default: true,
      doc: "Instance: set as public.",
      hidden: false,
      to: "pleroma.instance.public"
    ],
    "pleroma.instance.name": [
      commented: false,
      datatype: :binary,
      default: "Pleroma",
      doc: "Instance name.",
      hidden: false,
      to: "pleroma.instance.name"
    ],
    "pleroma.instance.email": [
      commented: false,
      datatype: :binary,
      default: "contact@email",
      doc: "Instance contact email.",
      hidden: false,
      to: "pleroma.instance.email"
    ],
    "pleroma.instance.limit": [
      commented: false,
      datatype: :integer,
      default: 5000,
      doc: "Instance character limit.",
      hidden: false,
      to: "pleroma.instance.limit"
    ],
    "pleroma.instance.registrations_open": [
      commented: false,
      datatype: :atom,
      default: true,
      doc: "Instance: open registrations.",
      hidden: false,
      to: "pleroma.instance.registrations_open"
    ],
    "pleroma.mrf_simple.media_removal": [
      commented: true,
      datatype: [list: :binary],
      default: [],
      hidden: false,
      doc: "MRF Simple: media removal",
      to: "pleroma.mrf_simple.media_removal"
    ],
    "pleroma.mrf_simple.media_nsfw": [
      commented: true,
      datatype: [list: :binary],
      default: [],
      hidden: false,
      doc: "MRF Simple: mark media as NSFW",
      to: "pleroma.mrf_simple.media_nsfw"
    ],
    "pleroma.mrf_simple.federated_timeline_removal": [
      commented: true,
      datatype: [list: :binary],
      default: [],
      hidden: false,
      doc: "MRF Simple: federated timeline removal",
      to: "pleroma.mrf_simple.federated_timeline_removal"
    ],
    "pleroma.mrf_simple.reject": [
      commented: true,
      datatype: [list: :binary],
      default: [],
      hidden: false,
      doc: "MRF Simple: reject incoming activities",
      to: "pleroma.mrf_simple.reject"
    ],
    "pleroma.media_proxy.enabled": [
      commented: false,
      datatype: :atom,
      default: true,
      doc: "Enabled media proxy.",
      hidden: false,
      to: "pleroma.media_proxy.enabled"
    ],
    "pleroma.media_proxy.redirect_on_failure": [
      commented: true,
      datatype: :atom,
      default: true,
      doc: "Media proxy: redirect to original URI on failure.",
      hidden: false,
      to: "pleroma.media_proxy.redirect_on_failure"
    ],
    "pleroma.media_proxy.base_url": [
      commented: true,
      datatype: :binary,
      default: nil,
      doc: "Media proxy: set another base URL if you're caching on a subdomain",
      hidden: false,
      to: "pleroma.media_proxy.base_url"
    ],
    "pleroma.gopher.enabled": [
      commented: false,
      datatype: :atom,
      default: false,
      doc: "Enable gopher server.",
      hidden: false,
      to: "pleroma.gopher.enabled"
    ],
    # TODO transform
    "pleroma.gopher.ip": [
      commented: true,
      datatype: :binary,
      default: "0.0.0.0",
      doc: "Gopher: bind IP.",
      hidden: false,
      to: "pleroma.gopher.ip"
    ],
    "pleroma.gopher.port": [
      commented: true,
      datatype: :integer,
      default: 9999,
      doc: "Gopher: bind port.",
      hidden: false,
      to: "pleroma.gopher.port"
    ],
  ],
  transforms: [
    "pleroma.gopher.ip": fn conf ->
      [{_, ip}] = Conform.Conf.get(conf, "pleroma.gopher.ip")
      {:ok, ipaddr} = ip
      |> String.to_charlist
      |> :inet.parse_address
      ipaddr
    end,
    "pleroma.Elixir.Pleroma.Web.Endpoint.http.ip": fn conf ->
      [{_, ip}] = Conform.Conf.get(conf, "pleroma.Elixir.Pleroma.Web.Endpoint.http.ip")
      {:ok, ipaddr} = ip
      |> String.to_charlist
      |> :inet.parse_address
      ipaddr
    end,
  ],
  validators: []
]
