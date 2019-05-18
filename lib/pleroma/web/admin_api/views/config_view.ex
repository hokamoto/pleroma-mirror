defmodule Pleroma.Web.AdminAPI.ConfigView do
  use Pleroma.Web, :view

  def render("index.json", %{configs: configs}) do
    %{
      configs: render_many(configs, __MODULE__, "show.json", as: :config)
    }
  end

  def render("show.json", %{config: config}) do
    %{
      key: config.key,
      value: Pleroma.Web.AdminAPI.Config.convert_value(config.value)
    }
  end
end
