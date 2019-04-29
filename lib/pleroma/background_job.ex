defmodule Pleroma.BackgroundJob do
  def perform(:delete_user, user) do
    Pleroma.User.delete(user)
  end
end
