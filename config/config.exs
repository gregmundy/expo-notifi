import Config
alias Notifi.Tasks.{TransactionReminder, Heartbeat}

config :notifi, Notifi.Scheduler,
  jobs: [
    {"* * * * *", {Heartbeat, :send, []}},
    {"* * * * *", {TransactionReminder, :send, []}}
  ]

config :notifi, :mongo,
  name: :mongo,
  pool_size: 3
