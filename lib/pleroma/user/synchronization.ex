defmodule Pleroma.User.Synchronization do
  alias Pleroma.HTTP
  alias Pleroma.User

  @spec call([User.t()], map()) :: {User.t(), map()}
  def call(users, errors) do
    do_call(users, errors)
  end

  defp do_call([user | []], errors) do
    updated = fetch_counters(user, errors)
    {user, updated}
  end

  defp do_call([user | others], errors) do
    updated = fetch_counters(user, errors)
    do_call(others, updated)
  end

  defp fetch_counters(user, errors) do
    uri = URI.parse(user.follower_address)

    with true <- available_domain?(uri.host, errors),
         {:ok, %{body: body, status: code}} when code in 200..299 <-
           HTTP.get(
             user.follower_address,
             [{:Accept, "application/activity+json"}]
           ),
         {:ok, data} <- Jason.decode(body) do
      IO.inspect(data["totalItems"])
    else
      false ->
        errors

      e ->
        IO.inspect(e)
        e = Map.update(errors, uri.host, 1, &(&1 + 1))
        IO.inspect(e)
        e
    end
  end

  defp available_domain?(domain, errors) do
    not (Map.has_key?(errors, domain) && errors[domain] >= 3)
  end
end
