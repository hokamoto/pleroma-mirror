defmodule Pleroma.User.SynchronizationTest do
  use Pleroma.DataCase
  import Pleroma.Factory
  alias Pleroma.User
  alias Pleroma.User.Synchronization

  setup_all do
    Tesla.Mock.mock_global(fn env -> apply(HttpRequestMock, :request, [env]) end)
    :ok
  end

  test "update following/followers count" do
    insert(:user,
      local: false,
      follower_address: "http://localhost:4001/users/masto-closed/followers"
    )

    insert(:user, local: false, follower_address: "http://localhost:4001/users/fuser2/followers")

    users = User.build_external_query()
    {user, %{}} = Synchronization.call(users, %{})
    assert user == List.last(users)
  end
end
