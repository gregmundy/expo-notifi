defmodule Notifi.ReceiptChecker do
  @moduledoc """
  This module is responsible for checking the status of Expo push token receipts.
  """

  alias Notifi.ReceiptStorage
  require Logger

  @expo_receipt_url "https://exp.host/--/api/v2/push/getReceipts"
  @message_chunk_size 100
  @headers [
    {"host", "exp.host"},
    {"accept", "application/json"},
    {"content-type", "application/json"}
  ]

  @doc """
  Check pending receipts.
  """
  def check_receipts do
    Logger.info("Checking pending receipts.")

    ReceiptStorage.get_pending_receipts()
    |> Enum.chunk_every(@message_chunk_size)
    |> Enum.each(&check_receipt_batch/1)
  end

  defp check_receipt_batch(receipts) do
    payload = %{"ids" => receipts} |> Jason.encode!()

    case HTTPoison.post(@expo_receipt_url, payload, @headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
        |> Jason.decode!()
        |> handle_receipts()

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error(~c"Check receipt failure.")
        {:error, reason}
    end
  end

  defp handle_receipts(%{"data" => push_statuses}) do
    Enum.each(push_statuses, fn {receipt_id, %{"status" => status}} ->
      ReceiptStorage.update_receipt_status(receipt_id, status)
    end)
  end
end
