defmodule Pleroma.Web.ActivityPub.MRF.ContentClassifier do
  require Logger
  import Woolly.Utils.Profanity

  @behaviour Pleroma.Web.ActivityPub.MRF

  @mrf_policy Application.get_env(:pleroma, :mrf_content_classifier)

  @do_sa Keyword.get(@mrf_policy, :sentiment_analysis)
  defp do_rate_post(object) do
    child_object = object["object"]
    grade = 0

    if @do_sa == true do
      if child_object["content"] != nil do
        grade = Veritaserum.analyze(child_object["content"])
        Logger.info("Found content:#{grade}")
      end

      child_object = Map.put(child_object, "sentiment_analysis", grade)
      object = Map.put(object, "object", child_object)
    end

    {:ok, object}
  end

  @do_lang Keyword.get(@mrf_policy, :reprocess_lang)
  defp do_set_lang(object) do
    child_object = object["object"]
    lang = ''

    if @do_lang == true do
      if child_object["content"] != nil do
        lang = Paasaa.detect(child_object["content"])
      end

      child_object = Map.put(child_object, "lang", lang)
      object = Map.put(object, "object", child_object)
    end

    {:ok, object}
  end

  @do_set_prof Keyword.get(@mrf_policy, :set_profanities)
  defp do_set_profanities(object) do
    child_object = object["object"]

    if @do_set_prof == true do
      if child_object["content"] != nil do
        new_content = remove_profanity(String.split(child_object["content"]))

        if new_content != String.split(child_object["content"]) do
          has_prof = true
        else
          has_prof = false
        end

        child_object = Map.put(child_object, "profanities", has_prof)
        object = Map.put(object, "object", child_object)
      end
    end

    {:ok, object}
  end

  @impl true
  def filter(object) do
    with {:ok, object} <- do_rate_post(object),
         {:ok, object} <- do_set_lang(object),
         {:ok, object} <- do_set_profanities(object) do
      Logger.info("content_classifier: #{inspect(object)}")
      {:ok, object}
    end
  end
end
