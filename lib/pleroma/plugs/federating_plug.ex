defmodule Pleroma.Web.FederatingPlug do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, opts) do
    if Keyword.get(Application.get_env(:pleroma, :instance), :federating) do
      conn
    else
      conn
      |> put_status(404)
      |> send_resp()
    end
  end

end
