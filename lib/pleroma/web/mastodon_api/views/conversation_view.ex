defmodule Pleroma.Web.MastodonAPI.ConversationView do
  use Pleroma.Web, :view

  alias Pleroma.Web.MastodonAPI.AccountView
  alias Pleroma.Web.MastodonAPI.StatusView

  def render("participation.json", %{participation: participation, user: user}) do
    last_status =
      StatusView.render("status.json", %{activity: participation.last_activity, for: user})

    # Conversations return all users except the current user.
    users =
      participation.conversation.users
      |> Enum.reject(&(&1.id == user.id))

    accounts =
      AccountView.render("accounts.json", %{
        users: users,
        as: :user
      })

    %{
      id: to_string(participation.id),
      accounts: accounts,
      unread: !participation.read,
      last_status: last_status
    }
  end
end
