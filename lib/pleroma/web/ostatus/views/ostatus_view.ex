defmodule Pleroma.Web.OStatus.AppWithOpenGraphView do
  use Pleroma.Web, :view
  alias Pleroma.User
  alias Pleroma.Web.LayoutView
  alias Phoenix.HTML

  # Adds crawler metadata to /notice/id URLs.
  #
  # This code should only run when a user requests a /notice/id page
  # in a new tab, as opposed to navigating with the JS app.  (Or when
  # a crawler, such as another website's embed checker, requests the
  # page.)

  def render("index.html", data) do
    with {:safe, content} <-
           Phoenix.View.render(LayoutView, "static_with_head.html", %{
             head_content: render("head.html", data)
           }) do
      content
    end
  end

  def render("head.html", args) do
    activity = args.activity
    user = args.user

    elems =
      Enum.concat([
        get_links(activity.data),
        get_og_meta(activity, user)
      ])

    Enum.map(elems, &make_tag/1)
  end

  defp get_links(%{"id" => uri}) do
    [
      {:link, [type: ['application/atom+xml'], href: uri, rel: 'alternate'], []},
      {:link, [type: ['application/activity+json'], href: uri, rel: 'alternate'], []}
    ]
  end

  defp get_og_meta(activity, user) do
    [
      {:meta,
       [
         property: "og:title",
         content: "#{user.name} (@#{user.nickname}@DOMAIN_HERE) post ##{activity.id}"
       ], []},
      {:meta, [property: "og:url", content: activity.data["id"]], []},
      {:meta, [property: "og:description", content: excerpt(activity.data["object"]["content"])],
       []},
      {:meta, [property: "og:image", content: User.avatar_url(user)], []},
      {:meta, [property: "og:image:width", content: 120], []},
      {:meta, [property: "og:image:height", content: 120], []},
      # heh, twitter. (other websites do use this property!)
      {:meta, [property: "twitter:card", content: "summary"], []}
    ]
  end

  defp excerpt(text) do
    # TODO configurable?
    max_length = 200

    cond do
      not String.valid?(text) ->
        text

      String.length(text) < max_length ->
        text

      true ->
        "#{String.slice(text, 0, max_length - 1)}…"
    end
  end

  defp make_tag(data) do
    with {name, attrs, _content = []} <- data do
      HTML.Tag.tag(name, attrs)
    else
      {name, attrs, content} ->
        HTML.Tag.content_tag(name, content, attrs)

      _ ->
        raise ArgumentError, message: "make_tag invalid args"
    end
  end
end
