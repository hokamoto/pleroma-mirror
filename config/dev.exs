use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :pleroma, Pleroma.Web.Endpoint,
  http: [
    port: 4000,
    protocol_options: [max_request_line_length: 8192, max_header_value_length: 8192]
  ],
  protocol: "http",
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

# Do not include metadata nor timestamps in development logs
#config :logger, :console, format: "[$level] $message\n"
config :logger, level: :warn

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
#config :phoenix, :stacktrace_depth, 20

# Configure your database
#config :pleroma, Pleroma.Repo,
#  adapter: Ecto.Adapters.Postgres,
#  username: "pleroma",
#  password: "pleroma",
#  database: "pleroma_dev",
#  hostname: "localhost",
#  pool_size: 10

try do
  import_config "dev.secret.exs"
rescue
  _ ->
    IO.puts(
      "!!! RUNNING IN LOCALHOST DEV MODE! !!!\nFEDERATION WON'T WORK UNTIL YOU CONFIGURE A dev.secret.exs"
    )
end
