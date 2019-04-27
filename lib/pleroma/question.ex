# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Question do
  use Ecto.Schema

  alias Pleroma.Config
  alias Pleroma.Object
  alias Pleroma.Repo

  import Ecto.Query

  def add_reply_by_id(id, choices, actor) do
    with {:ok, _object} <- add_reply(id, choices, actor),
         {:ok, object} <- increment_total(id, choices) do
      {:ok, object}
    end
  end

  def maybe_check_limits(false, _expires, _options), do: :ok

  def maybe_check_limits(true, expires, options) when is_binary(expires) do
    maybe_check_limits(true, String.to_integer(expires), options)
  end

  def maybe_check_limits(true, expires, options) when is_integer(expires) do
    limits = Config.get([:instance, :poll_limits])
    expiration_range = limits[:min_expiration]..limits[:max_expiration]

    cond do
      length(options) > limits[:max_options] ->
        {:error, "The number of options exceed the maximum of #{limits[:max_options]}"}

      Enum.any?(options, &(String.length(&1) > limits[:max_option_chars])) ->
        {:error,
         "The number of option's characters exceed the maximum of #{limits[:max_option_chars]}"}

      !Enum.member?(expiration_range, expires) ->
        {:error,
         "`expires_in` must be in range of (#{limits[:min_expiration]}..#{limits[:max_expiration]}) seconds"}

      true ->
        :ok
    end
  end

  def options_to_array(options) do
    options |> Enum.map(& &1["name"])
  end

  defp add_reply(id, choices, actor) when is_binary(id) or is_integer(id) do
    with question <- Object.get_by_id(id),
         true <- maybe_ensure_multipe(question, choices),
         true <- valid_choice_indices(question, choices),
         false <- actor_already_voted(question, actor) do
      add_reply(question, choices, actor)
    else
      _ ->
        {:noop, id}
    end
  end

  defp add_reply(question, choices, actor) when is_list(choices) do
    choices
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(fn choice ->
      add_reply(question, choice_name_by_index(question, choice), actor)
    end)

    {:ok, question}
  end

  defp add_reply(%{id: id}, name, actor) when is_binary(name) do
    from(o in Object, where: o.id == ^to_string(id))
    |> update([o],
      set: [
        data:
          fragment(
            "jsonb_set(?, '{replies,items}', (?->'replies'->'items') || ?, true)",
            o.data,
            o.data,
            ^%{"type" => "Note", "name" => name, "attributedTo" => actor}
          )
      ]
    )
    |> select([u], u)
    |> Repo.update_all([])
    |> case do
      {1, [object]} -> {:ok, object}
      _ -> :error
    end
  end

  defp increment_total(id, choices) do
    count = length(choices)

    from(o in Object, where: o.id == ^to_string(id))
    |> update([o],
      set: [
        data:
          fragment(
            "jsonb_set(?, '{replies,totalItems}', ((?->'replies'->>'totalItems')::int + ?)::varchar::jsonb, true)",
            o.data,
            o.data,
            ^count
          )
      ]
    )
    |> select([u], u)
    |> Repo.update_all([])
    |> case do
      {1, [object]} -> {:ok, object}
      _ -> :error
    end
  end

  def choice_name_by_index(question, index) when is_binary(index) do
    choice_name_by_index(question, String.to_integer(index))
  end

  def choice_name_by_index(question, index) do
    (question.data["anyOf"] || question.data["oneOf"])
    |> options_to_array()
    |> Enum.at(index)
  end

  defp maybe_ensure_multipe(_question, choices) when length(choices) == 1, do: true
  defp maybe_ensure_multipe(%{data: %{"oneOf" => _one_of}}, _choices), do: false
  defp maybe_ensure_multipe(%{data: %{"anyOf" => _any_of}}, _choices), do: true

  defp actor_already_voted(%{data: %{"replies" => %{"items" => []}}}, _actor),
    do: false

  defp actor_already_voted(%{data: %{"replies" => %{"items" => replies}}}, actor) do
    Enum.any?(replies, &(&1["attributedTo"] == actor))
  end

  defp valid_choice_indices(%{data: %{"anyOf" => options}}, choices) do
    valid_choice_indices(options, choices)
  end

  defp valid_choice_indices(%{data: %{"oneOf" => options}}, choices) do
    valid_choice_indices(options, choices)
  end

  defp valid_choice_indices(options, choices) do
    choices
    |> Enum.map(&String.to_integer/1)
    |> Enum.all?(&(length(options) > &1))
  end

  def is_question(object) when is_nil(object), do: false
  def is_question(%{data: %{"type" => type}}), do: type == "Question"
end
