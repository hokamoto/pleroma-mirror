defmodule Pleroma.Web.RichMedia.Parsers.OGP do
  def parse(html, data) do
    Pleroma.Web.RichMedia.Parsers.BaseParser.parse(
      html,
      data,
      "og",
      "No OGP metadata found",
      "property"
    )
  end
end
