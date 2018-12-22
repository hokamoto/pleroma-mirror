ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Pleroma.Repo, :manual)
{:ok, _} = Application.ensure_all_started(:ex_machina)

# Fixes CI unit test error: ** (CompileError) Pleroma.User.__struct__/1 is undefined, cannot expand struct Pleroma.User
true = Code.ensure_compiled?(Pleroma.User)
