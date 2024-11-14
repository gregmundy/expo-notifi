defmodule Notifi.NotificationClient do
  @moduledoc """
  This module is responsible for sending push notifications via Expo client.
  """

  require Logger
  alias Notifi.ReceiptStorage

  @expo_push_url "https://exp.host/--/api/v2/push/send"
  @message_chunk_size 100
  @headers [
    {"host", "exp.host"},
    {"accept", "application/json"},
    {"accept-encoding", "gzip, deflate"},
    {"content-type", "application/json"}
  ]
  @max_retries 5
  @initial_retry_delay 1_000

  @doc """
  Send a batch of notifications to Expo.
  """
  @spec send_notification(list) :: :ok | :error
  def send_notification(notifications) when is_list(notifications) do
    notifications
    |> Enum.chunk_every(@message_chunk_size)
    |> Enum.each(&send_batch/1)
  end

  defp send_batch(notifications, retries \\ 0) when is_list(notifications) do
    case HTTPoison.post(@expo_push_url, Jason.encode!(notifications), @headers) do
      {:ok, %HTTPoison.Response{body: body}} ->
        Jason.decode!(body)
        |> handle_push_tickets()

        Logger.info("Successfully sent push notifications.")

      {:error, %HTTPoison.Error{reason: reason}} ->
        if retries < @max_retries do
          Logger.warning(
            ~c"Failed to send push notifications. Retrying #{retries + 1} of #{@max_retries}"
          )

          :timer.sleep(calculate_exponential_delay(retries))
          send_batch(notifications, retries + 1)
        else
          Logger.error(~c"Send push notification failure.")
          {:error, reason}
        end
    end
  end

  defp calculate_exponential_delay(attempt) do
    delay = trunc(@initial_retry_delay * :math.pow(2, attempt - 1))
    jitter = :rand.uniform(500)
    delay + jitter
  end

  defp handle_push_tickets(%{"data" => tickets}) when is_list(tickets) do
    Enum.each(tickets, &ReceiptStorage.store_receipt/1)
  end
end
