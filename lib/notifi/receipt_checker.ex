defmodule Notifi.ReceiptChecker do
  @moduledoc """
  This module is responsible for checking the status of Expo push token receipts.
  """

  alias Notifi.ReceiptCache
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
  @spec check_receipts() :: :ok
  def check_receipts do
    Logger.info("Checking pending receipts.")

    receipts = ReceiptCache.get_pending_receipts()
    IO.inspect(receipts)

    receipts
    |> Enum.chunk_every(@message_chunk_size)
    |> Enum.each(&check_receipt_batch/1)
  end

  @spec check_receipt_batch(list) :: :ok | :error
  defp check_receipt_batch(receipts) do
    IO.inspect(receipts)
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

  @spec handle_receipts(map) :: :ok
  defp handle_receipts(%{"data" => push_statuses}) do
    Enum.each(push_statuses, &maybe_update_push_status/1)
    :ok
  end

  @spec maybe_update_push_status({String.t(), map()}) :: :ok
  defp maybe_update_push_status({receipt_id, %{"status" => status}}) do
    case status do
      "ok" ->
        ReceiptCache.delete_receipt(receipt_id)

      _ ->
        ReceiptCache.update_receipt_status(receipt_id, String.to_atom(status))
        Logger.warning(~c"Push notification failed for receipt: #{receipt_id}. Status: #{status}")
    end

    :ok
  end
end
