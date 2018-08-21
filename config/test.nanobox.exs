use Mix.Config

# Overwrite the database settings with Nanobox ones
config :pleroma, Pleroma.Repo,
  username: System.get_env("DATA_DB_USER"),
  password: System.get_env("DATA_DB_PASS"),
  hostname: System.get_env("DATA_DB_HOST")

# Overwrite the endpoint
config :pleroma, Pleroma.Web.Endpoint,
  url: [host: "phoenix.local"]
