defmodule Notifi.NotificationClient do
  @moduledoc """
  This module is responsible for sending push notifications via Expo client.
  """

  @expo_url "https://exp.host/--/api/v2/push/send"
  @message_chunk_size 100
  @headers [
    {"host", "exp.host"},
    {"accept", "application/json"},
    {"accept-encoding", "gzip, deflate"},
    {"content-type", "application/json"}
  ]

  @doc """
  Send a batch of notifications to Expo.
  """
  @spec send_notification(list) :: :ok | :error
  def send_notification(notifications) when is_list(notifications) do
    notifications
    |> Enum.chunk_every(@message_chunk_size)
    |> Enum.each(&send_batch/1)
  end

  @spec send_batch(list) :: :ok | :error
  defp send_batch(notifications) when is_list(notifications) do
    case HTTPoison.post(@expo_url, Jason.encode!(notifications), @headers) do
      {:ok, result} ->
        IO.inspect(result, label: "Batch sent successfully")

      {:error, reason} ->
        IO.inspect(reason, label: "Failed to send batch")
    end
  end
end
