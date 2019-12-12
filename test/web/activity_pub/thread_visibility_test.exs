# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-onl

defmodule Pleroma.Web.ActivityPub.ThreadVisibilityTest do
  use Pleroma.DataCase

  import Pleroma.Factory

  alias Pleroma.Constants
  alias Pleroma.User
  alias Pleroma.Web.ActivityPub.ActivityPub
  alias Pleroma.Web.CommonAPI

  require Pleroma.Constants

  describe "public root post" do
    setup do
      [u1, u2, u3, u4] = prepare_users()
      a = create_activity(u1)

      private_replies = create_thread(u1, u2, a, "private")
      public_replies = create_thread(u1, u4, a)

      {:ok,
       users: %{u1: u1, u2: u2, u3: u3, u4: u4},
       a: a,
       private: private_replies,
       public: public_replies}
    end

    test "thread_contaiment is off", %{
      users: users,
      a: a,
      private: private,
      public: public
    } do
      assert_timelines(
        Map.put(users[:u1], :skip_thread_containment, true),
        Map.values(public) ++ Map.values(private) ++ [a],
        Map.values(public) ++ [a]
      )

      assert_timelines(
        Map.put(users[:u2], :skip_thread_containment, true),
        Map.values(private) ++ [a, public[:r2]],
        Map.values(public) ++ [a]
      )

      assert_timelines(
        Map.put(users[:u3], :skip_thread_containment, true),
        [private[:r1], private[:r3]],
        Map.values(public) ++ [a]
      )

      assert_timelines(
        Map.put(users[:u4], :skip_thread_containment, true),
        Map.values(public) ++ [a, private[:r2]],
        Map.values(public) ++ [a]
      )
    end

    test "thread_contaiment is on", %{
      users: users,
      a: a,
      private: private,
      public: public
    } do
      assert_timelines(
        users[:u1],
        Map.values(public) ++ Map.values(private) ++ [a],
        Map.values(public) ++ [a]
      )

      assert_timelines(
        users[:u2],
        Map.values(private) ++ [a, public[:r2]],
        Map.values(public) ++ [a]
      )

      assert_timelines(
        users[:u3],
        [private[:r1]],
        Map.values(public) ++ [a]
      )

      assert_timelines(
        users[:u4],
        Map.values(public) ++ [a],
        Map.values(public) ++ [a]
      )
    end
  end

  describe "private root post" do
    setup do
      [u1, u2, u3, u4] = prepare_users()
      a = create_activity(u1, "private")

      private_replies = create_thread(u1, u2, a, "private")
      public_replies = create_thread(u1, u4, a)

      {:ok,
       users: %{u1: u1, u2: u2, u3: u3, u4: u4},
       a: a,
       private: private_replies,
       public: public_replies}
    end

    test "thread_contaiment is off", %{
      users: users,
      a: a,
      private: private,
      public: public
    } do
      assert_timelines(
        Map.put(users[:u1], :skip_thread_containment, true),
        Map.values(public) ++ Map.values(private) ++ [a],
        Map.values(public)
      )

      assert_timelines(
        Map.put(users[:u2], :skip_thread_containment, true),
        Map.values(private) ++ [a, public[:r2]],
        Map.values(public)
      )

      assert_timelines(
        Map.put(users[:u3], :skip_thread_containment, true),
        [private[:r1], private[:r3]],
        Map.values(public)
      )

      assert_timelines(
        Map.put(users[:u4], :skip_thread_containment, true),
        Map.values(public) ++ [a, private[:r2]],
        Map.values(public)
      )
    end

    test "thread_contaiment is on", %{
      users: users,
      a: a,
      private: private,
      public: public
    } do
      assert_timelines(
        users[:u1],
        Map.values(public) ++ Map.values(private) ++ [a],
        Map.values(public)
      )

      assert_timelines(
        users[:u2],
        Map.values(private) ++ [a, public[:r2]],
        Map.values(public)
      )

      assert_timelines(
        users[:u3],
        [],
        Map.values(public)
      )

      assert_timelines(
        users[:u4],
        Map.values(public) ++ [a],
        Map.values(public)
      )
    end
  end

  describe "unlisted root post" do
    setup do
      [u1, u2, u3, u4] = prepare_users()
      a = create_activity(u1, "unlisted")

      private_replies = create_thread(u1, u2, a, "private")
      public_replies = create_thread(u1, u4, a)

      {:ok,
       users: %{u1: u1, u2: u2, u3: u3, u4: u4},
       a: a,
       private: private_replies,
       public: public_replies}
    end

    test "thread_contaiment is off", %{
      users: users,
      a: a,
      private: private,
      public: public
    } do
      assert_timelines(
        Map.put(users[:u1], :skip_thread_containment, true),
        Map.values(public) ++ Map.values(private) ++ [a],
        Map.values(public)
      )

      assert_timelines(
        Map.put(users[:u2], :skip_thread_containment, true),
        Map.values(private) ++ [a, public[:r2]],
        Map.values(public)
      )

      assert_timelines(
        Map.put(users[:u3], :skip_thread_containment, true),
        [private[:r1], private[:r3]],
        Map.values(public)
      )

      assert_timelines(
        Map.put(users[:u4], :skip_thread_containment, true),
        Map.values(public) ++ [a, private[:r2]],
        Map.values(public)
      )
    end

    test "thread_contaiment is on", %{
      users: users,
      a: a,
      private: private,
      public: public
    } do
      assert_timelines(
        users[:u1],
        Map.values(public) ++ Map.values(private) ++ [a],
        Map.values(public)
      )

      assert_timelines(
        users[:u2],
        Map.values(private) ++ [a, public[:r2]],
        Map.values(public)
      )

      assert_timelines(
        users[:u3],
        [private[:r1]],
        Map.values(public)
      )

      assert_timelines(
        users[:u4],
        Map.values(public) ++ [a],
        Map.values(public)
      )
    end
  end

  describe "direct root post" do
    setup do
      [u1, u2, u3, u4] = prepare_users()
      a = create_activity(u1, "direct", u2)

      private_replies = create_thread(u1, u2, a, "direct")

      {:ok, users: %{u1: u1, u2: u2, u3: u3, u4: u4}, a: a, private: private_replies}
    end

    test "thread_contaiment is off", %{
      users: users,
      a: a,
      private: private
    } do
      assert_timelines(
        Map.put(users[:u1], :skip_thread_containment, true),
        Map.values(private) ++ [a],
        [],
        Map.values(private) ++ [a]
      )

      assert_timelines(
        Map.put(users[:u2], :skip_thread_containment, true),
        Map.values(private) ++ [a],
        [],
        Map.values(private) ++ [a]
      )

      assert_timelines(
        Map.put(users[:u3], :skip_thread_containment, true),
        [],
        []
      )

      assert_timelines(
        Map.put(users[:u4], :skip_thread_containment, true),
        [],
        []
      )
    end

    test "thread_contaiment is on", %{
      users: users,
      a: a,
      private: private
    } do
      assert_timelines(
        users[:u1],
        Map.values(private) ++ [a],
        [],
        Map.values(private) ++ [a]
      )

      assert_timelines(
        users[:u2],
        Map.values(private) ++ [a],
        [],
        Map.values(private) ++ [a]
      )

      assert_timelines(
        users[:u3],
        [],
        []
      )

      assert_timelines(
        users[:u4],
        [],
        []
      )
    end
  end

  describe "public root post and unlisted thread" do
    setup do
      [u1, u2, u3, u4] = prepare_users()
      a = create_activity(u1)

      private_replies = create_thread(u1, u2, a, "unlisted")
      public_replies = create_thread(u1, u4, a)

      {:ok,
       users: %{u1: u1, u2: u2, u3: u3, u4: u4},
       a: a,
       private: private_replies,
       public: public_replies}
    end

    test "thread_contaiment is off", %{
      users: users,
      a: a,
      private: private,
      public: public
    } do
      assert_timelines(
        Map.put(users[:u1], :skip_thread_containment, true),
        Map.values(public) ++ Map.values(private) ++ [a],
        Map.values(public) ++ [a]
      )

      assert_timelines(
        Map.put(users[:u2], :skip_thread_containment, true),
        Map.values(private) ++ [a, public[:r2]],
        Map.values(public) ++ [a]
      )

      assert_timelines(
        Map.put(users[:u3], :skip_thread_containment, true),
        [private[:r1], private[:r3]],
        Map.values(public) ++ [a]
      )

      assert_timelines(
        Map.put(users[:u4], :skip_thread_containment, true),
        Map.values(public) ++ [a, private[:r2]],
        Map.values(public) ++ [a]
      )
    end

    test "thread_contaiment is on", %{
      users: users,
      a: a,
      private: private,
      public: public
    } do
      assert_timelines(
        users[:u1],
        Map.values(public) ++ Map.values(private) ++ [a],
        Map.values(public) ++ [a]
      )

      assert_timelines(
        users[:u2],
        Map.values(private) ++ [a, public[:r2]],
        Map.values(public) ++ [a]
      )

      assert_timelines(
        users[:u3],
        [private[:r1], private[:r3]],
        Map.values(public) ++ [a]
      )

      assert_timelines(
        users[:u4],
        Map.values(public) ++ [a, private[:r2]],
        Map.values(public) ++ [a]
      )
    end
  end

  describe "public root post and direct thread" do
    setup do
      [u1, u2, u3, u4] = prepare_users()
      a = create_activity(u1)

      private_replies = create_thread(u1, u2, a, "direct")
      public_replies = create_thread(u1, u4, a)

      {:ok,
       users: %{u1: u1, u2: u2, u3: u3, u4: u4},
       a: a,
       private: private_replies,
       public: public_replies}
    end

    test "thread_contaiment is off", %{
      users: users,
      a: a,
      private: private,
      public: public
    } do
      assert_timelines(
        Map.put(users[:u1], :skip_thread_containment, true),
        Map.values(public) ++ Map.values(private) ++ [a],
        Map.values(public) ++ [a],
        Map.values(private)
      )

      assert_timelines(
        Map.put(users[:u2], :skip_thread_containment, true),
        Map.values(private) ++ [a, public[:r2]],
        Map.values(public) ++ [a],
        Map.values(private)
      )

      assert_timelines(
        Map.put(users[:u3], :skip_thread_containment, true),
        [],
        Map.values(public) ++ [a]
      )

      assert_timelines(
        Map.put(users[:u4], :skip_thread_containment, true),
        Map.values(public) ++ [a],
        Map.values(public) ++ [a]
      )
    end

    test "thread_contaiment is on", %{
      users: users,
      a: a,
      private: private,
      public: public
    } do
      assert_timelines(
        users[:u1],
        Map.values(public) ++ Map.values(private) ++ [a],
        Map.values(public) ++ [a],
        Map.values(private)
      )

      assert_timelines(
        users[:u2],
        Map.values(private) ++ [a, public[:r2]],
        Map.values(public) ++ [a],
        Map.values(private)
      )

      assert_timelines(
        users[:u3],
        [],
        Map.values(public) ++ [a]
      )

      assert_timelines(
        users[:u4],
        Map.values(public) ++ [a],
        Map.values(public) ++ [a]
      )
    end
  end

  defp create_activity(user, visibility \\ "public") do
    {:ok, a} =
      CommonAPI.post(user, %{"status" => "Thread for my followers", "visibility" => visibility})

    a.id
  end

  defp create_activity(user, visibility, mention) do
    {:ok, a} =
      CommonAPI.post(user, %{
        "status" => "Thread for my followers with @#{mention.nickname}",
        "visibility" => visibility
      })

    a.id
  end

  defp create_thread(user1, user2, activity_id, visibility \\ "public") do
    {:ok, r1} =
      CommonAPI.post(user2, %{
        "status" => "@#{user1.nickname} #{user2.nickname} replies to #{user1.nickname}",
        "visibility" => visibility,
        "in_reply_to_status_id" => activity_id
      })

    {:ok, r2} =
      CommonAPI.post(user1, %{
        "status" => "@#{user2.nickname} #{user1.nickname} replies to #{user2.nickname}",
        "visibility" => visibility,
        "in_reply_to_status_id" => r1.id
      })

    {:ok, r3} =
      CommonAPI.post(user2, %{
        "status" => "@#{user1.nickname} #{user2.nickname} replies to #{user1.nickname}",
        "visibility" => visibility,
        "in_reply_to_status_id" => r2.id
      })

    %{r1: r1.id, r2: r2.id, r3: r3.id}
  end

  defp prepare_users do
    [u1, u2, u3, u4] = insert_list(4, :user)

    {:ok, u1} = User.follow(u1, u2)
    {:ok, u2} = User.follow(u2, u1)

    {:ok, u1} = User.follow(u1, u4)
    {:ok, u4} = User.follow(u4, u1)

    {:ok, u2} = User.follow(u2, u3)
    {:ok, u3} = User.follow(u3, u2)
    [u1, u2, u3, u4]
  end

  defp default_opts(user) do
    %{"blocking_user" => user}
  end

  defp public_timeline_opts(user) do
    user
    |> default_opts()
    |> Map.put("type", ["Create", "Announce"])
    |> Map.put("muting_user", user)
  end

  defp home_timeline_opts(user) do
    opts =
      user
      |> public_timeline_opts()
      |> with_user(user)

    {[user.ap_id | User.following(user)], opts}
  end

  defp direct_timeline_opts(user) do
    opts =
      user
      |> default_opts()
      |> Map.put("type", "Create")
      |> with_user(user)
      |> Map.put(:visibility, "direct")

    {[user.ap_id], opts}
  end

  defp with_user(opts, user), do: Map.put(opts, "user", user)

  defp fetch_activities({recipients, opts}) do
    ActivityPub.fetch_activities(recipients, opts) |> Enum.map(& &1.id)
  end

  defp fetch_public_activities(opts) do
    ActivityPub.fetch_public_activities(opts) |> Enum.map(& &1.id)
  end

  defp assert_timelines(
         user,
         home_activities,
         public_activities,
         direct_activities \\ []
       ) do
    home_ids =
      user
      |> home_timeline_opts()
      |> fetch_activities()

    assert length(home_ids) == length(home_activities)

    assert_all(home_activities, home_ids)

    public_ids =
      user
      |> public_timeline_opts()
      |> fetch_public_activities()

    assert length(public_ids) == length(public_activities)

    assert_all(public_activities, public_ids)

    direct_ids =
      user
      |> direct_timeline_opts()
      |> fetch_activities()

    assert length(direct_ids) == length(direct_activities)

    assert_all(direct_activities, direct_ids)
  end

  defp assert_all(values, ids) do
    assert Enum.all?(values, &(&1 in ids))
  end

  describe "get_thread_recipients/2" do
    test "public for public post" do
      user = insert(:user)
      {:ok, post} = CommonAPI.post(user, %{"status" => "Yeah!"})

      assert post.thread_recipients == [Constants.as_public()]
    end

    test "user follower address for private post" do
      user = insert(:user)
      {:ok, post} = CommonAPI.post(user, %{"status" => "Yeah!", "visibility" => "private"})

      assert post.thread_recipients == [
               user.follower_address
             ]
    end

    test "public for public reply to public post" do
      [u1, u2] = insert_list(2, :user)

      {:ok, post} = CommonAPI.post(u1, %{"status" => "Yeah!"})

      {:ok, reply} =
        CommonAPI.post(u2, %{"status" => "Yeah!", "in_reply_to_status_id" => post.id})

      assert post.thread_recipients == [Constants.as_public()]
      assert reply.thread_recipients == [Constants.as_public()]
    end

    test "user follower address for private reply to public post" do
      [u1, u2] = insert_list(2, :user)

      {:ok, post} = CommonAPI.post(u1, %{"status" => "Yeah!"})

      {:ok, reply} =
        CommonAPI.post(u2, %{
          "status" => "Yeah!",
          "in_reply_to_status_id" => post.id,
          "visibility" => "private"
        })

      assert post.thread_recipients == [Constants.as_public()]
      assert reply.thread_recipients == [u2.follower_address]
    end

    test "user follower address for public reply to private post" do
      [u1, u2] = insert_list(2, :user)

      {:ok, post} = CommonAPI.post(u1, %{"status" => "yeah!", "visibility" => "private"})

      {:ok, reply} =
        CommonAPI.post(u2, %{
          "status" => "yeah",
          "in_reply_to_status_id" => post.id,
          "visibility" => "public"
        })

      assert post.thread_recipients == [u1.follower_address]
      assert reply.thread_recipients == [u1.follower_address]
    end

    test "users followers addresses for private reply to private post" do
      [u1, u2] = insert_list(2, :user)

      {:ok, post} = CommonAPI.post(u1, %{"status" => "yeah!", "visibility" => "private"})

      {:ok, reply} =
        CommonAPI.post(u2, %{
          "status" => "yeah",
          "in_reply_to_status_id" => post.id,
          "visibility" => "private"
        })

      assert post.thread_recipients == [u1.follower_address]
      assert reply.thread_recipients == [u1.follower_address, u2.follower_address]
    end

    test "follower addresses for public post and private replies" do
      [u1, u2, u3] = insert_list(3, :user)

      {:ok, post} = CommonAPI.post(u1, %{"status" => "yeah!"})

      {:ok, reply1} =
        CommonAPI.post(u2, %{
          "status" => "yeah",
          "in_reply_to_status_id" => post.id,
          "visibility" => "private"
        })

      {:ok, reply2} =
        CommonAPI.post(u3, %{
          "status" => "yeah",
          "in_reply_to_status_id" => reply1.id,
          "visibility" => "private"
        })

      assert post.thread_recipients == [Constants.as_public()]
      assert reply1.thread_recipients == [u2.follower_address]
      assert reply2.thread_recipients == [u2.follower_address, u3.follower_address]
    end

    test "follower addresses for private post and private replies" do
      [u1, u2, u3] = insert_list(3, :user)

      {:ok, post} = CommonAPI.post(u1, %{"status" => "yeah!", "visibility" => "private"})

      {:ok, reply1} =
        CommonAPI.post(u2, %{
          "status" => "yeah",
          "in_reply_to_status_id" => post.id,
          "visibility" => "private"
        })

      {:ok, reply2} =
        CommonAPI.post(u3, %{
          "status" => "yeah",
          "in_reply_to_status_id" => reply1.id,
          "visibility" => "private"
        })

      assert post.thread_recipients == [u1.follower_address]
      assert reply1.thread_recipients == [u1.follower_address, u2.follower_address]

      assert reply2.thread_recipients == [
               u1.follower_address,
               u2.follower_address,
               u3.follower_address
             ]
    end

    test "public for public reply if thread recipients of root post is nil or empty list" do
      [u1, u2] = insert_list(2, :user)

      {:ok, post} = CommonAPI.post(u1, %{"status" => "Yeah!"})

      {:ok, post} = Repo.update(Ecto.Changeset.change(post, thread_recipients: []))

      {:ok, reply2} =
        CommonAPI.post(u2, %{"status" => "Yeah!", "in_reply_to_status_id" => post.id})

      assert post.thread_recipients == []
      assert reply2.thread_recipients == [Constants.as_public()]
    end

    test "user follower address for private reply if thread recipients of root post is nil or empty list" do
      [u1, u2] = insert_list(2, :user)

      {:ok, post} = CommonAPI.post(u1, %{"status" => "Yeah!"})
      {:ok, post} = Repo.update(Ecto.Changeset.change(post, thread_recipients: []))

      {:ok, reply2} =
        CommonAPI.post(u2, %{
          "status" => "Yeah!",
          "in_reply_to_status_id" => post.id,
          "visibility" => "private"
        })

      assert post.thread_recipients == []
      assert reply2.thread_recipients == [u2.follower_address]
    end
  end

  describe "thread visibility" do
    setup do
      [u1, u2, u3] = insert_list(3, :user)

      {:ok, u1} = User.follow(u1, u2)
      {:ok, u2} = User.follow(u2, u1)

      {:ok, u2} = User.follow(u2, u3)
      {:ok, u3} = User.follow(u3, u2)

      {:ok, u1: u1, u2: u2, u3: u3}
    end

    test "private reply to private post", %{u1: u1, u2: u2, u3: u3} do
      {:ok, activity} = CommonAPI.post(u1, %{"status" => "yeah", "visibility" => "private"})

      {:ok, reply} =
        CommonAPI.post(u2, %{
          "status" => "yeah",
          "visibility" => "public",
          "in_reply_to_status_id" => activity.id
        })

      params =
        %{}
        |> Map.put("type", ["Create", "Announce"])
        |> Map.put("blocking_user", u3)
        |> Map.put("muting_user", u3)
        |> Map.put("user", u3)

      recipients = [u3.ap_id | User.following(u3)]

      assert ActivityPub.fetch_activities(
               recipients,
               params
             ) == []

      assert ActivityPub.fetch_public_activities(params) == []

      u3 = Map.put(u3, :skip_thread_containment, true)

      params =
        params
        |> Map.put("blocking_user", u3)
        |> Map.put("muting_user", u3)
        |> Map.put("user", u3)

      [result] =
        ActivityPub.fetch_activities(
          recipients,
          params
        )

      assert reply.id == result.id

      [result] = ActivityPub.fetch_public_activities(params)
      assert reply.id == result.id
    end

    test "private reply to public post", %{u1: u1, u2: u2, u3: u3} do
      {:ok, activity} = CommonAPI.post(u2, %{"status" => "yeah"})

      {:ok, private_reply} =
        CommonAPI.post(u1, %{
          "status" => "yeah",
          "visibility" => "private",
          "in_reply_to_status_id" => activity.id
        })

      {:ok, public_reply} =
        CommonAPI.post(u2, %{
          "status" => "yeah",
          "visibility" => "public",
          "in_reply_to_status_id" => private_reply.id
        })

      params =
        %{}
        |> Map.put("type", ["Create", "Announce"])
        |> Map.put("blocking_user", u3)
        |> Map.put("muting_user", u3)
        |> Map.put("user", u3)

      recipients = [u3.ap_id | User.following(u3)]

      [result] =
        ActivityPub.fetch_activities(
          recipients,
          params
        )

      assert result.id == activity.id

      [result] = ActivityPub.fetch_public_activities(params)
      assert result.id == activity.id

      u3 = Map.put(u3, :skip_thread_containment, true)

      params =
        params
        |> Map.put("blocking_user", u3)
        |> Map.put("muting_user", u3)
        |> Map.put("user", u3)

      result =
        ActivityPub.fetch_activities(
          recipients,
          params
        )
        |> Enum.map(& &1.id)

      assert activity.id in result
      assert public_reply.id in result

      result = ActivityPub.fetch_public_activities(params) |> Enum.map(& &1.id)
      assert activity.id in result
      assert public_reply.id in result
    end
  end
end
