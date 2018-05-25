echo "-*- Running migrations"
bin/pleroma rpc Elixir.Pleroma.Release.MigrateTask migrate
