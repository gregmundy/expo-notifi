import Config
alias Notifi.Tasks.{TransactionReminder, Heartbeat}

config :notifi, Notifi.Scheduler,
  jobs: [
    {"* * * * *", {Heartbeat, :send, []}},
    {"* * * * *", {TransactionReminder, :send, []}},
    {"* * * * *", {Notifi.ReceiptChecker, :check_receipts, []}}
  ]

config :notifi, :mongo,
  name: :mongo,
  pool_size: 3
