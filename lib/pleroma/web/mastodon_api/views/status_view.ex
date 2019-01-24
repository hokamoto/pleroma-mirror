# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.MastodonAPI.StatusView do
  use Pleroma.Web, :view

  alias Pleroma.Activity
  alias Pleroma.HTML
  alias Pleroma.Repo
  alias Pleroma.User
  alias Pleroma.Web.CommonAPI.Utils
  alias Pleroma.Web.MediaProxy
  alias Pleroma.Web.MastodonAPI.AccountView
  alias Pleroma.Web.MastodonAPI.StatusView

  # TODO: Add cached version.
  defp get_replied_to_activities(activities) do
    activities
    |> Enum.map(fn
      %{data: %{"type" => "Create", "object" => %{"inReplyTo" => in_reply_to}}} ->
        in_reply_to != "" && in_reply_to

      _ ->
        nil
    end)
    |> Enum.filter(& &1)
    |> Activity.create_by_object_ap_id()
    |> Repo.all()
    |> Enum.reduce(%{}, fn activity, acc ->
      Map.put(acc, activity.data["object"]["id"], activity)
    end)
  end

  defp get_user(ap_id) do
    cond do
      user = User.get_cached_by_ap_id(ap_id) ->
        user

      user = User.get_by_guessed_nickname(ap_id) ->
        user

      true ->
        User.error_user(ap_id)
    end
  end

  def render("index.json", opts) do
    replied_to_activities = get_replied_to_activities(opts.activities)

    opts.activities
    |> render_many(
      StatusView,
      "status.json",
      Map.put(opts, :replied_to_activities, replied_to_activities)
    )
    |> Enum.filter(fn x -> not is_nil(x) end)
  end

  def render(
        "status.json",
        %{activity: %{data: %{"type" => "Announce", "object" => object}} = activity} = opts
      ) do
    user = get_user(activity.data["actor"])
    created_at = Utils.to_masto_date(activity.data["published"])

    reblogged = Activity.get_create_by_object_ap_id(object)
    reblogged = render("status.json", Map.put(opts, :activity, reblogged))

    mentions =
      activity.recipients
      |> Enum.map(fn ap_id -> User.get_cached_by_ap_id(ap_id) end)
      |> Enum.filter(& &1)
      |> Enum.map(fn user -> AccountView.render("mention.json", %{user: user}) end)

    %{
      id: to_string(activity.id),
      uri: object,
      url: object,
      account: AccountView.render("account.json", %{user: user}),
      in_reply_to_id: nil,
      in_reply_to_account_id: nil,
      reblog: reblogged,
      content: reblogged[:content] || "",
      created_at: created_at,
      reblogs_count: 0,
      replies_count: 0,
      favourites_count: 0,
      reblogged: false,
      favourited: false,
      muted: false,
      pinned: pinned?(activity, user),
      sensitive: false,
      spoiler_text: "",
      visibility: "public",
      media_attachments: reblogged[:media_attachments] || [],
      mentions: mentions,
      tags: reblogged[:tags] || [],
      application: %{
        name: "Web",
        website: nil
      },
      language: nil,
      emojis: []
    }
  end

  def render("status.json", %{activity: %{data: %{"object" => object}} = activity} = opts) do
    user = get_user(activity.data["actor"])

    like_count = object["like_count"] || 0
    announcement_count = object["announcement_count"] || 0

    tags = object["tag"] || []
    sensitive = object["sensitive"] || Enum.member?(tags, "nsfw")

    mentions =
      activity.recipients
      |> Enum.map(fn ap_id -> User.get_cached_by_ap_id(ap_id) end)
      |> Enum.filter(& &1)
      |> Enum.map(fn user -> AccountView.render("mention.json", %{user: user}) end)

    repeated = opts[:for] && opts[:for].ap_id in (object["announcements"] || [])
    favorited = opts[:for] && opts[:for].ap_id in (object["likes"] || [])

    attachment_data = object["attachment"] || []
    attachments = render_many(attachment_data, StatusView, "attachment.json", as: :attachment)

    created_at = Utils.to_masto_date(object["published"])

    reply_to = get_reply_to(activity, opts)
    reply_to_user = reply_to && get_user(reply_to.data["actor"])

    content =
      object
      |> render_content()
      |> HTML.get_cached_scrubbed_html_for_object(
        User.html_filter_policy(opts[:for]),
        activity,
        __MODULE__
      )

    %{
      id: to_string(activity.id),
      uri: object["id"],
      url: object["external_url"] || object["id"],
      account: AccountView.render("account.json", %{user: user}),
      in_reply_to_id: reply_to && to_string(reply_to.id),
      in_reply_to_account_id: reply_to_user && to_string(reply_to_user.id),
      reblog: nil,
      content: content,
      created_at: created_at,
      reblogs_count: announcement_count,
      replies_count: 0,
      favourites_count: like_count,
      reblogged: present?(repeated),
      favourited: present?(favorited),
      muted: false,
      pinned: pinned?(activity, user),
      sensitive: sensitive,
      spoiler_text: object["summary"] || "",
      visibility: get_visibility(object),
      media_attachments: attachments |> Enum.take(4),
      mentions: mentions,
      tags: build_tags(tags),
      application: %{
        name: "Web",
        website: nil
      },
      language: nil,
      emojis: build_emojis(activity.data["object"]["emoji"])
    }
  end

  def render("status.json", _) do
    nil
  end

  def render("attachment.json", %{attachment: attachment}) do
    [attachment_url | _] = attachment["url"]
    media_type = attachment_url["mediaType"] || attachment_url["mimeType"] || "image"
    href = attachment_url["href"] |> MediaProxy.url()

    type =
      cond do
        String.contains?(media_type, "image") -> "image"
        String.contains?(media_type, "video") -> "video"
        String.contains?(media_type, "audio") -> "audio"
        true -> "unknown"
      end

    <<hash_id::signed-32, _rest::binary>> = :crypto.hash(:md5, href)

    %{
      id: to_string(attachment["id"] || hash_id),
      url: href,
      remote_url: href,
      preview_url: href,
      text_url: href,
      type: type,
      description: attachment["name"]
    }
  end

  def get_reply_to(activity, %{replied_to_activities: replied_to_activities}) do
    _id = activity.data["object"]["inReplyTo"]
    replied_to_activities[activity.data["object"]["inReplyTo"]]
  end

  def get_reply_to(%{data: %{"object" => object}}, _) do
    if object["inReplyTo"] && object["inReplyTo"] != "" do
      Activity.get_create_by_object_ap_id(object["inReplyTo"])
    else
      nil
    end
  end

  def get_visibility(object) do
    public = "https://www.w3.org/ns/activitystreams#Public"
    to = object["to"] || []
    cc = object["cc"] || []

    cond do
      public in to ->
        "public"

      public in cc ->
        "unlisted"

      # this should use the sql for the object's activity
      Enum.any?(to, &String.contains?(&1, "/followers")) ->
        "private"

      length(cc) > 0 ->
        "private"

      true ->
        "direct"
    end
  end

  def render_content(%{"type" => "Video"} = object) do
    with name when not is_nil(name) and name != "" <- object["name"] do
      "<p><a href=\"#{object["id"]}\">#{name}</a></p>#{object["content"]}"
    else
      _ -> object["content"] || ""
    end
  end

  def render_content(%{"type" => object_type} = object)
      when object_type in ["Article", "Page"] do
    with summary when not is_nil(summary) and summary != "" <- object["name"],
         url when is_bitstring(url) <- object["url"] do
      "<p><a href=\"#{url}\">#{summary}</a></p>#{object["content"]}"
    else
      _ -> object["content"] || ""
    end
  end

  def render_content(object), do: object["content"] || ""

  @doc """
  Builds a dictionary tags.

  ## Examples

  iex> Pleroma.Web.MastodonAPI.StatusView.build_tags(["fediverse", "nextcloud"])
  [{"name": "fediverse", "url": "/tag/fediverse"},
   {"name": "nextcloud", "url": "/tag/nextcloud"}]

  """
  @spec build_tags(list(any())) :: list(map())
  def build_tags(object_tags) when is_list(object_tags) do
    object_tags = for tag when is_binary(tag) <- object_tags, do: tag

    Enum.reduce(object_tags, [], fn tag, tags ->
      tags ++ [%{name: tag, url: "/tag/#{tag}"}]
    end)
  end

  def build_tags(_), do: []

  @doc """
  Builds list emojis.

  Arguments: `nil` or list tuple of name and url.

  Returns list emojis.

  ## Examples

  iex> Pleroma.Web.MastodonAPI.StatusView.build_emojis([{"2hu", "corndog.png"}])
  [%{shortcode: "2hu", static_url: "corndog.png", url: "corndog.png", visible_in_picker: false}]

  """
  @spec build_emojis(nil | list(tuple())) :: list(map())
  def build_emojis(nil), do: []

  def build_emojis(emojis) do
    emojis
    |> Enum.map(fn {name, url} ->
      name = HTML.strip_tags(name)

      url =
        url
        |> HTML.strip_tags()
        |> MediaProxy.url()

      %{shortcode: name, url: url, static_url: url, visible_in_picker: false}
    end)
  end

  defp present?(nil), do: false
  defp present?(false), do: false
  defp present?(_), do: true

  defp pinned?(%Activity{id: id}, %User{info: %{pinned_activities: pinned_activities}}),
    do: id in pinned_activities
end
