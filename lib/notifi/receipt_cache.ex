defmodule Notifi.ReceiptCache do
  @moduledoc """
  A simple in-memory caching service to maintain the status of receipts.
  """

  use GenServer

  @table :receipts

  @doc """
  Starts the cache table as a GenServer.
  """
  @spec start_link(any) :: {:ok, pid}
  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Initializes the cache table.
  """
  @spec init(:ok) :: {:ok, map}
  def init(:ok) do
    :ets.new(@table, [:set, :public, :named_table])
    {:ok, %{}}
  end

  @doc """
  Stores a receipt in the cache table.
  """
  @spec store_receipt(map, atom) :: :ok
  def store_receipt(%{"id" => receipt_id}, status \\ :pending) do
    :ets.insert(@table, {receipt_id, status})
    :ok
  end

  @doc """
  Retrieves all pending receipts from the cache table.
  """
  @spec get_pending_receipts() :: list
  def get_pending_receipts do
    :ets.tab2list(@table)
    |> Enum.filter(fn {_, status} -> status == :pending end)
    |> Enum.map(fn {receipt_id, _} -> receipt_id end)
  end

  @doc """
  Updates the status of a receipt in the cache table.
  """
  @spec update_receipt_status(atom, atom) :: :ok
  def update_receipt_status(receipt_id, status) do
    :ets.insert(@table, {receipt_id, status})
    :ok
  end

  @doc """
  Counts the number of receipts by status in the cache table.
  """
  @spec count_receipts_by_status(atom) :: non_neg_integer
  def count_receipts_by_status(status \\ :pending) do
    :ets.select_count(@table, [{{:"$1", status}, [], [true]}])
  end

  @doc """
  Deletes a receipt from the cache table.
  """
  @spec delete_receipt(atom()) :: :ok
  def delete_receipt(receipt_id) do
    :ets.delete(@table, receipt_id)
    :ok
  end
end
