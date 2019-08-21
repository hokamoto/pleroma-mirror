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
      subject1 = insert(:user)
      subject2 = insert(:user)

      [admin: admin, moderator: moderator, subject1: subject1, subject2: subject2]
    end

    test "logging user deletion by moderator", %{moderator: moderator, subject1: subject1} do
      {:ok, _} =
        ModerationLog.insert_log(%{
          actor: moderator,
          subject: subject1,
          action: "delete"
        })

      log = Repo.one(ModerationLog)

      assert ModerationLog.get_log_entry_message(log) ==
               "[#{log.inserted_at}] @#{moderator.nickname} deleted user @#{subject1.nickname}"
    end

    test "logging user creation by moderator", %{moderator: moderator, subject1: subject1} do
      {:ok, _} =
        ModerationLog.insert_log(%{
          actor: moderator,
          subject: subject1,
          action: "create"
        })

      log = Repo.one(ModerationLog)

      assert ModerationLog.get_log_entry_message(log) ==
               "[#{log.inserted_at}] @#{moderator.nickname} created user @#{subject1.nickname}"
    end

    test "logging user follow by admin", %{admin: admin, subject1: subject1, subject2: subject2} do
      {:ok, _} =
        ModerationLog.insert_log(%{
          actor: admin,
          followed: subject1,
          follower: subject2,
          action: "follow"
        })

      log = Repo.one(ModerationLog)

      assert ModerationLog.get_log_entry_message(log) ==
               "[#{log.inserted_at}] @#{admin.nickname} made @#{subject2.nickname} follow @#{
                 subject1.nickname
               }"
    end

    test "logging user unfollow by admin", %{admin: admin, subject1: subject1, subject2: subject2} do
      {:ok, _} =
        ModerationLog.insert_log(%{
          actor: admin,
          followed: subject1,
          follower: subject2,
          action: "unfollow"
        })

      log = Repo.one(ModerationLog)

      assert ModerationLog.get_log_entry_message(log) ==
               "[#{log.inserted_at}] @#{admin.nickname} made @#{subject2.nickname} unfollow @#{
                 subject1.nickname
               }"
    end

    test "logging user tagged by admin", %{admin: admin, subject1: subject1, subject2: subject2} do
      {:ok, _} =
        ModerationLog.insert_log(%{
          actor: admin,
          nicknames: [subject1.nickname, subject2.nickname],
          tags: ["foo", "bar"],
          action: "tag"
        })

      log = Repo.one(ModerationLog)

      users =
        [subject1.nickname, subject2.nickname]
        |> Enum.map(&"@#{&1}")
        |> Enum.join(", ")

      tags = ["foo", "bar"] |> Enum.join(", ")

      assert ModerationLog.get_log_entry_message(log) ==
               "[#{log.inserted_at}] @#{admin.nickname} tagged users: #{users} with #{tags}"
    end

    test "logging user untagged by admin", %{admin: admin, subject1: subject1, subject2: subject2} do
      {:ok, _} =
        ModerationLog.insert_log(%{
          actor: admin,
          nicknames: [subject1.nickname, subject2.nickname],
          tags: ["foo", "bar"],
          action: "untag"
        })

      log = Repo.one(ModerationLog)

      users =
        [subject1.nickname, subject2.nickname]
        |> Enum.map(&"@#{&1}")
        |> Enum.join(", ")

      tags = ["foo", "bar"] |> Enum.join(", ")

      assert ModerationLog.get_log_entry_message(log) ==
               "[#{log.inserted_at}] @#{admin.nickname} removed tags: #{tags} from users: #{users}"
    end
  end
end
