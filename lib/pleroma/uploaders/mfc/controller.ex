defmodule Pleroma.Uploaders.MFC.Controller do
  use Pleroma.Web, :controller

  def callbacks(conn, params = %{"source_key" => key}) do
    process_callback(conn, :global.whereis_name({Pleroma.Uploaders.MFC, key}), params)
  end

  def callbacks(conn, _) do
    send_resp(conn, 400, "invalid request")
  end

  defp process_callback(conn, pid, params = %{"action" => "success", "dest_key" => path})
       when is_pid(pid) do
    send(pid, {Pleroma.Uploaders.MFC, {:ok, path}})
    send_resp(conn, 200, "ok")
  end

  defp process_callback(conn, pid, %{"action" => "failure", "error" => error}) when is_pid(pid) do
    send(pid, {Pleroma.Uploaders.MFC, {:error, error}})
    send_resp(conn, 200, "ok")
  end

  defp process_callback(conn, pid, _) do
    if is_pid(pid), do: send(pid, {Pleroma.Uploaders.MFC, :error, "invalid callback"})
    send_resp(conn, 400, "invalid request")
  end
end
