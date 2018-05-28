# https://hexdocs.pm/distillery/configuration.html

# Import all plugins from `rel/plugins`
Path.join(["rel", "plugins", "*.exs"])
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
    default_release: :default,
    default_environment: Mix.env()

# MIX_ENV=prod mix release --env dev
environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :test
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"INSECURE-CHANGE-ME"
end

release :pleroma do
  plugin Conform.ReleasePlugin

  set version: current_version(:pleroma)

  set applications: [
    :runtime_tools,
  ]

  set run_erl_env: "RUN_ERL_LOG_MAXSIZE=50000000 RUN_ERL_LOG_GENERATIONS=5"

  set vm_args: "rel/templates/vm.args.eex"

  set overlays: [
    {:copy, "config/pleroma.conf", "pleroma.conf.sample"},
    {:copy, "<%= output_dir %>/releases/<%= release_version %>/vm.args", "vm.args.sample"},
  ]

  set post_start_hook: "rel/hooks/post_start.sh"

  set commands: [
    "migrate": "rel/commands/migrate.sh",
    "user": "rel/commands/user.sh",
    "fix-ap-users": "rel/commands/fix-ap-users.sh"
  ]

end

