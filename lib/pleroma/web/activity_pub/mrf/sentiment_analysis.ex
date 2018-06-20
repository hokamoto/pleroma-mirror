defmodule Pleroma.Web.ActivityPub.MRF.SentimentAnalysis do
  require Logger
  @behaviour Pleroma.Web.ActivityPub.MRF

  @rate_post Keyword.get(@mrf_policy, :sentiment_analysis_posts)
  defp do_rate_post(actor_info, object) do
    child_object = object["object"]

    if @rate_post do
      if child_object["content"] != nil do
        grade = Veritaserum.analyze(child_object["content"])
        Logger.info("rating found #{inspect(child_object)}:#{grade}")
      else
        grade = 0
      end

      child_object = Map.put(child_object, "sentiment_analysis", grade)
      object = Map.put(object, "object", child_object)
    end

    {:ok, object}
  end

  @impl true
  def filter(object) do
    actor_info = URI.parse(object["actor"])

    with {:ok, object} <- do_rate_post(actor_info, object) do
      {:ok, object}
    else
      _e -> {:reject, nil}
    end
  end
end
