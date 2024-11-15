import Config
alias Notifi.Tasks.{TransactionReminder, Heartbeat}
alias Quantum.Job

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :notifi, Notifi.Scheduler,
  timezone: "America/New_York",
  jobs: [
    {"0 * * * *", {Heartbeat, :send, []}},
    {"* * * * *", {TransactionReminder, :send, []}},
    {"*/30 * * * *", {Notifi.ReceiptChecker, :check_receipts, []}}
  ]
