defmodule Notifi.ReceiptCacheTest do
  use ExUnit.Case
  alias Notifi.ReceiptCache

  describe "delete_receipt/1" do
    test "deletes a receipt by ID" do
      receipt_id = "receipt1"
      assert ReceiptCache.delete_receipt(receipt_id) == :ok
    end
  end

  describe "update_receipt_status/2" do
    test "updates the status of a receipt" do
      receipt_id = "receipt1"
      status = :error
      assert ReceiptCache.update_receipt_status(receipt_id, status) == :ok
    end
  end
end
