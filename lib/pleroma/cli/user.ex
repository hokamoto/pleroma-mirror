defmodule Pleroma.CLI.User do
  alias Pleroma.{Repo, User}

  @commands ~w(deactivate reset-password moderator delete)

  def run(args) when is_binary(args) do
    run(String.split(args))
  end

  def run([command, nickname | args]) when command in @commands do
    run(command, nickname, args)
  end

  def run(["register" | args]) do
    run("register", args)
  end

  def run("register", [username, email | args]) do
    {reset_password, password} =
      case args do
        [password] -> {false, password}
        _ -> {true, :crypto.strong_rand_bytes(32) |> Base.encode64() |> binary_part(0, 32)}
      end

    params = %{
      name: username,
      nickname: username,
      email: email,
      password: password,
      password_confirmation: password,
      bio: ""
    }

    user = User.register_changeset(%User{}, params)

    case Repo.insert(user) do
      {:ok, user} ->
        IO.puts("User #{username} created!")

        if reset_password do
          execute("reset-password", user, [])
        else
          :ok
        end

      {:error, error} ->
        IO.puts("Failed to create user: #{inspect(error)}")
        {:error, error}
    end
  end

  def run(command, nickname, args) when is_binary(nickname) do
    {:ok, _} = Application.ensure_all_started(:pleroma)
    user = User.get_by_nickname(nickname)

    case execute(command, user, args) do
      :ok ->
        :ok

      {:ok, ok} ->
        {:ok, ok}

      error ->
        IO.puts("Error: #{inspect(error)}")
        error
    end
  end

  def run(_) do
    IO.puts("""
    Unknown command or missing parameters.

    - register [username] [email] <password>
      If password is empty, a reset link will be generated
    - reset-password [username]
    - moderator [username] <true|false>
    - deactivate [username]
    - delete [username]
    """)

    :error
  end

  defp execute(_, nil, _) do
    {:error, :user_not_found}
  end

  defp execute("deactivate", user, _) do
    User.deactivate(user)
  end

  defp execute("delete", user = %User{local: true}, _) do
    User.delete(user)
  end

  defp execute("delete", _, _), do: {:error, :user_not_local}

  defp execute("moderator", user = %User{local: true}, args) do
    moderator =
      case args do
        [moderator] -> moderator == "true"
        _ -> true
      end

    info =
      user.info
      |> Map.put("is_moderator", !!moderator)

    cng = User.info_changeset(user, %{info: info})

    case Repo.update(cng) do
      {:ok, user} ->
        IO.puts("Moderator status of #{user.nickname}: #{user.info["is_moderator"]}")
        {:ok, user}

      error ->
        IO.puts("Failed to change moderator status of #{user.nickname}: #{inspect(error)}")
        error
    end
  end

  defp execute("moderator", _, _) do
    {:error, :user_not_local}
  end

  defp execute("reset-password", user = %User{local: true}, _) do
    {:ok, token} = Pleroma.PasswordResetToken.create_token(user)

    url =
      Pleroma.Web.Router.Helpers.util_url(Pleroma.Web.Endpoint, :show_password_reset, token.token)

    IO.puts("Generated password reset token for #{user.nickname}")
    IO.puts("URL: #{url}")
    {:ok, url}
  end

  defp execute("reset-password", _, _) do
    {:error, :user_not_local}
  end

  defp execute(command, _, args) do
    {:error, {:command, command, args}}
  end
end
