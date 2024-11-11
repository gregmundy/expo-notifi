defmodule Notifi.Tasks.Heartbeat do
  require Logger

  def send do
    Logger.info("💓 Heartbeat")
  end
end
