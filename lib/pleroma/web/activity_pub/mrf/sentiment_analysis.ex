defmodule Pleroma.Web.ActivityPub.MRF.SentimentAnalysis do
  require Logger
  @behaviour Pleroma.Web.ActivityPub.MRF

  @mrf_policy Application.get_env(:pleroma, :mrf_sentimentanalysis)

  @rate_post Keyword.get(@mrf_policy, :sentiment_analysis_posts)
  @do_auto_cw Keyword.get(@mrf_policy, :sentiment_analysis_autocw)
  defp do_rate_post(object) do
    child_object = object["object"]
    grade = 0

    if @rate_post == true do
      if child_object["content"] != nil do
        grade = Veritaserum.analyze(child_object["content"])
        Logger.info("Found content:#{grade}")
      end

      if @do_auto_cw == true and grade < -1 do
        Logger.info("Marked sensitive !")
        child_object = Map.put(child_object, "sensitive", true)

        if child_object["summary"] != nil do
          child_object =
            Map.put(child_object, "summary", "[Negative: #{grade}]" <> child_object["summary"])
        else
          child_object = Map.put(child_object, "summary", "[Negative: #{grade}]")
        end
      end

      child_object = Map.put(child_object, "sentiment_analysis", grade)
      object = Map.put(object, "object", child_object)
    end

    Logger.info("Sentiment_analysis: #{inspect(child_object)}")
    {:ok, object}
  end

  @impl true
  def filter(object) do
    do_rate_post(object)
  end
end
