# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.ActivityPub.MRF.KeywordPolicy do
  @behaviour Pleroma.Web.ActivityPub.MRF

  alias Pleroma.Web.ActivityPub.MRF
  import Ecto.Query
  alias __MODULE__
  import Pleroma.Config, only: [update_from_storage: 3]

  @type t :: %__MODULE__{}

  defstruct federated_timeline_removal: [],
            reject: [],
            replace: %{}

  def config_update() do
    query = from(kp in MRF, limit: 1, order_by: [desc: :updated_at])
    callback = &(&1 |> hd |> serialise_config())
    update_from_storage(:mrf_keyword, where(query, policy: "KeywordPolicy"), callback)
  end

  def save_keyword_policy(%KeywordPolicy{} = keyword_policy) do
    keyword_policy |> deserialise_config |> MRF.save_policy()
  end

  defp string_matches?(string, pattern) when is_binary(pattern) do
    String.contains?(string, pattern)
  end

  defp string_matches?(string, pattern) do
    String.match?(string, pattern)
  end

  defp check_reject(%{"object" => %{"content" => content, "summary" => summary}} = message) do
    if Enum.any?(Pleroma.Config.get([:mrf_keyword, :reject]), fn pattern ->
         string_matches?(content, pattern) or string_matches?(summary, pattern)
       end) do
      {:reject, nil}
    else
      {:ok, message}
    end
  end

  defp check_ftl_removal(
         %{"to" => to, "object" => %{"content" => content, "summary" => summary}} = message
       ) do
    if "https://www.w3.org/ns/activitystreams#Public" in to and
         Enum.any?(Pleroma.Config.get([:mrf_keyword, :federated_timeline_removal]), fn pattern ->
           string_matches?(content, pattern) or string_matches?(summary, pattern)
         end) do
      to = List.delete(to, "https://www.w3.org/ns/activitystreams#Public")
      cc = ["https://www.w3.org/ns/activitystreams#Public" | message["cc"] || []]

      message =
        message
        |> Map.put("to", to)
        |> Map.put("cc", cc)

      {:ok, message}
    else
      {:ok, message}
    end
  end

  defp check_replace(%{"object" => %{"content" => content, "summary" => summary}} = message) do
    {content, summary} =
      Enum.reduce(Pleroma.Config.get([:mrf_keyword, :replace]), {content, summary}, fn {pattern,
                                                                                        replacement},
                                                                                       {content_acc,
                                                                                        summary_acc} ->
        {String.replace(content_acc, pattern, replacement),
         String.replace(summary_acc, pattern, replacement)}
      end)

    {:ok,
     message
     |> put_in(["object", "content"], content)
     |> put_in(["object", "summary"], summary)}
  end

  @impl true
  def serialise_config(%MRF{} = mrf) do
    %{
      federated_timeline_removal: mrf.data["federated_timeline_removal"],
      reject: mrf.data["reject"],
      replace: mrf.data["replace"]
    }
  end

  @impl true
  def deserialise_config(%__MODULE__{} = kp) do
    %{data: Map.from_struct(kp), policy: "KeywordPolicy"}
  end

  def deserialize_config(_, _), do: :ok

  @impl true
  def filter(%{"object" => %{"content" => nil}} = message) do
    {:ok, message}
  end

  @impl true
  def filter(%{"type" => "Create", "object" => %{"content" => _content}} = message) do
    with {:ok, message} <- check_reject(message),
         {:ok, message} <- check_ftl_removal(message),
         {:ok, message} <- check_replace(message) do
      {:ok, message}
    else
      _e ->
        {:reject, nil}
    end
  end

  @impl true
  def filter(message), do: {:ok, message}
end
