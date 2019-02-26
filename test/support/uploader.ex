defmodule Pleroma.Uploaders.Test do
  @behaviour Pleroma.Uploaders.Uploader

  def get_file(_) do
    {:ok, {:static_dir, Pleroma.Config.get!([__MODULE__, :uploads])}}
  end

  def put_file(upload) do
    {:ok, {:file, upload.path}}
  end
end
