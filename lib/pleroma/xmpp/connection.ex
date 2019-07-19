defmodule Pleroma.XMPP.Connection do
  @moduledoc """
  XMPP connection manager
  """

  defstruct host: nil,
            jid: nil,
            sid: nil

  def start_link([]) do
  end
end
