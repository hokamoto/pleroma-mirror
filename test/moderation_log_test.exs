# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.ModerationLogTest do
  alias Pleroma.ModerationLog

  use Pleroma.DataCase

  import Pleroma.Factory

  describe "user moderation" do
    setup do
      admin = insert(:user, info: %{is_admin: true})
      moderator = insert(:user, info: %{is_moderator: true})
      subject = insert(:user)

      [admin: admin, moderator: moderator, subject: subject]
    end

    test "logging user deletion by moderator", %{moderator: moderator, subject: subject} do
      {:ok, %{data: %{subject_type: subject_type, action: action}}} =
        ModerationLog.insert_log("user", "delete", moderator, subject)

      log_entry =
        ModerationLog.get_log_entry(
          subject_type,
          action,
          moderator,
          subject
        )

      assert log_entry ==
               "@#{moderator.nickname} performed 'delete' action on user @#{subject.nickname}"
    end
  end
end
