# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.ActivityPub.ObjectValidators.Types.Attachments do
  use Ecto.Type

  def type, do: {:array, :map}

  # Note based on Transmogrifier.prepare_attachments/1
  def cast(attachments_list) when is_list(attachments_list) do
    if Enum.all?(attachments_list, &is_map/1) do
      casted_attachments =
        Enum.map(
          attachments_list,
          fn data ->
            {media_type, href} =
              with [%{"mediaType" => media_type, "href" => href} | _] <- data["url"] do
                {media_type, href}
              else
                _ -> {nil, data["url"]}
              end

            %{"mediaType" => media_type, "type" => "Document"}
            |> Map.merge(data)
            |> Map.put("url", href)
          end
        )

      {:ok, casted_attachments}
    else
      :error
    end
  end

  def cast(_) do
    :error
  end

  def dump(data) do
    {:ok, data}
  end

  def load(data) do
    {:ok, data}
  end
end
