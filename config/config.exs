import Config
alias Notifi.Tasks.{TransactionReminder, Heartbeat}

config :notifi, Notifi.Scheduler,
  jobs: [
    {"0 * * * *", {Heartbeat, :send, []}},
    {"0 17 * * *", {TransactionReminder, :send, []}, timezone: ~c"America/New_York"},
    {"*/30 * * * *", {Notifi.ReceiptChecker, :check_receipts, []}}
  ]

config :notifi, :mongo,
  name: :mongo,
  pool_size: 3
