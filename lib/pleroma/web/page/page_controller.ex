defmodule Pleroma.Web.Page.PageController do
  use Pleroma.Web, :controller
  alias Pleroma.Web
  alias Pleroma.Web.Page.PageView

  def about(conn, _params) do
    conn
    |> render(PageView, "about.html")
  end

  def about_more(conn, _params) do
    conn
    |> render(PageView, "about_more.html")
  end
end
