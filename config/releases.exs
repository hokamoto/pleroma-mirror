import Config

config :pleroma, :instance, static_dir: "/var/lib/pleroma/static"
config :pleroma, Pleroma.Uploaders.Local, uploads: "/var/lib/pleroma/uploads"
config :pleroma, :modules, runtime_dir: "/var/lib/pleroma/modules"

config_path = System.get_env("PLEROMA_CONFIG_PATH") || "/etc/pleroma/config.exs"

config :pleroma, release: true, config_path: config_path

if File.exists?(config_path) do
  import_config config_path
else
  warning = [
    IO.ANSI.red(),
    IO.ANSI.bright(),
    "!!! #{config_path} not found! Please ensure it exists and that PLEROMA_CONFIG_PATH is unset or points to an existing file",
    IO.ANSI.reset()
  ]

  IO.puts(warning)
end

config_path_dir = Path.dirname(config_path)

for_reboot_config = Path.join(config_path_dir, "prod.for_reboot.exs")

if File.exists?(for_reboot_config) do
  import_config for_reboot_config
end

exported_config = Path.join(config_path_dir, "prod.exported_from_db.secret.exs")

if File.exists?(exported_config) do
  import_config exported_config
end
