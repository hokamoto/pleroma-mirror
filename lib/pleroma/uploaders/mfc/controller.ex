defmodule Pleroma.Uploaders.MFC.Controller do
  use Pleroma.Web, :controller
  alias Pleroma.Uploaders.MFC

  def callbacks(conn, params = %{"source_key" => key}) do
    process_callback(conn, :global.whereis_name({MFC, key}), params)
  end

  def callbacks(conn, _) do
    send_resp(conn, 400, "invalid request")
  end

  defp process_callback(conn, pid, %{"action" => "success", "dest_key" => path} = _)
       when is_pid(pid) do
    send(pid, {MFC, {:ok, path}})
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
