defmodule Pleroma.LoadTesting.Generator do
  use Pleroma.LoadTesting.Helper
  alias Pleroma.Web.CommonAPI

  def generate_like_activities(user, posts) do
    count_likes = Kernel.trunc(length(posts) / 4)
    IO.puts("Starting generating #{count_likes} like activities...")

    {time, _} =
      :timer.tc(fn ->
        Task.async_stream(
          Enum.take_random(posts, count_likes),
          fn post -> {:ok, _, _} = CommonAPI.favorite(post.id, user) end,
          max_concurrency: 20,
          timeout: 30_000
        )
        |> Stream.run()
      end)

    IO.puts("Inserting like activities take #{to_sec(time)} sec.\n")
  end

  def generate_users(opts) do
    IO.puts("Starting generating #{opts[:users_max]} users...")
    {time, _} = :timer.tc(fn -> do_generate_users(opts) end)

    IO.puts("Inserting users take #{to_sec(time)} sec.\n")
  end

  defp do_generate_users(opts) do
    max = Keyword.get(opts, :users_max)

    Task.async_stream(
      1..max,
      &generate_user_data(&1),
      max_concurrency: 20,
      timeout: 30_000
    )
    |> Enum.to_list()
  end

  defp generate_user_data(i) do
    remote = Enum.random([true, false])

    user = %User{
      name: "Test テスト User #{i}",
      email: "user#{i}@example.com",
      nickname: "nick#{i}",
      password_hash:
        "$pbkdf2-sha512$160000$bU.OSFI7H/yqWb5DPEqyjw$uKp/2rmXw12QqnRRTqTtuk2DTwZfF8VR4MYW2xMeIlqPR/UX1nT1CEKVUx2CowFMZ5JON8aDvURrZpJjSgqXrg",
      bio: "Tester Number #{i}",
      local: remote
    }

    user_urls =
      if remote do
        base_url =
          Enum.random(["https://domain1.com", "https://domain2.com", "https://domain3.com"])

        ap_id = "#{base_url}/users/#{user.nickname}"

        %{
          ap_id: ap_id,
          follower_address: ap_id <> "/followers",
          following_address: ap_id <> "/following"
        }
      else
        %{
          ap_id: User.ap_id(user),
          follower_address: User.ap_followers(user),
          following_address: User.ap_following(user)
        }
      end

    user = Map.merge(user, user_urls)

    Repo.insert!(user)
  end

  def generate_activities(user, users) do
    do_generate_activities(user, users)
  end

  defp do_generate_activities(user, users) do
    IO.puts("Starting generating 20000 common activities...")

    {time, _} =
      :timer.tc(fn ->
        Task.async_stream(
          1..20_000,
          fn _ ->
            do_generate_activity([user | users])
          end,
          max_concurrency: 20,
          timeout: 30_000
        )
        |> Stream.run()
      end)

    IO.puts("Inserting common activities take #{to_sec(time)} sec.\n")

    IO.puts("Starting generating 20000 activities with mentions...")

    nicknames = Enum.map(users, &["@", &1.nickname])

    {time, _} =
      :timer.tc(fn ->
        Task.async_stream(
          1..20_000,
          fn _ ->
            do_generate_activity_with_mention(Enum.random(users), user.nickname, nicknames)
          end,
          max_concurrency: 20,
          timeout: 30_000
        )
        |> Stream.run()
      end)

    IO.puts("Inserting activities with menthions take #{to_sec(time)} sec.\n")

    IO.puts("Starting generating 10000 activities with threads...")

    {time, _} =
      :timer.tc(fn ->
        Task.async_stream(
          1..10_000,
          fn _ ->
            do_generate_threads([user | users])
          end,
          max_concurrency: 20,
          timeout: 30_000
        )
        |> Stream.run()
      end)

    IO.puts("Inserting activities with threads take #{to_sec(time)} sec.\n")
  end

  defp do_generate_activity(users) do
    post = %{
      "status" => "Some status without mention with random user"
    }

    CommonAPI.post(Enum.random(users), post)
  end

  defp do_generate_activity_with_mention(author, nickname, nicknames) do
    mentions =
      nicknames
      |> Enum.shuffle()
      |> Enum.take(Enum.random([2, 3, 4, 5]))

    mentions =
      if Enum.random([true, false]) do
        [nickname | mentions]
      else
        mentions
      end

    post = %{
      "status" => ["some status with mentions random users" | mentions] |> Enum.join(" ")
    }

    CommonAPI.post(author, post)
  end

  defp do_generate_threads(users) do
    thread_length = Enum.random([2, 3, 4, 5])
    actor = Enum.random(users)

    post = %{
      "status" => "Start of the thread"
    }

    {:ok, activity} = CommonAPI.post(actor, post)

    Enum.each(1..thread_length, fn _ ->
      user = Enum.random(users)

      post = %{
        "status" => "@#{actor.nickname} reply to thread",
        "in_reply_to_status_id" => activity
      }

      CommonAPI.post(user, post)
    end)
  end

  def generate_remote_activities(user, users) do
    do_generate_remote_activities(user, users)
  end

  defp do_generate_remote_activities(user, users) do
    IO.puts("Starting generating 10000 remote activities...")

    {time, _} =
      :timer.tc(fn ->
        Task.async_stream(
          1..10_000,
          fn i ->
            do_generate_remote_activity(i, user, users)
          end,
          max_concurrency: 20,
          timeout: 30_000
        )
        |> Stream.run()
      end)

    IO.puts("Inserting remote activities take #{to_sec(time)} sec.\n")
  end

  defp do_generate_remote_activity(i, user, users) do
    actor = Enum.random(users)
    %{host: host} = URI.parse(actor.ap_id)
    date = Date.utc_today()
    datetime = DateTime.utc_now()

    map = %{
      "actor" => actor.ap_id,
      "cc" => [actor.follower_address, user.ap_id],
      "context" => "tag:mastodon.example.org,#{date}:objectId=#{i}:objectType=Conversation",
      "id" => actor.ap_id <> "/statuses/#{i}/activity",
      "object" => %{
        "actor" => actor.ap_id,
        "atomUri" => actor.ap_id <> "/statuses/#{i}",
        "attachment" => [],
        "attributedTo" => actor.ap_id,
        "bcc" => [],
        "bto" => [],
        "cc" => [actor.follower_address, user.ap_id],
        "content" =>
          "<p><span class=\"h-card\"><a href=\"" <>
            user.ap_id <>
            "\" class=\"u-url mention\">@<span>" <> user.nickname <> "</span></a></span></p>",
        "context" => "tag:mastodon.example.org,#{date}:objectId=#{i}:objectType=Conversation",
        "conversation" =>
          "tag:mastodon.example.org,#{date}:objectId=#{i}:objectType=Conversation",
        "emoji" => %{},
        "id" => actor.ap_id <> "/statuses/#{i}",
        "inReplyTo" => nil,
        "inReplyToAtomUri" => nil,
        "published" => datetime,
        "sensitive" => true,
        "summary" => "cw",
        "tag" => [
          %{
            "href" => user.ap_id,
            "name" => "@#{user.nickname}@#{host}",
            "type" => "Mention"
          }
        ],
        "to" => ["https://www.w3.org/ns/activitystreams#Public"],
        "type" => "Note",
        "url" => "http://#{host}/@#{actor.nickname}/#{i}"
      },
      "published" => datetime,
      "to" => ["https://www.w3.org/ns/activitystreams#Public"],
      "type" => "Create"
    }

    Pleroma.Web.ActivityPub.ActivityPub.insert(map, false)
  end

  def generate_dms(user, users, opts) do
    IO.puts("Starting generating #{opts[:dms_max]} DMs")
    {time, _} = :timer.tc(fn -> do_generate_dms(user, users, opts) end)
    IO.puts("Inserting dms take #{to_sec(time)} sec.\n")
  end

  defp do_generate_dms(user, users, opts) do
    Task.async_stream(
      1..opts[:dms_max],
      fn _ ->
        do_generate_dm(user, users)
      end,
      max_concurrency: 20,
      timeout: 30_000
    )
    |> Stream.run()
  end

  defp do_generate_dm(user, users) do
    post = %{
      "status" => "@#{user.nickname} some direct message",
      "visibility" => "direct"
    }

    CommonAPI.post(Enum.random(users), post)
  end

  def generate_long_thread(user, users, opts) do
    IO.puts("Starting generating long thread with #{opts[:thread_length]} replies")
    {time, activity} = :timer.tc(fn -> do_generate_long_thread(user, users, opts) end)
    IO.puts("Inserting long thread replies take #{to_sec(time)} sec.\n")
    {:ok, activity}
  end

  defp do_generate_long_thread(user, users, opts) do
    {:ok, activity} = CommonAPI.post(user, %{"status" => "Start of long thread"})

    Task.async_stream(
      1..opts[:thread_length],
      fn _ -> do_generate_thread(users, activity) end,
      max_concurrency: 20,
      timeout: 30_000
    )
    |> Stream.run()

    activity
  end

  defp do_generate_thread(users, activity) do
    CommonAPI.post(Enum.random(users), %{
      "status" => "reply to main post",
      "in_reply_to_status_id" => activity
    })
  end

  def generate_non_visible_message(user, users) do
    IO.puts("Starting generating 1000 non visible posts")

    {time, _} =
      :timer.tc(fn ->
        do_generate_non_visible_posts(user, users)
      end)

    IO.puts("Inserting non visible posts take #{to_sec(time)} sec.\n")
  end

  defp do_generate_non_visible_posts(user, users) do
    [not_friend | users] = users

    make_friends(user, users)

    Task.async_stream(1..1000, fn _ -> do_generate_non_visible_post(not_friend, users) end,
      max_concurrency: 20,
      timeout: 30_000
    )
    |> Stream.run()
  end

  defp make_friends(_user, []), do: nil

  defp make_friends(user, [friend | users]) do
    {:ok, _} = User.follow(user, friend)
    {:ok, _} = User.follow(friend, user)
    make_friends(user, users)
  end

  defp do_generate_non_visible_post(not_friend, users) do
    post = %{
      "status" => "some non visible post",
      "visibility" => "private"
    }

    {:ok, activity} = CommonAPI.post(not_friend, post)

    thread_length = Enum.random([2, 3, 4, 5])

    Enum.each(1..thread_length, fn _ ->
      user = Enum.random(users)

      post = %{
        "status" => "@#{not_friend.nickname} reply to non visible post",
        "in_reply_to_status_id" => activity,
        "visibility" => "private"
      }

      CommonAPI.post(user, post)
    end)
  end

  def generate_replies(user, followers) do
    IO.puts("Starting generating thread with 150 replies")
    {time, _} = :timer.tc(fn -> do_generate_replies(user, followers) end)
    IO.puts("Inserting thread with 150 replies take #{to_sec(time)} sec.\n")
  end

  defp do_generate_replies(user, [f1, f2, f3]) do
    {:ok, user} = User.follow(user, f1)
    {:ok, f1} = User.follow(f1, user)
    {:ok, user} = User.follow(user, f3)
    {:ok, f3} = User.follow(f3, user)

    {:ok, f1} = User.follow(f1, f2)
    {:ok, f2} = User.follow(f2, f1)

    {:ok, activity} = CommonAPI.post(user, %{"status" => "Status"})

    Stream.iterate(activity, fn id ->
      {:ok, r1} =
        CommonAPI.post(f1, %{
          "status" => "@#{user.nickname} reply from #{f1.nickname} to #{user.nickname}",
          "in_reply_to_status_id" => id
        })

      {:ok, r2} =
        CommonAPI.post(f2, %{
          "status" => "@#{f1.nickname} reply from #{f2.nickname} to #{f1.nickname}",
          "in_reply_to_status_id" => r1
        })

      {:ok, r3} =
        CommonAPI.post(f3, %{
          "status" => "@#{f2.nickname} reply from #{f3.nickname} to #{f2.nickname}",
          "in_reply_to_status_id" => r2
        })

      {:ok, r4} =
        CommonAPI.post(f1, %{
          "status" => "@#{f3.nickname} reply from #{f1.nickname} to #{f3.nickname}",
          "in_reply_to_status_id" => r3
        })

      {:ok, r5} =
        CommonAPI.post(f2, %{
          "status" => "@#{f3.nickname} reply from #{f2.nickname} to #{f3.nickname}",
          "in_reply_to_status_id" => r4
        })

      {:ok, r6} =
        CommonAPI.post(f3, %{
          "status" => "@#{user.nickname} reply from #{f3.nickname} to #{user.nickname}",
          "in_reply_to_status_id" => r5
        })

      r6
    end)
    |> Enum.take(25)
  end
end
