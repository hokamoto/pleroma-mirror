defmodule Pleroma.Uploaders.MFC.Controller do
  use Pleroma.Web, :controller
  alias Pleroma.Uploaders.MFC

  def callbacks(conn, %{"source_key" => key} = params) do
    process_callback(conn, :global.whereis_name({MFC, key}), params)
  end

  def callbacks(conn, _) do
    send_resp(conn, 400, "invalid request")
  end

  defp process_callback(conn, pid, %{"action" => "success"} = params)
       when is_pid(pid) do
    conversion_result = Pleroma.Uploaders.MFC.Video.parse_conversion_result(params)
    send(pid, {MFC, conversion_result})
    send_resp(conn, 200, "ok")
  end

  defp process_callback(conn, pid, %{"action" => "failure", "error" => error})
       when is_pid(pid) do
    send(pid, {MFC, {:error, error}})
    send_resp(conn, 200, "ok")
  end

  defp process_callback(conn, pid, _) do
    if is_pid(pid), do: send(pid, {MFC, :error, "invalid callback"})
    send_resp(conn, 400, "invalid request")
  end
end
