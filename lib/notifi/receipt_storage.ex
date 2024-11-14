defmodule Notifi.ReceiptStorage do
  @moduledoc """
  An ets wrapper for storing Expo push token receipts.
  """

  use GenServer

  @table_name :receipts

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    :ets.new(@table_name, [:set, :public, :named_table])
    {:ok, %{}}
  end

  def store_receipt(%{"id" => receipt_id}, status \\ :pending) do
    :ets.insert(@table_name, {receipt_id, status})
  end

  def get_pending_receipts do
    :ets.tab2list(@table_name)
    |> Enum.filter(fn {_, status} -> status == :pending end)
    |> Enum.map(fn {receipt_id, _} -> receipt_id end)
  end

  def update_receipt_status(receipt_id, status) do
    :ets.insert(@table_name, {receipt_id, status})
  end

  def count_receipts_by_status(status \\ :pending) do
    :ets.select_count(@table_name, [{{:"$1", status}, [], [true]}])
  end

  def delete_receipt(receipt_id) do
    :ets.delete(:receipt_table, receipt_id)
  end
end
