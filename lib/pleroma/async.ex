defmodule Pleroma.Async do
  @moduledoc """
  A helper module for async tasks so that tests run smoothly
  """

  @doc """
  If the environment is test, run synchronously.
  Otherwise, run the function asynchronously using Task.start
  """
  def start(fun) do
    if Mix.env() == :test, do: fun.(), else: Task.start(fun)
  end
end
