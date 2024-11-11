import Config
alias Notifi.Tasks.{TransactionReminder, Heartbeat}

config :notifi, Notifi.Scheduler,
  jobs: [
    {"* * * * *", {Heartbeat, :send, []}},
    {"* * * * *", {TransactionReminder, :send, []}}
  ]
