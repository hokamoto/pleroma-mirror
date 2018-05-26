echo "-*- Running migrations"
bin/pleroma rpc Elixir.Pleroma.CLI.Migrate migrate
