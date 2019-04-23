# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.MastodonAPI.QuestionView do
  use Pleroma.Web, :view

  alias Pleroma.Question
  alias Pleroma.User

  def render("show.json", %{object: nil}), do: %{}

  def render(
        "show.json",
        %{
          object: %Pleroma.Object{
            id: id,
            data:
              %{
                "replies" => %{
                  "items" => replies,
                  "totalItems" => total_votes
                },
                "endTime" => expires_in
              } = data
          },
          user: %User{} = user
        }
      ) do
    do_render("show.json", %{
      id: id,
      expires_in: expires_in,
      multiple: Map.has_key?(data, "anyOf"),
      poll_options: Question.options_to_array(data["anyOf"] || data["oneOf"]),
      replies: replies,
      total_votes: total_votes,
      user_id: user.ap_id,
      published: data["published"]
    })
  end

  def render("show.json", _), do: %{}

  defp do_render("show.json", opts) do
    %{
      id: opts[:id],
      expired: poll_expired(opts[:expires_in]),
      multiple: opts[:multiple],
      voted: Enum.any?(opts[:replies], &(&1["attributedTo"] == opts[:user_id])),
      votes_count: opts[:total_votes],
      options: build_options(opts[:replies], opts[:poll_options]),
      emojis: []
    }
  end

  defp build_options(all_votes, options) do
    options
    |> Enum.map(fn option ->
      %{
        title: option,
        votes_count: count_votes(all_votes, option)
      }
    end)
  end

  defp count_votes(items, option) do
    Enum.reduce(items, 0, fn item, acc -> if item["name"] == option, do: acc + 1, else: acc end)
  end

  defp poll_expired(expires_in) when is_binary(expires_in) do
    {:ok, date, _offset} = DateTime.from_iso8601(expires_in)

    poll_expired(date)
  end

  defp poll_expired(expires_in) do
    DateTime.compare(expires_in, DateTime.utc_now()) == :lt
  end
end
