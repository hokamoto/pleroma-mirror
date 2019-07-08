# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Emails.Mailer do
  use Swoosh.Mailer,
    otp_app: :pleroma,
    perform_deliveries: &__MODULE__.enabled?/0

  def deliver_async(email, config \\ []) do
    PleromaJobQueue.enqueue(:mailer, __MODULE__, [:deliver_async, email, config])
  end

  def perform(:deliver_async, email, config), do: deliver(email, config)

  def enabled? do
    Pleroma.Config.get([:instance, :mailer])
  end
end
