defmodule Notifi.ReceiptCheckerTest do
  use ExUnit.Case
  import ExUnit.CaptureLog
  alias Notifi.ReceiptChecker
  alias Notifi.ReceiptCache

  import Mock

  describe "check_receipts/0" do
    test "logs info and processes pending receipts" do
      with_mock ReceiptCache, get_pending_receipts: fn -> ["receipt1", "receipt2"] end do
        assert capture_log(fn -> ReceiptChecker.check_receipts() end) =~
                 "Checking pending receipts."
      end
    end
  end

  describe "maybe_update_push_status/1" do
    test "deletes receipt if status is ok" do
      with_mock ReceiptCache, delete_receipt: fn _ -> :ok end do
        assert Receipt
      end
    end
  end
end
